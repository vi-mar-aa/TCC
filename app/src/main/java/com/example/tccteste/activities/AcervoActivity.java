package com.example.tccteste.activities;

import android.animation.ValueAnimator;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Spinner;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.tccteste.R;

public class AcervoActivity extends AppCompatActivity {
AppCompatButton btnLivros, btnAudiovisual;
ImageButton btnAnoFiltro, btnGeneroFiltro;

LinearLayout llFiltroGenero;
Spinner llFiltroAno;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_acervo);
        btnLivros = findViewById(R.id.btnLivros);
        btnAnoFiltro= findViewById(R.id.btnAnoFiltro);
        btnAudiovisual = findViewById(R.id.btnAudiovisual);
        btnGeneroFiltro = findViewById(R.id.btnGeneroFiltro);
        btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_down);
        btnGeneroFiltro.setTag("down");
        llFiltroGenero = findViewById(R.id.llFiltroGenero);
        llFiltroAno = findViewById(R.id.llFiltroAno);
        btnLivros.setOnClickListener(v -> {
            btnLivros.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_emprestimo_clicado));
            btnAudiovisual.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_emprestimo_clicavel));
        });

        btnAudiovisual.setOnClickListener(v -> {
            btnAudiovisual.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_emprestimo_clicado));
            btnLivros.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_emprestimo_clicavel));


        });
        btnGeneroFiltro.setOnClickListener(v -> {

            if (!btnGeneroFiltro.getTag().equals("up")) {
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_up);
                btnGeneroFiltro.setTag("up");
                llFiltroGenero.setVisibility(View.VISIBLE);
                llFiltroGenero.measure(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                int alturaFinal = llFiltroGenero.getMeasuredHeight();

                // Começa com altura 0
                ViewGroup.LayoutParams medida = llFiltroGenero.getLayoutParams();
                medida.height = 0;
                llFiltroGenero.setLayoutParams(medida);

                ValueAnimator anim = ValueAnimator.ofInt(0, alturaFinal);
                anim.setDuration(600);

                anim.addUpdateListener(valueAnimator -> {
                    int valorAnimado = (int) valueAnimator.getAnimatedValue();
                    ViewGroup.LayoutParams p = llFiltroGenero.getLayoutParams();
                    p.height = valorAnimado;
                    llFiltroGenero.setLayoutParams(p);
                });

                anim.start();
            }
            else {
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_down);
                btnGeneroFiltro.setTag("down");
                llFiltroGenero.setVisibility(View.GONE);
            }
        });
        btnAnoFiltro.setOnClickListener(v -> {
            btnAnoFiltro.setImageResource(R.drawable.icon_combobox_up);
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}