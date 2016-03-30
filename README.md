Ispikit Cordova Plugin
======================

### This is version 2.0 of the Ispikit Cordova plugin

This is the documentation of the Ispikit Cordova plugin, it brings speech recognition and pronunciation assessment to Cordova applications.

This version is free to use and includes two limitations compared to the full version:

* Number of sentences for recognition is limited to 3
* Number of words per sentence is limited to 4

Contact us at info@ispikit.com for the full version.

## 1. Features

* Audio recording: records user's voice through internal or external microphone.
* Speech recognition: recognizes what the user said among several possible inputs. Recognized words are available in real time.
* Pronunciation assessment: returns overall pronunciation score.
* Playback of user's input: recorded voice can be played back.
* Mispronounced words detection: detects and flags words that have been mispronounced.
* Audio volume: During recording, audio volume callbacks can be used to display the audio input level.
* Waveform: during recording, waveform callbacks can be used to draw and display the recorded audio.
* Pitch tracking: during recording, pitch callbacks can be used to plot user's pitch contour (intonation).
* Local-only: everything happens locally, no network call made.

Note: this build includes binaries for all iOS architectures (simulator or device) and Android (x86 and ARM).

## 2. Content

This package includes:

* `example`: A sample boilerplate Cordova application.
* `ispikit.js`: JavaScript interface for the plugin.
* `plugin.xml`: Plugin config.
* `res`: Plugin resources.
* `src`: Plugin sources and libraries.
* `README.md`: This file.
* `LICENSE`

## 3. Starting with the Ispikit Cordova plugin

You can start from the provided example app to build on:

* Generate a new Cordova application:
```
cordova create myapp
```
* Add the platforms you want (iOS and/or Android)
```
cordova platform add ios
```
* Add the console and device plugins (console might not be nescessary, and seems to be buggy on Android).
```
cordova plugin add cordova-plugin-device cordova-plugin-console
```
* Add the Ispikit plugin
```
cordova plugin add https://github.com/ispikit/ispikit-cordova.git
```
* Replace `www/index.html` and `www/js/index.js` from your `myapp` app by the ones in the example directory of the plugin
* For Android, add the permission to record audio in `platforms/android/AndroidManifest.xml`
```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```
* Launch the application:
```
cordova run ios --simulator
```
* The app will start and plugin will initialize:
  * Once plugin is initialized, press the "Start" button and speak one of the following sentences: "one two three four five", "I am learning English", "from New York to San Francisco".
  * While speaking, audio volume and recognized words (coded with indexes explained below) are displayed.
  * Press the "Stop" button.
  * During analysis, a completion callback is called that shows what percentage of analysis has been completed.
  * At the end of analysis, the result string is given (the pronunciation score, the speed and the words with mispronunciation flags, those are explained below).
  * After result is displayed, press the "Start Replay" button,  the recorded voice is played back again.

You can reuse this boilerplate code to build your application using the more detailed docs below.

## 4. Usage

The available API calls are listed in `ispikit.js`. They include calls to send instructions to the plugins and calls to register callback functions. Callback are used by the plugin to give real time information back to the application.

In this section, we also document the meaning of the callbacks' arguments.

### 4.1 The ispikit object

Before you can do anything with the Ispikit plugin, you need to get the ispikit object. This must happen after the `deviceready` event:

```
var ispikit = cordova.require("cordova/plugin/ispikit");
```

As stated earlier, you need the `cordova-plugin-device` plugin for that. All calls described here are made on this `ispikit` object.

### 4.2 `function init(win, fail)` 

The first thing to do with the `ispikit` object is to initialize it. It typically takes a few seconds and calls back `win` if successful or `fail` if not. Those callbacks have no arguments.

### 4.3 `function setResultCallback(win, fail)`

This adds callback when results of analysis are ready. You only need to set the `win` callback. This callback takes three arguments, `(score, speed, words)`:

