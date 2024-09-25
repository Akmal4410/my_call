package com.example.my_call;

import android.content.Intent;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = new Intent(this, CallRecordingService.class);
        startService(intent);
    }
}
