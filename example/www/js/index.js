/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
	this.sentences = "one two three four five,I am learning English,from new york to san francisco";
    },
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    startRecognition: function() {
	app.ispikit.start(app.sentences, function() {}, function() {});
    },
    stopRecognition: function() {
	app.ispikit.stop(function() {
		console.log("Recognition stopped successfully");
	    }, function() {
		console.log("Error while stopping");
	    });
    },
    startReplay: function() {
	app.ispikit.startPlayback(function() {
		console.log("Playback started successfully");
	    }, function() {
		console.log("Error while starting playback");
	    });
    },
    stopReplay: function() {
	app.ispikit.stopPlayback(function() {
		console.log("Playback stopped successfully");
	    }, function() {
		console.log("Error while stopping playback");
	    });
    },
    onInitDone: function(success) {
	if(success) {
	    document.getElementById("status").innerHTML = "Initialized";
	    document.getElementById("startButton").onclick = app.startRecognition;
	    document.getElementById("stopButton").onclick = app.stopRecognition;
	    document.getElementById("replayButton").onclick = app.startReplay;
	    document.getElementById("replayStopButton").onclick = app.stopReplay;
	    app.ispikit.setVolumeCallback(function(volume) {
		    document.getElementById("volume").innerHTML = volume;
		});
	    app.ispikit.setCompletionCallback(function(completion) {
		    document.getElementById("completion").innerHTML = completion;
		});
	    app.ispikit.setPitchCallback(function() {
		    console.log("Pitch samples");
		    for (var i = 0 ; i < arguments.length ; i++) {
			console.log(arguments[i]);
		    }
		});
	    app.ispikit.setWaveformCallback(function() {
		    console.log("Waveform samples");
		    for (var i = 0 ; i < arguments.length ; i++) {
			console.log(arguments[i]);
		    }
		});
	    app.ispikit.setResultCallback(function() {
		    var output = document.getElementById("result");
		    output.innerHTML = "";
		    for (var i = 0 ; i < arguments.length ; i++) {
			output.innerHTML += " " + arguments[i] + " ; ";
		    }
		});
	    app.ispikit.setNewWordsCallback(function(words) {
		    document.getElementById("words").innerHTML = words;
		});
	} else
	    document.getElementById("status").innerHTML = "Error";
    },
    onDeviceReady: function() {
	app.receivedReadyEvent();
	app.ispikit = cordova.require("cordova/plugin/ispikit");
	app.ispikit.init(function() {app.onInitDone(true);},function() {app.onInitDone(false);});
    },
    // Update DOM on a Received Event
    receivedReadyEvent: function() {
        var parentElement = document.getElementById("deviceready");
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

    }
};

app.initialize();