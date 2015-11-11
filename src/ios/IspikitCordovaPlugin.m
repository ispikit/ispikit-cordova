#import "IspikitCordovaPlugin.h"
#import "ISTAnalyzer.h"
@implementation IspikitCordovaPlugin

ISTAnalyzer* analyzer;
AVPlayer* player;
NSMutableDictionary* audioTable;
NSString* currentAudioItemId;
NSString *initDoneCallbackId;
NSString *startCallbackId;
NSString *newPitchCallbackId;
NSString *resultsCallbackId;
NSString *newWaveformCallbackId;
NSString *newWordsCallbackId;
NSString *newVolumeCallbackId;
NSString *newWaveFileCallbackId;
NSString *completionCallbackId;
NSString *playbackDoneCallbackId;
NSString *playURLDoneCallbackId;
CDVPluginResult* startCallback;
CDVPluginResult* newPitchCallback;
CDVPluginResult* resultsCallback;
CDVPluginResult* newWaveformCallback;
CDVPluginResult* newWordsCallback;
CDVPluginResult* newVolumeCallback;
CDVPluginResult* newWaveFileCallback;
CDVPluginResult* completionCallback;
CDVPluginResult* playbackDoneCallback;
CDVPluginResult* playURLDoneCallback;

- (void) initDoneWithStatus:(NSNumber *)initStatus {
  if ([initStatus shortValue] == 0) {
     CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:initDoneCallbackId];
  } else {
     CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:result callbackId:initDoneCallbackId];
  } 
}

- (void) newAudioWithAudio:(NSArray *)pitch waveformLow:(NSArray *)waveformLow waveformHigh:(NSArray *)waveformHigh volume:(unsigned char) volume {
  newPitchCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:pitch];
  newWaveformCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:[waveformLow arrayByAddingObjectsFromArray:waveformHigh]];
  newVolumeCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:volume];
  [newWaveformCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [newPitchCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [newVolumeCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:newPitchCallback callbackId:newPitchCallbackId];
  [self.commandDelegate sendPluginResult:newWaveformCallback callbackId:newWaveformCallbackId];
  [self.commandDelegate sendPluginResult:newVolumeCallback callbackId:newVolumeCallbackId];
}

- (void) newResultWithResult:(int)score speed:(int)speed words:(NSString *)words {
  NSArray* output = @[[NSString stringWithFormat:@"%d", score], [NSString stringWithFormat:@"%d", speed], words];
  resultsCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:output];
  [resultsCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:resultsCallback callbackId:resultsCallbackId];
}

- (void) newWordsWithWords:(NSString *)words {
  newWordsCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:words];
  [newWordsCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:newWordsCallback callbackId:newWordsCallbackId];
}

- (void) completionWithCompletion:(int)completion {
  completionCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:completion];
  [completionCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:completionCallback callbackId:completionCallbackId];
}

- (void) newAudioFileWithFile:(NSString *)waveFile {
  newWaveFileCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:waveFile];
  [newWaveFileCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:newWaveFileCallback callbackId:newWaveFileCallbackId];
}

- (void) playbackDone:(NSNumber *)x {
  playbackDoneCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [playbackDoneCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:playbackDoneCallback callbackId:playbackDoneCallbackId];
}

- (void)init:(CDVInvokedUrlCommand*)command
{
    // Needed to play audio back with AVAudio
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    audioTable = [[NSMutableDictionary alloc] init];
    initDoneCallbackId = [command callbackId];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                            sizeof(audioRouteOverride), &audioRouteOverride);
    player = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
					  selector:@selector(playerItemDidReachEnd:)
					  name:AVPlayerItemDidPlayToEndTimeNotification
					  object:nil];
    analyzer = [ISTAnalyzer new];
    IspikitCordovaPlugin * weakSelf = self;
    [analyzer setInitDoneCallback:^(int initStatus){
        NSNumber * status = [NSNumber numberWithInt:initStatus];
        [weakSelf performSelectorOnMainThread:@selector(initDoneWithStatus:) withObject:status waitUntilDone:NO];
     }];
    [analyzer startInitialization];
}

