/************************************************
 * Copyright Ispikit Technologies 2013
 *
 * Interface of ISTAnalyzer, iOS Library for 
 * pronunciation assessment.
 *
 ************************************************/

#import <Foundation/NSString.h>
#import <Block.h>

/*************************************************
 *
 * Most member functions are asynchronous, they
 * call back executing blocks. These are typedefs
 * for the blocks used by ISTAnalyzer.
 *
 ************************************************/

/************************************************
 *
 * Called once initialization is done. It returns
 * the status of initialization. 0 means successful,
 * other values mean error.
 *
 ***********************************************/
typedef void (^InitDoneCallback)(int);

/***********************************************
 *
 * Called once an analysis result is ready. It
 * returns, respectively, the score, the speed
 * and the list of recognized words, with a
 * flag indicating whether they were mispronounced.
 *
 **********************************************/
typedef void (^ResultCallback)(int, int, NSString*);

/************************************************
 *
 * Called once playback is done (ie. the whole
 * recording has been played).
 *
 ***********************************************/
typedef void (^PlaybackDoneCallback)(void);

/***********************************************
 *
 * Called during recording, each time a new word
 * has been recognized. It returns a string representing
 * the recognized words.
 *
 **********************************************/
typedef void (^NewWordsCallback)(NSString*);

/***********************************************
 *
 * Called during recording, each time a new audio
 * buffer has been recorded. It returns a NSArray
 * containing the pitch samples, the low points
 * the high points of the waveform and the volume
 * respectively.
 *
 **********************************************/
typedef void (^NewAudioCallback)(NSArray*, NSArray*, NSArray*, unsigned char);

/***********************************************
 *
 * Called after recording is over, giving the
 * wave file of the audio that was just recorded,
 * encoded in base64.
 *
 **********************************************/
typedef void (^NewAudioFileCallback)(NSString*);

/**********************************************
 *
 * Called during analysis, returns the percentage
 * of completion of the analysis.
 *
 **********************************************/
typedef void (^CompletionCallback)(int);

@interface ISTAnalyzer : NSObject

/*********************************************
 *
 * Starts initialization of all internal structures,
 * should be called on an alloc-ated and init-ed ISTAnalyzer
 * object. This is asynchronous and calls back executing
 * the initDoneCallback block. Returns NO if anything goes
 * wrong when started.
 *
 *********************************************/
- (BOOL) startInitialization;

/*********************************************
*
* Starts recording. It will record and analyze
* assuming sentences are the sentences to be read.
* Returns NO if anything is wrong, for instance
* if the object has not been properly initialized
* or if the sentence is invalid (words missing
* from dictionary). During recording, it calls
* back with newWordsCallback each time a new word
* was recognized.
*
**********************************************/
- (BOOL) startRecording;

/*********************************************
 *
 * Stops recording. If force is false, it starts
 * analyzing the recording and calls back with
 * resultCallback. If force is true, it stops
 * without starting analysis (useful when app is
 * put in background during recording). During 
 * analysis it calls back with completionCallback
 * which gives the current percentage of completion
 * of analysis. Returns NO if not recording, or not
 * analyzed.
 *
 *********************************************/
- (BOOL) stopRecordingWithForce:(BOOL)force;
- (BOOL) setStrictness:(int)strictness;

// Same as stopRecordingWithForce:NO
- (BOOL) stopRecording;

/********************************************
 *
 * Starts playing back the last recorded sentence
 * Calls back with playbackDoneCallback once the
 * whole recording has been played. Returns NO if
 * not initialized or not ready to play back.
 *
 *******************************************/
- (BOOL) startPlayback;

/********************************************
 *
 * Stops playback before it ends. Returns NO
 * if there is anything wrong, such as if it is
 * not playing.
 *
 ********************************************/
- (BOOL) stopPlayback;

/*********************************************
 *
 * Adds words to dictionary at runtime. Pronunciation
 * should be in the CMU dictionary format. Returns NO
 * if the format is not correct or if the object has 
 * not been initialized. Added words don't persist if
 * the object is destroyed. If word already exists, 
 * pronunciation is added to the list of possible
 * valid pronunciations for that word.
 *
 *********************************************/
- (BOOL) addWordWithWord:(NSString *)word pronunciation:(NSString *)pronunciation;

/********************************************************
 *
 * This property should be set to the sentences to be analyzed.
 * It must be set before calling startRecording. Possible sentences
 * are comma-separated
 *
 *******************************************************/
@property NSString *sentences;

/*********************************************************
 *
 * Callback blocks are properties of the ISTAnalyzer class.
 * They can be assigned any block matching the previously
 * described signature.
 *
 ********************************************************/
@property (copy) InitDoneCallback initDoneCallback;
@property (copy) ResultCallback resultCallback;
@property (copy) PlaybackDoneCallback playbackDoneCallback;
@property (copy) NewWordsCallback newWordsCallback;
@property (copy) NewAudioCallback newAudioCallback;
@property (copy) NewAudioFileCallback newAudioFileCallback;
@property (copy) CompletionCallback completionCallback;

@end
