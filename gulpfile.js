var gulp = require('gulp'),
    util = require('util'),
    gutil = require('gulp-util'),
    path = require('path'),
    exec = require('child_process').exec,
    Q = require('q');

var playerVersion = '16.0';
var flexSdk = '/home/nicolas/Documents/ActionScript/sdk/apache-flex-4.13.0';
var airSdk = path.join('D:', 'Works', 'ActionScript', 'SDK', 'AIR-16.0.0');
var compc = path.resolve(flexSdk, './bin/compc');
var libs = path.resolve(flexSdk, './frameworks/libs');


gulp.task('create:swc-web', function() {
    var deferred = Q.defer();
    execCommand(createCompc(compc, 'logger', 'web'), deferred);
    return deferred.promise;
});

gulp.task('create:swc-mobile', function() {
    var deferred = Q.defer();
    execCommand(createCompc(compc, 'logger-mobile', 'mobile'), deferred);
    return deferred.promise;
});

gulp.task('default', ['create:swc-web', 'create:swc-mobile']);

function addCommand(app, command) {
    app += ' ' + command;
    return app;
}

function createCompc(app, libName, libType) {
    var result = app;

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
    exec(command, function(error, stdout, stderr) {
        gutil.log(gutil.colors.yellow(stdout));
        if(stderr){
            gutil.log(gutil.colors.red('Error: ' + stderr));
        }
        // if (error !== null) {
            //gutil.log('exec error: ' + error);
        // }
        deferred.resolve();
    });
}