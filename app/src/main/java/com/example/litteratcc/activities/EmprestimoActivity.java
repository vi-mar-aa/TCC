package com.example.litteratcc.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.PopupWindow;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.litteratcc.R;

public class EmprestimoActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, perfil;
    FrameLayout btnQR;
    View fundo_escuro, menu_layout;
    AppCompatButton btnHistorico, btnAtuais;
    PopupWindow popupWindowSubmenu;
    RecyclerView rvEmprestimosAtuais;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_emprestimo);
        btnHistorico = findViewById(R.id.btnHistorico);
        btnAtuais = findViewById(R.id.btnAtuais);
        rvEmprestimosAtuais = findViewById(R.id.rvEmprestimosAtuais);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        perfil = findViewById(R.id.item_perfil);
        menu_layout = findViewById(R.id.menu_layout);
        fundo_escuro = findViewById(R.id.background_cinza);

        btnHistorico.setOnClickListener(v -> {
            btnHistorico.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnAtuais.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
        });
        btnAtuais.setOnClickListener(v -> {
            btnAtuais.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnHistorico.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
        });
        LinearLayoutManager managerEmprestimoAtual = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        rvEmprestimosAtuais.setLayoutManager(managerEmprestimoAtual);
        //rvEmprestimosAtuais.setAdapter(new CarrosselAdapter(midias));
        home.setOnClickListener(v -> {
            Intent home = new Intent(EmprestimoActivity.this, MainActivity.class);
            startActivity(home);
            finish();
        });
        acervo.setOnClickListener(v -> {
            Intent acervo= new Intent(EmprestimoActivity.this, AcervoActivity.class);
            startActivity(acervo);
            finish();
        });
        btnQR.setOnClickListener(v -> {
            Intent qr = new Intent(EmprestimoActivity.this, QRCodeActivity.class);
            startActivity(qr);
            finish();
        });
        submenu.setOnClickListener(v -> {
            if (popupWindowSubmenu != null && popupWindowSubmenu.isShowing()) {
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
                return;
            }
            LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
            View popupView = inflater.inflate(R.layout.caixa_submenu, null);

            popupWindowSubmenu = new PopupWindow(popupView,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    true);
            // Mede o tamanho do layout
            popupView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            int width = popupView.getMeasuredWidth();
            int height = popupView.getMeasuredHeight();

// Pega posição do botão
            int[] coordenadasPop = new int[2];
            submenu.getLocationOnScreen(coordenadasPop);

// Alinha o balão para que a seta fique centralizada no botão submenu
            int popupX = coordenadasPop[0] + submenu.getWidth() / 2 - (int) (width * 0.83); // Ajuste o fator conforme necessário
            int popupY = coordenadasPop[1] - height;

            popupWindowSubmenu.setElevation(10f);
            popupWindowSubmenu.showAtLocation(submenu, Gravity.NO_GRAVITY, popupX, popupY);
            fundo_escuro.setVisibility(View.VISIBLE);
            popupWindowSubmenu.setOnDismissListener(() -> {
                fundo_escuro.setVisibility(View.GONE);
                popupWindowSubmenu = null;
            });

            // Clique em cada item do submenu
            popupView.findViewById(R.id.item_emprestimo).setOnClickListener(view -> {

                startActivity(new Intent(EmprestimoActivity.this, EmprestimoActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
                startActivity(new Intent(EmprestimoActivity.this, ReservaActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
                startActivity(new Intent(EmprestimoActivity.this, DesejosActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });
        });
        perfil.setOnClickListener(v -> {
            Intent perfil = new Intent(EmprestimoActivity.this, PerfilActivity.class);
            startActivity(perfil);
        });
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}