#import <Cordova/CDVPlugin.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
@interface IspikitCordovaPlugin : CDVPlugin

- (void) init:(CDVInvokedUrlCommand*)command;
- (void) start:(CDVInvokedUrlCommand*)command;
- (void) stop:(CDVInvokedUrlCommand*)command;
- (void) startPlayback:(CDVInvokedUrlCommand*)command;
- (void) stopPlayback:(CDVInvokedUrlCommand*)command;
- (void) startLoadURL:(CDVInvokedUrlCommand*)command;
- (void) startPlay:(CDVInvokedUrlCommand*)command;
- (void) stopPlay:(CDVInvokedUrlCommand*)command;
- (void) setPitchCallback:(CDVInvokedUrlCommand*)command;
- (void) setResultCallback:(CDVInvokedUrlCommand*)command;
- (void) setNewWordsCallback:(CDVInvokedUrlCommand*)command;
- (void) setWaveformCallback:(CDVInvokedUrlCommand*)command;
- (void) setVolumeCallback:(CDVInvokedUrlCommand*)command;
- (void) setCompletionCallback:(CDVInvokedUrlCommand*)command;
- (void) setWaveFileCallback:(CDVInvokedUrlCommand*)command;
- (void) playerItemDidReachEnd:(NSNotification *)notification;

@end
