package com.ispikit.library;

import java.io.IOException;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;

public class IspikitWrapper extends CordovaPlugin {

    /////////////////////////////////////////////////////////////
    //
    // Private members
    //
    /////////////////////////////////////////////////////////////
    private String m_BasePath;
    static Handler m_HandlerInit;
    static Handler m_HandlerCompletion;
    static Handler m_HandlerWords;
    static Handler m_HandlerPlaybackDone;
    static Handler m_HandlerResult;
    private static CallbackContext m_InitCallbackContext;
    private static CallbackContext m_PlaybackDoneCallbackContext;
    private static CallbackContext m_WaveformCallbackContext;
    private static CallbackContext m_WaveFileCallbackContext;
    private static CallbackContext m_PitchCallbackContext;
    private static CallbackContext m_VolumeCallbackContext;
    private static CallbackContext m_NewWordsCallbackContext;
    private static CallbackContext m_CompletionCallbackContext;
    private static CallbackContext m_ResultCallbackContext;
    private static final String LOGTAG = "IspikitWrapper";

    private static final String INIT = "init";
    private static final String START = "start";
    private static final String STOP = "stop";
    private static final String SETPITCHCALLBACK = "setPitchCallback";
    private static final String SETWAVEFORMCALLBACK = "setWaveformCallback";
    private static final String SETWAVEFILECALLBACK = "setWaveFileCallback";
    private static final String SETVOLUMECALLBACK = "setVolumeCallback";
    private static final String SETNEWWORDSCALLBACK = "setNewWordsCallback";
    private static final String SETCOMPLETIONCALLBACK = "setCompletionCallback";
    private static final String SETRESULTCALLBACK = "setResultCallback";
    private static final String STARTPLAYBACK = "startPlayback";
    private static final String STOPPLAYBACK = "stopPlayback";

    public static final String RECORD_AUDIO = "android.permission.RECORD_AUDIO";
    public static final int REQUEST_CODE = 0;

    private native boolean Init(String base_path);
    private native boolean StopRecording(boolean force);
    private native boolean StartRecognition();
    //////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////
    //
    // Public members. See README for documentation
    //
    ///////////////////////////////////////////////////////////////

    public native boolean StartPlayback();
    public native boolean StopPlayback();
    public native boolean Shutdown();
    public native boolean SetSentence(String sentences);
    public native boolean AddWord(String word, String pronunciation);

