var gulp = require('gulp'),
    util = require('util'),
    gutil = require('gulp-util'),
    path = require('path'),
    exec = require('child_process').exec,
    Q = require('q');

var playerVersion = '16.0';
var flexSdk = path.join('D:', 'Works', 'ActionScript', 'SDK', 'Flex-4.13.0');
var airSdk = path.join('D:', 'Works', 'ActionScript', 'SDK', 'AIR-16.0.0');
var compc = path.resolve(flexSdk, './bin/compc');
var libs = path.resolve(flexSdk, './frameworks/libs');
var playerGlobal = path.resolve(libs, util.format('./player/%s/playerglobal.swc', playerVersion));

gulp.task('create:swc', function() {
    var deferred = Q.defer();
    var execCommand = createCompc(compc, 'lib', {'MOBILE':true, 'DEFAULT':false});
    gutil.log('exec: ' + execCommand);
    exec(createCompc(compc, 'lib'), function(error, stdout, stderr) {
        gutil.log(gutil.colors.yellow(stdout));
        gutil.log(gutil.colors.red('Error: ' + stderr));
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

function createCompc(app, libName, defines) {
    var result = app;

    if(defines){
        for (var key in defines){
            result = addCommand(result, util.format('-define+=CONFIG::%s,%s', key, defines[key]));
        }
    }

    result = addCommand(result, '-compiler.debug=false');
    result = addCommand(result, util.format('-output=application/export/%s.swc', libName));
    result = addCommand(result, '-include-sources=client/src');
    result = addCommand(result, '-source-path=client/src');
    // result = addCommand(result, util.format('-target-player=%s', playerVersion));
    result = addCommand(result, util.format('-library-path=%s,%s', playerGlobal, libs));
    return result;
}