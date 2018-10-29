/*

    Cordova Text-to-Speech Plugin
    https://github.com/vilic/cordova-plugin-tts

    by VILIC VANE
    https://github.com/vilic

    MIT License

*/

exports.speak = function (options, success, error) {
    cordova.exec(success, error, 'TTS', 'speak', [options]);
};

exports.stop = function () {
    return new Promise(function (resolve, reject) {
        cordova.exec(resolve, reject, 'TTS', 'stop', []);
    });
};

exports.checkLanguage = function () {
    return new Promise(function (resolve, reject) {
        cordova.exec(resolve, reject, 'TTS', 'checkLanguage', []);
    });
};

exports.openInstallTts = function () {
    return new Promise(function (resolve, reject) {
        cordova.exec(resolve, reject, 'TTS', 'openInstallTts', []);
    });
};