    @Override
    public boolean execute(final String action, final JSONArray data, final CallbackContext callbackContext) {
	Log.d(LOGTAG, "Plugin Called: " + action);
	PluginResult result = null;
	try {
	    if (INIT.equals(action)) {
		m_InitCallbackContext = callbackContext;
		// On recent version of Android, permission
		// must be explicitly given by user.
		// See onRequestPermissionResult below
		if(cordova.hasPermission(RECORD_AUDIO))
		    {
			cordova.getThreadPool().execute(new Runnable() {
				public void run() {
				    Init();
				}
			    });
		    }
		else
		    {
			cordova.requestPermission(this, REQUEST_CODE, RECORD_AUDIO);
		    }
	    } else if (START.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    PluginResult result = null;
			    String sentence = "";
			    try {
				sentence = data.getString(0);
			    } catch (JSONException e) {
				result = new PluginResult(PluginResult.Status.ERROR, "No sentence given");
				callbackContext.sendPluginResult(result);
				return;
			    }
			    if (SetSentence(sentence)) {
				if (Start()) {
				    result = new PluginResult(PluginResult.Status.OK);
				} else {
				    result = new PluginResult(PluginResult.Status.ERROR, "Error when trying to start");
				}	
			    } else {
				result = new PluginResult(PluginResult.Status.ERROR, "Error when setting sentence");
			    }
			    callbackContext.sendPluginResult(result);
			}
		    });				
	    } else if (STOP.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    PluginResult result = null;
			    boolean force = false;
			    try {
				force = (data.getString(0).compareTo("1") == 0);
			    } catch (JSONException e) {
				// Nothing
			    }
			    if (Stop(force)) {
				result = new PluginResult(PluginResult.Status.OK);
			    } else {
				result = new PluginResult(PluginResult.Status.ERROR, "Error when trying to stop");
			    }
			    callbackContext.sendPluginResult(result);
			}
		    });
	    } else if (SETPITCHCALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_PitchCallbackContext = callbackContext;
			}
		    });	
	    } else if (SETWAVEFORMCALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_WaveformCallbackContext = callbackContext;
			}
		    });	
	    } else if (SETWAVEFILECALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_WaveFileCallbackContext = callbackContext;
			}
		    });
	    } else if (SETVOLUMECALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_VolumeCallbackContext = callbackContext;
			}
		    });
	    } else if (SETRESULTCALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_ResultCallbackContext = callbackContext;
			}
		    });	
	    } else if (SETNEWWORDSCALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_NewWordsCallbackContext = callbackContext;
			}
		    });	
	    } else if (SETCOMPLETIONCALLBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_CompletionCallbackContext = callbackContext;
			}
		    });	
	    } else if (STARTPLAYBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    m_PlaybackDoneCallbackContext = callbackContext;
			    StartPlayback();
			}
		    });	
	    } else if (STOPPLAYBACK.equals(action)) {
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    StopPlayback();
			}
		    });
	    } else {
		result = new PluginResult(Status.OK);
	    }
	} catch (Exception ex) {
	    result = new PluginResult(Status.ERROR, ex.toString());
	}

	if(result != null) callbackContext.sendPluginResult( result );
	return true;
    }
    public boolean Start() {
	return StartRecognition();
    }
    public boolean Stop(boolean force) {
	return StopRecording(force);
    }
    public boolean Init() {
	m_BasePath = cordova.getActivity().getApplicationContext().getApplicationInfo().dataDir;
	return Init(m_BasePath);
    }
    public void setInitHandler(Handler h) {
	m_HandlerInit = h;
    }
    public void setResultHandler(Handler h) {
	m_HandlerResult = h;
    }
    public void setCompletionHandler(Handler h) {
	m_HandlerCompletion = h;
    }
    public void setWordsHandler(Handler h) {
	m_HandlerWords = h;
    }
    public void setPlaybackDoneHandler(Handler h) {
	m_HandlerPlaybackDone = h;
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions,
					  int[] grantResults) throws JSONException
    {
	for(int r:grantResults)
	    {
		if(r == PackageManager.PERMISSION_DENIED)
		    {
			m_InitCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Permission Denied"));
			return;
		    }
	    }
	switch(requestCode)
	    {
	    case REQUEST_CODE:
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
			    Init();
			}
		    });
		break;
	    }
    }
    /**************************************************************
     * *
     *  The only thing you might want to modify in this file	
     *  is what is added in the messages for the handlers.
     *  For instance you might want to parse the word string
     *  in onNewResult and wrap it in a container.
     *  
     **************************************************************/
    public static void onNewResult(int score, int speed, String words, String recording) {
	if (m_WaveFileCallbackContext != null) {
	    PluginResult result_recording =  new PluginResult(PluginResult.Status.OK, recording);
	    result_recording.setKeepCallback(true);
	    m_WaveFileCallbackContext.sendPluginResult(result_recording);
	}
	if (m_ResultCallbackContext != null) {
	    JSONArray result_array = new JSONArray();
	    result_array.put(score);
	    result_array.put(speed);
	    result_array.put(words);
	    PluginResult result =  new PluginResult(PluginResult.Status.OK, result_array);
	    result.setKeepCallback(true);
	    m_ResultCallbackContext.sendPluginResult(result);
	}
    }

    public static void onPlaybackDone() {
	if (m_PlaybackDoneCallbackContext != null) {
	    PluginResult result = new PluginResult(PluginResult.Status.OK);
	    result.setKeepCallback(true);
	    m_PlaybackDoneCallbackContext.sendPluginResult(result);
	}
    }

    public static void onNewAudio(String pitch, String waveform, int volume) {
	if (m_WaveformCallbackContext != null) {
	    String[] parts = waveform.split(",");
	    JSONArray wf = null;
	    try {
		 wf = new JSONArray(parts);
	    } catch (JSONException e) {
	    }
	    PluginResult result =  new PluginResult(PluginResult.Status.OK, wf);
	    result.setKeepCallback(true);
	    m_WaveformCallbackContext.sendPluginResult(result);
	}
	if (m_PitchCallbackContext != null) {

	    String[] parts = pitch.split(",");
	    JSONArray p = null;
	    p = new JSONArray();
	    for (int i =0; i < parts.length; i++)
		{
		    p.put(parts[i]);
		}
	    PluginResult result =  new PluginResult(PluginResult.Status.OK, p);
	    result.setKeepCallback(true);
	    m_PitchCallbackContext.sendPluginResult(result);
	}
	if (m_VolumeCallbackContext != null) {
	    PluginResult result =  new PluginResult(PluginResult.Status.OK, volume);
	    result.setKeepCallback(true);
	    m_VolumeCallbackContext.sendPluginResult(result);
	}
    }

    public static void onNewWords(String words) {
	if (m_NewWordsCallbackContext != null) {
	    PluginResult result =  new PluginResult(PluginResult.Status.OK, words);
	    result.setKeepCallback(true);
	    m_NewWordsCallbackContext.sendPluginResult(result);
	}
    }

    public static void onInit(int initStatus) {
	if (m_InitCallbackContext != null) {
	    PluginResult result = null;
	    if (initStatus == 0)
		result = new PluginResult(PluginResult.Status.OK);
	    else
		result = new PluginResult(PluginResult.Status.ERROR);
	    result.setKeepCallback(true);
	    m_InitCallbackContext.sendPluginResult(result);
	}
    }

    public static void onCompletion(int completion) {
	if (m_CompletionCallbackContext != null) {
	    PluginResult result =  new PluginResult(PluginResult.Status.OK, completion);
	    result.setKeepCallback(true);
	    m_CompletionCallbackContext.sendPluginResult(result);
	}
    }

    /****************************************************************
     * *
     * * This is the end of the section you might need to modify.
     * *
     ****************************************************************/
	
    static {
	// This is done because we are putting other files in the libs folder, so
	// the trick of having several libs folder would require us to duplicate those
	// files.
	if (Build.CPU_ABI.compareTo("armeabi-v7a") == 0) {
	    System.loadLibrary("upal-armeabi-v7a");
	} else {
	    System.loadLibrary("upal");
	}
    }
}