- (void)setResultCallback:(CDVInvokedUrlCommand*)command
{
    resultsCallbackId = [command callbackId];
    resultsCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [resultsCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)setCompletionCallback:(CDVInvokedUrlCommand*)command
{
    completionCallbackId = [command callbackId];
    completionCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [completionCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)setPitchCallback:(CDVInvokedUrlCommand*)command
{
    newPitchCallbackId = [command callbackId];
    newPitchCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [newPitchCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)setWaveformCallback:(CDVInvokedUrlCommand*)command
{
    newWaveformCallbackId = [command callbackId];
    newWaveformCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [newWaveformCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)setVolumeCallback:(CDVInvokedUrlCommand*)command
{
    newVolumeCallbackId = [command callbackId];
    newVolumeCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [newVolumeCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)setWaveFileCallback:(CDVInvokedUrlCommand*)command
{
    newWaveFileCallbackId = [command callbackId];
    newWaveFileCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [newWaveFileCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)setNewWordsCallback:(CDVInvokedUrlCommand*)command
{
    newWordsCallbackId = [command callbackId];
    newWordsCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [newWordsCallback setKeepCallback:[NSNumber numberWithBool:YES]];
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    startCallbackId = [command callbackId];
    NSString* sentences = [[command arguments] objectAtIndex:0];
    IspikitCordovaPlugin * weakSelf = self;
    [analyzer setNewAudioCallback:^(NSArray* pitch, NSArray* waveformLow, NSArray* waveformHigh, unsigned char volume){
	dispatch_async(dispatch_get_main_queue(), ^{
	    [weakSelf newAudioWithAudio:pitch waveformLow:waveformLow waveformHigh:waveformHigh volume:volume];
	  });
     }];
    [analyzer setResultCallback:^(int score, int speed, NSString* words){
	dispatch_async(dispatch_get_main_queue(), ^{
	    [weakSelf newResultWithResult:score speed:speed words:words];
	  });
     }];
    [analyzer setNewWordsCallback:^(NSString* words){
	dispatch_async(dispatch_get_main_queue(), ^{
	    [weakSelf newWordsWithWords:words];
	  });
     }];
    [analyzer setNewAudioFileCallback:^(NSString* waveFile){
	dispatch_async(dispatch_get_main_queue(), ^{
	    [weakSelf newAudioFileWithFile:waveFile];
	  });
     }];
    [analyzer setCompletionCallback:^(int completion){
	dispatch_async(dispatch_get_main_queue(), ^{
	    [weakSelf completionWithCompletion:completion];
	  });
     }];
     [analyzer setSentences:sentences];
     BOOL output = [analyzer startRecording];
     startCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:output];
     [startCallback setKeepCallback:[NSNumber numberWithBool:YES]];
     [self.commandDelegate sendPluginResult:startCallback callbackId:startCallbackId];
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
  NSString *stopCallbackId = [command callbackId];
  BOOL output = [analyzer stopRecording];
  CDVPluginResult* stopCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:output];
  [self.commandDelegate sendPluginResult:stopCallback callbackId:stopCallbackId];
}

- (void)startPlayback:(CDVInvokedUrlCommand*)command
{
    playbackDoneCallbackId = [command callbackId];
    IspikitCordovaPlugin * weakSelf = self;
    [analyzer setPlaybackDoneCallback:^(){
        [weakSelf performSelectorOnMainThread:@selector(playbackDone:) withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
     }];
     playbackDoneCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     [playbackDoneCallback setKeepCallback:[NSNumber numberWithBool:YES]];
  [analyzer startPlayback];
}

- (void)stopPlayback:(CDVInvokedUrlCommand*)command
{
  [analyzer stopPlayback];
  CDVPluginResult* result = [CDVPluginResult
			      resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
}

- (void)startLoadURL:(CDVInvokedUrlCommand*)command
{
  NSString* audioId = [[command arguments] objectAtIndex:0];
  NSString* audioURL = [[command arguments] objectAtIndex:1];

  if (!([audioURL hasPrefix:@"http://"] || [audioURL hasPrefix:@"https://"]))
    audioURL = [NSString stringWithFormat:@"file://%@/%@", [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"], audioURL];

  if ([audioTable objectForKey:audioId] == nil) {
    [audioTable setObject:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:audioURL]] forKey:audioId];
  }

  if (![audioId isEqualToString:currentAudioItemId]) {
    AVPlayerItem* item = [audioTable objectForKey:audioId]; 
    if (player.currentItem)
      [player replaceCurrentItemWithPlayerItem:item];
    else {
      player = [AVPlayer playerWithPlayerItem:item];
      player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    currentAudioItemId = [NSString stringWithString:audioId];
  }
  CDVPluginResult* result = [CDVPluginResult
			      resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
  playURLDoneCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:playURLDoneCallback callbackId:playURLDoneCallbackId];
}

- (void)startPlay:(CDVInvokedUrlCommand*)command
{
  playURLDoneCallbackId = [command callbackId];
  NSString * audioItemId = [[command arguments] objectAtIndex:0];
  if (![audioItemId isEqualToString:currentAudioItemId]) {
    AVPlayerItem* item = [audioTable objectForKey:audioItemId];
    if (item) {
      if (player.currentItem)
	[player replaceCurrentItemWithPlayerItem:item];
      else {
	player = [AVPlayer playerWithPlayerItem:item];
	player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
      }
    } else {
      CDVPluginResult* result = [CDVPluginResult
				  resultWithStatus:CDVCommandStatus_ERROR];
      [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
      return;
    }
  }
  [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished){
      if (finished)
	[player play];
    }];
}

- (void)stopPlay:(CDVInvokedUrlCommand*)command
{
  [player pause];
  CDVPluginResult* result = [CDVPluginResult
			      resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
}

@end
