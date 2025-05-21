package com.example.tccteste.activities;

import android.content.Intent;
import android.os.Bundle;
import android.widget.FrameLayout;
import android.widget.ImageButton;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.tccteste.R;

public class PerfilActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, perfil;
    FrameLayout btnQR;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_perfil);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        perfil = findViewById(R.id.item_perfil);
        home.setOnClickListener(v -> {
            Intent home = new Intent(PerfilActivity.this, MainActivity.class);
            startActivity(home);
        });
        acervo.setOnClickListener(v -> {

        });
        btnQR.setOnClickListener(v -> {
            Intent qr = new Intent(PerfilActivity.this, QRCodeActivity.class);
            startActivity(qr);
        });
        submenu.setOnClickListener(v -> {

        });
        perfil.setOnClickListener(v -> {
            Intent perfil = new Intent(PerfilActivity.this, MainActivity.class);
            startActivity(perfil);
        });
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}