* `score` is the pronunciation score, it is a number between 0 (worse) and 100 (perfect pronunciation).
* `speed` is a measure of how many phonemes have been uttered in 10 seconds.
* `words` are the recognized words during the recording, they are given with a bunch of indexes separated with dashes ("-"). The first index is the index of the sentence that was recognized (starting with 0, the first sentence given to the call to `start(sentences)`. The second index is the word index within the sentence, also starting with 0, and the third number is a flag: 0 if the word was correctly said, 1 if it was mispronounced. Word level mispronunciation detection is not 100% accurate, especially for short words.

For instance, if `start` was called with "one two three,four five,six seven eight" and result is `(55, 82, "2-0-0 2-2-1"), it means that the overall pronunciation score is 55 (over a scale of 0 to 100), speed was 82 (phonemes per 10 seconds), and user said "six eight", "eight" being mispronounced.

### 4.4 `function setNewWordsCallback(win, fail)`

It specifies to the plugin the callback to be called during recording to show which words have been recognized up to that point. You only need to set the `win` callback. The callback takes one argument, a string where each word is given encoded with 4 indexes separate with dashes:

* First index is the index of the sentence.
* Second index is the word index within the sentence.
* Third and fourth indexes are not really meaningful from a user's point of view.

For instance, if `start` was called with "one two three four five,six seven eight nine ten" and callback parameter is "1-0-0-0 1-1-0-0 1-3-0-0", it means that at this moment, user said "six seven nine".

### 4.5 `function setCompletionCallback(win, fail)`

It specifies to the plugin the callback to be called during analysis to give the percentage of completion. You only need to set the `win` callback. The callback takes one argument, an integer between 0 and 100, representing the percentage of completion. It can be used to show a progress bar, especially for long inputs, where analysis can take a few seconds.

### 4.6 `function setPitchCallback(win, fail)`

It specifies to the plugin the callback to be called during recording to give the pitch contour in real time. You only need to set the `win` callback. The callback takes a variable number of arguments, each being a pitch sample. You can access the samples by iterating through the JavaScript `arguments` of the callback function. These pitch samples can be used to draw the intonation in real time.

### 4.7 `function setWaveformCallback(win, fail)`

It specifies to the plugin the callback to be called during recording to give the waveform contour in real time. You only need to set the `win` callback. The callback takes a variable number of arguments, where the first half are the upper points of the contour and the second half are the lower points. You can access the samples by iterating through the JavaScript `arguments` of the callback function. These samples can be used to draw the waveform in real time.

### 4.8 `function setVolumeCallback(win, fail)`

It specifies to the plugin the callback to be called during recording to give the volume of the recorded audio. You only need to set the `win` callback. The callback takes one argument, an integer between 0 and 100, representing the current audio volume. It can be used to draw a meter of the recorded audio.

### 4.9 `function setWaveFileCallback(win, fail)`

It specifies to the plugin the callback to be called after recording to give the wave file of the recorded audio. You only need to set the `win` callback. The callback takes one argument, a sting containing the .wav file, encoded in base64. It can be used to keep student's recording on the device or send it to a server.

### 4.10 `function start(sentences, win, fail)`

This starts audio recording, assuming that plugin was properly initialized before. As argument, a string with one or several sentences to be recognized. Sentences are comma separated, with no punctuation and just one space between words.

### 4.11 `function stop(win, fail)`

This stops recording. It also immediately starts analysis during which completion callbacks will be regularly called. Analysis is done when result callback comes.

### 4.12 `function startPlayback(win, fail)`

This starts replaying back the previously recorded audio. It takes a callback as argument that will be called when audio completely played back. Audio playback can also be stopped with `stopPlayback`.

### 4.13 `function stopPlayback(win, fail)`

Stops audio playback immediately.

### 4.14 `function startLoadURL(id, url, win, fail)`

On iOS only.

Loads a URL of an audio file to be played back later. Takes the URL and an id that will be used to start the playback later.

### 4.15 `function startPlay(id, win, fail)`

On iOS only.

Starts playing back the URL corresponding to the given id. The URL must have been previously loaded with `startLoadURL`.

### 4.16 `function stopPlay(id, win, fail)`

On iOS only.

Stop playing back the URL corresponding to the given id.

## 5. Notes

* On Android, do not forget to set the permission to record audio (see section 3.). Also, on Android 6+, user must grant permission explicitly. The plugin includes a standard request modal for that, you can modify it if necessary in `./src/android/SimpleIspikitWrapper.java`. Audio recording permission should be granted before plugin is initialized.
* On Android, in the emulator, audio recording is not working properly. You can use and test the app, but the recording and analysis results are not meaningful.

