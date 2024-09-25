package com.example.my_call;

import android.app.Service;
import android.content.Intent;
import android.media.MediaRecorder;
import android.os.Environment;
import android.os.IBinder;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import java.io.File;
import java.io.IOException;

public class CallRecordingService extends Service {
    private MediaRecorder recorder;
    private boolean isRecording = false;
    private File recordingFile;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        TelephonyManager telephonyManager = (TelephonyManager) getSystemService(TELEPHONY_SERVICE);
        telephonyManager.listen(new PhoneStateListener() {
            @Override
            public void onCallStateChanged(int state, String incomingNumber) {
                if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
                    startRecording();
                } else if (state == TelephonyManager.CALL_STATE_IDLE && isRecording) {
                    stopRecording();
                }
            }
        }, PhoneStateListener.LISTEN_CALL_STATE);
        return START_NOT_STICKY;
    }

    private void startRecording() {
        String fileName = "call_recording_" + System.currentTimeMillis() + ".3gp";
        recordingFile = new File(getExternalFilesDir(null), fileName);

        recorder = new MediaRecorder();
        recorder.setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION);
        recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
        recorder.setOutputFile(recordingFile.getAbsolutePath());

        try {
            recorder.prepare();
            recorder.start();
            isRecording = true;
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void stopRecording() {
        if (isRecording) {
            recorder.stop();
            recorder.release();
            isRecording = false;
        }
    }
}
