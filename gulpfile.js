var gulp = require('gulp'),
    util = require('util'),
    gutil = require('gulp-util'),
    path = require('path'),
    exec = require('child_process').exec,
    Q = require('q'),
    credentials = require('./credentials');

var playerVersion = '16.0';
var flexSdk = path.join.apply(path, credentials.flexSdk);
var compc = path.resolve(flexSdk, './bin/compc');
var adt = path.resolve(flexSdk, './bin/adt');

gulp.task('compile:app', function () {
    var deferred = Q.defer();
    execCommand(composeAdt(adt), deferred);
    return deferred.promise;
});

gulp.task('copy:content', function () {
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

gulp.task('default', ['create:swc-web', 'create:swc-mobile', 'copy:content']);

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
    result = addCommand(result, 'as3logger.air');
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
    gutil.log('exec: ' + command);
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