package com.example.tccteste.activities;
import com.example.tccteste.R;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowMetrics;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SnapHelper;

import com.example.tccteste.R;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {
ImageButton home, acervo, submenu, perfil, btnNotificacao;
LinearLayout cx_submenu;
View fundo_escuro, menu_layout;
RecyclerView rvPopLivros;


FrameLayout btnQR;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        fundo_escuro = findViewById(R.id.dim_background);
        perfil = findViewById(R.id.item_perfil);
        menu_layout = findViewById(R.id.menu_layout);
        rvPopLivros = findViewById(R.id.rvPopLivros);
        rvPopLivros.setLayoutManager(
                new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        );

        btnNotificacao = findViewById(R.id.btnNotificacao);
        home.setOnClickListener(v -> {
            Intent home = new Intent(MainActivity.this, MainActivity.class);
            startActivity(home);
            finish();
        });
        acervo.setOnClickListener(v -> {
            Intent acervo= new Intent(MainActivity.this, AcervoActivity.class);
            startActivity(acervo);
            finish();
        });
        btnQR.setOnClickListener(v -> {
            Intent qr = new Intent(MainActivity.this, QRCodeActivity.class);
            startActivity(qr);
            finish();
        });
        submenu.setOnClickListener(v -> {
            LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
            View popupView = inflater.inflate(R.layout.caixa_submenu, null);
            int width = LinearLayout.LayoutParams.WRAP_CONTENT;
            int height = LinearLayout.LayoutParams.WRAP_CONTENT;
            boolean focusable = true;
            final PopupWindow popupWindow = new PopupWindow(popupView, width, height, focusable);
            int[] coordenadas = new int[2];
           btnQR.getLocationOnScreen(coordenadas);

            int popupX = coordenadas[0] + submenu.getWidth() - popupWindow.getWidth();
            int popupY = coordenadas[1] + menu_layout.getHeight() - popupWindow.getHeight();

            popupWindow.showAtLocation(submenu, Gravity.NO_GRAVITY, popupX, popupY);

            // Clique em cada item do submenu
            popupView.findViewById(R.id.item_emprestimo).setOnClickListener(view -> {
                startActivity(new Intent(MainActivity.this, EmprestimoActivity.class));
                popupWindow.dismiss();
            });

            popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
                startActivity(new Intent(MainActivity.this, ReservaActivity.class));
                popupWindow.dismiss();
            });

            popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
                startActivity(new Intent(MainActivity.this, DesejosActivity.class));
                popupWindow.dismiss();
            });
        });

        perfil.setOnClickListener(v -> {
            Intent perfil = new Intent(MainActivity.this, PerfilActivity.class);
            startActivity(perfil);
        });
        btnNotificacao.setOnClickListener(
                v -> {
                    Intent notificacao = new Intent(MainActivity.this, NotificacaoActivity.class);
                    startActivity(notificacao);
                }
        );

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}