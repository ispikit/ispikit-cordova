/*global cordova*/
cordova.define("cordova/plugin/ispikit",
    function (require, exports, module) {
        var serviceName = (device.platform == "Android") ? "IspikitWrapper" : "IspikitCordovaPlugin";
        var noAudioPlayer = (device.platform == "Android");
        var exec = cordova.require('cordova/exec');
        function init(win, fail) {
            exec(win, fail, serviceName, "init", []);
	}
        function setResultCallback(win, fail) {
	    console.log("In function setResultcallback");
            exec(win, fail, serviceName, "setResultCallback", []);
	}

        function setNewWordsCallback(win, fail) {
            exec(win, fail, serviceName, "setNewWordsCallback", []);
	}

        function setCompletionCallback(win, fail) {
            exec(win, fail, serviceName, "setCompletionCallback", []);
	}

        function setPitchCallback(win, fail) {
            exec(win, fail, serviceName, "setPitchCallback", []);
	}

        function setWaveformCallback(win, fail) {
            exec(win, fail, serviceName, "setWaveformCallback", []);
	}

        function setVolumeCallback(win, fail) {
            exec(win, fail, serviceName, "setVolumeCallback", []);
	}

        function setWaveFileCallback(win, fail) {
            exec(win, fail, serviceName, "setWaveFileCallback", []);
	}

        function start(sentences, win, fail) {
            exec(win, fail, serviceName, "start", [sentences]);
	}

        function stop(win, fail) {
            exec(win, fail, serviceName, "stop", []);
	}

        function startPlayback(win, fail) {
            exec(win, fail, serviceName, "startPlayback", []);
	}

        function stopPlayback(win, fail) {
            exec(win, fail, serviceName, "stopPlayback", []);
	}

        function startLoadURL(id, url, win, fail) {
	    if (noAudioPlayer) return false;
            exec(win, fail, serviceName, "startLoadURL", [id, url]);
	}

        function startPlay(id, win, fail) {
	    if (noAudioPlayer) return false;
            exec(win, fail, serviceName, "startPlay", [id]);
	}

        function stopPlay(id, win, fail) {
	    if (noAudioPlayer) return false;
            exec(win, fail, serviceName, "stopPlay", [id]);
	}

        module.exports = {
            init: init,
	    start: start,
	    stop: stop,
            setPitchCallback: setPitchCallback,
            setWaveformCallback: setWaveformCallback,
            setVolumeCallback: setVolumeCallback,
            setWaveFileCallback: setWaveFileCallback,
            setResultCallback: setResultCallback,
            setNewWordsCallback: setNewWordsCallback,
            setCompletionCallback: setCompletionCallback,
	    startPlayback: startPlayback,
	    stopPlayback: stopPlayback,
	    startLoadURL: startLoadURL,
	    startPlay: startPlay,
	    stopPlay: stopPlay
        }
    }
);
