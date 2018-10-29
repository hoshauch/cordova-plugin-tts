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

exports.stop = function (success, error) {
    cordova.exec(success, error, 'TTS', 'stop', []);
};

exports.checkLanguage = function (success, error) {
    cordova.exec(success, error, 'TTS', 'checkLanguage', []);
};

exports.openInstallTts = function (success, error) {
    cordova.exec(success, error, 'TTS', 'openInstallTts', []);
};
