package com.example.litteratcc.activities;

import android.os.Bundle;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.example.litteratcc.R;

public class FilmeActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_filme);

        int idMidia = getIntent().getIntExtra("idMidia", -1);
        Log.d("FilmeActivity", "idMidia recebido: " + idMidia);
    }
}
