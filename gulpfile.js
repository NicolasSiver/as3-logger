var gulp = require('gulp'),
    util = require('util'),
    gutil = require('gulp-util'),
    path = require('path'),
    exec = require('child_process').exec,
    Q = require('q'),
    credentials = require('./credentials'),
    request = require('request'),
    fs = require('fs'),
    rename = require("gulp-rename"),
    replace = require('gulp-replace'),
    sftp = require('gulp-sftp');


var playerVersion = '16.0',
    flexSdk = path.join.apply(path, credentials.flexSdk),
    airDescriptor = path.join('./application', 'Descriptor.xml'),
    compc = path.resolve(flexSdk, './bin/compc'),
    adt = path.resolve(flexSdk, './bin/adt'),
    currentVersion = null,
    currentDate = null,
    appUrl = null,
    log = null;

gulp.task('compile:app', ['copy:content'], function () {
    var deferred = Q.defer();
    execCommand(composeAdt(adt), deferred);
    return deferred.promise;
});

gulp.task('copy:content', ['create:swc-web', 'create:swc-mobile'], function () {
    return gulp
        .src(['application/export/**', 'application/icons/**'], {'base': 'application'})
        .pipe(gulp.dest('application/out/'));
});

gulp.task('create:swc-web', function () {
    var deferred = Q.defer();
    execCommand(createCompc(compc, 'logger', 'web'), deferred);
    return deferred.promise;
});

gulp.task('create:swc-mobile', function () {
    var deferred = Q.defer();
    execCommand(createCompc(compc, 'logger-mobile', 'mobile'), deferred);
    return deferred.promise;
});

gulp.task('create:update-xml', ['publish:app'], function () {
    return gulp
        .src('update*.xml')
        .pipe(replace('{{versionNumber}}', currentVersion))
        .pipe(replace('{{versionLabel}}', currentVersion))
        .pipe(replace('{{appUrl}}', appUrl))
        .pipe(replace('{{description}}', log))
        .pipe(rename('update.xml'))
        .pipe(gulp.dest('bin'));
});

gulp.task('parse:log', function () {
    var changeLog = fs.readFileSync('changelog.md', {encoding: 'utf8'});
    var versionLine = changeLog.match(/#+.*:\s+(.*),\s+(.*)/);
    var changes = changeLog.match(/(\r\n\*.*)+/);
    currentVersion = versionLine[1];
    currentDate = versionLine[2];
    log = changes[0];
    gutil.log(gutil.colors.yellow(currentVersion), 'from ' + currentDate);
});

gulp.task('publish:app', ['compile:app'], function () {
    var deferred = Q.defer();
    request({
        url: util.format('https://api.github.com/repos/%s/%s/releases', credentials.github.user, credentials.github.repo),
        method: 'POST',
        json: true,
        body: {
            tag_name: util.format('v%s', currentVersion),
            target_commitish: 'master',
            name: util.format('Version: %s', currentVersion),
            body: log,
            draft: false,
            prerelease: false
        },
        headers: {
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': 'token ' + credentials.github.token,
            'User-Agent': 'As3Logger-Publish-Script'
        }
    }, function (error, response, body) {
        if (error) {
            deferred.reject(new Error(JSON.stringify(error)));
        } else {
            if (response.statusCode == 201) {
                var loggerData = fs.readFileSync('bin/as3logger.air');

                request({
                    url: body.upload_url.replace('{?name}', util.format('?name=As3Logger-v%s.air', currentVersion)),
                    method: 'POST',
                    body: loggerData,
                    headers: {
                        'Accept': 'application/vnd.github.v3+json',
                        'Authorization': 'token ' + credentials.github.token,
                        'User-Agent': 'As3Logger-Publish-Script',
                        'Content-Type': 'application/zip'
                    }
                }, function (error, response, body) {
                    if (error) {
                        deferred.reject(new Error(JSON.stringify(error)));
                    } else {
                        if (response.statusCode == 201) {
                            appUrl = JSON.parse(body).browser_download_url;
                            gutil.log(gutil.colors.green('Application published at ' + appUrl));
                            deferred.resolve();
                        } else {
                            //API error
                            gutil.log(gutil.colors.red('Error: ' + JSON.stringify(body)));
                            deferred.reject(new Error(body.message));
                        }
                    }
                });
            } else {
                //Handle API error
                gutil.log(gutil.colors.red('Error: ' + JSON.stringify(body)));
                deferred.reject(new Error(body.message));
            }
        }
    });
    return deferred.promise;
});

gulp.task('upload:update-xml', ['create:update-xml'], function () {
    return gulp
        .src('bin/update.xml')
        .pipe(sftp({
            host: credentials.host.url,
            remotePath: credentials.host.path,
            user: credentials.host.user,
            passphrase: credentials.host.pwd
        }));
});

gulp.task('validate:app-semver', ['parse:log'], function () {
    var descriptor = fs.readFileSync(airDescriptor, {encoding: 'utf8'});
    var versionLine = descriptor.match(/<versionNumber>(.*?)<\/versionNumber>/);
    var appVersion = versionLine[1];

    if (currentVersion !== appVersion) {
        throw new Error('Application version and Changelog are not synced');
    } else {
        gutil.log(gutil.colors.green('Application version is valid'));
    }
});

gulp.task('default', [
    'validate:app-semver',
    'publish:app',
    'upload:update-xml'
]);

function addCommand(app, command) {
    app += ' ' + command;
    return app;
}

function composeAdt(compiler) {
    var result = compiler;

    result = addCommand(result, '-package');
    result = addCommand(result, '-storetype pkcs12');
    result = addCommand(result, util.format('-keystore %s', credentials.keystore));
    result = addCommand(result, util.format('-storepass %s', credentials.storepass));
    //Output
    result = addCommand(result, 'bin/as3logger.air');
    //Descriptor
    result = addCommand(result, 'application/out/Descriptor.xml');
    //Content, base
    result = addCommand(result, '-C application/out');
    result = addCommand(result, 'Main.swf');
    result = addCommand(result, 'export icons');
    return result;
}

function createCompc(compiler, libName, libType) {
    var result = compiler;

    result = addCommand(result, '-compiler.debug=false');
    result = addCommand(result, util.format('-output=application/export/%s.swc', libName));
    result = addCommand(result, '-include-sources=client/src');
    result = addCommand(result, '-source-path=client/src');
    result = addCommand(result, util.format('-target-player=%s', playerVersion));
    result = addCommand(result, util.format('-load-config=%s', 'lib-config.xml'));
    result = addCommand(result, util.format('-load-config+=def-%s.xml', libType));
    return result;
}

function execCommand(command, deferred) {
    gutil.log('exec: ' + gutil.colors.cyan(command));
    exec(command, function (error, stdout, stderr) {
        gutil.log(gutil.colors.yellow(stdout));
        if (stderr) {
            gutil.log(gutil.colors.red('Error: ' + stderr));
        }
        // if (error !== null) {
        //gutil.log('exec error: ' + error);
        // }
        deferred.resolve();
    });
}