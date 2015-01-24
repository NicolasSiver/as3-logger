var gulp = require('gulp'),
    util = require('util'),
    gutil = require('gulp-util'),
    path = require('path'),
    exec = require('child_process').exec,
    Q = require('q');

var playerVersion = '16.0';
// var flexSdk = path.jnhome', 'Documents', 'ActionScript', 'sdk', 'apache-flex-4.13.0');
var flexSdk = '/home/nicolas/Documents/ActionScript/sdk/apache-flex-4.13.0';
var airSdk = path.join('D:', 'Works', 'ActionScript', 'SDK', 'AIR-16.0.0');
var compc = path.resolve(flexSdk, './bin/compc');
var libs = path.resolve(flexSdk, './frameworks/libs');
var playerGlobal = path.resolve(libs, util.format('./player/%s/playerglobal.swc', playerVersion));

// process.env['PLAYERGLOBAL_HOME'] = path.resolve(libs, 'player');

gulp.task('create:swc', function() {
    var deferred = Q.defer();
    var execCommand = createCompc(compc, 'lib', {'MOBILE':true, 'DEFAULT':false});
    gutil.log('exec: ' + execCommand);
    exec(createCompc(compc, 'lib'), function(error, stdout, stderr) {
        gutil.log(gutil.colors.yellow(stdout));
        if(stderr){
            gutil.log(gutil.colors.red('Error: ' + stderr));
        }
        // if (error !== null) {
            //gutil.log('exec error: ' + error);
        // }
        deferred.resolve();
    });
    return deferred.promise;
});

gulp.task('default', ['create:swc']);

function addCommand(app, command) {
    app += ' ' + command;
    return app;
}

function createCompc(app, libName) {
    var result = app;

    result = addCommand(result, '-compiler.debug=false');
    result = addCommand(result, util.format('-output=application/export/%s.swc', libName));
    result = addCommand(result, '-include-sources=client/src');
    result = addCommand(result, '-source-path=client/src');
    result = addCommand(result, util.format('-target-player=%s', playerVersion));
    result = addCommand(result, util.format('-load-config=%s', 'lib-config.xml'));
    return result;
}