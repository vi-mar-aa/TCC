package com.example.litteratcc.activities;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.Spinner;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.example.litteratcc.R;

public class AcervoActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, perfil;
    FrameLayout btnQR;
    AppCompatButton btnLivros, btnAudiovisual;
    ImageButton btnAnoFiltro, btnGeneroFiltro;
    View indicador_acervo, fundo_escuro, menu_layout;
    LinearLayout llFiltroGenero;
    PopupWindow popupWindowSubmenu;
    Spinner llFiltroAno;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_acervo);
        btnLivros = findViewById(R.id.btnLivros);
        btnAnoFiltro = findViewById(R.id.btnAnoFiltro);
        btnAudiovisual = findViewById(R.id.btnAudiovisual);
        btnGeneroFiltro = findViewById(R.id.btnGeneroFiltro);
        btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_down);
        btnGeneroFiltro.setTag("down");
        llFiltroGenero = findViewById(R.id.llFiltroGenero);
       // llFiltroAno = findViewById(R.id.llFiltroAno);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        menu_layout = findViewById(R.id.menu_layout);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        fundo_escuro = findViewById(R.id.background_cinza);
        perfil = findViewById(R.id.item_perfil);
        indicador_acervo = findViewById(R.id.indicador_acervo);
        indicador_acervo.setVisibility(View.VISIBLE);

        btnLivros.setOnClickListener(v -> {
            btnLivros.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnAudiovisual.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
        });
        btnAudiovisual.setOnClickListener(v -> {
            btnAudiovisual.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnLivros.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
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
            } else {
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_down);
                btnGeneroFiltro.setTag("down");
                llFiltroGenero.setVisibility(View.GONE);
            }
        });
        btnAnoFiltro.setOnClickListener(v -> btnAnoFiltro.setImageResource(R.drawable.icon_combobox_up));

        //BOTTOM_MENU
        home.setOnClickListener(v -> {
            Intent home = new Intent(AcervoActivity.this, MainActivity.class);
            startActivity(home);
            finish();
        });
        acervo.setOnClickListener(v -> {
            Intent acervo = new Intent(AcervoActivity.this, AcervoActivity.class);
            startActivity(acervo);
            finish();
        });
        btnQR.setOnClickListener(v -> {
            Intent qr = new Intent(AcervoActivity.this, QRCodeActivity.class);
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
                startActivity(new Intent(AcervoActivity.this, EmprestimoActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
                finish();
            });

            popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
                startActivity(new Intent(AcervoActivity.this, ReservaActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
                finish();
            });

            popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
                startActivity(new Intent(AcervoActivity.this, DesejosActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
                finish();
            });
        });
        perfil.setOnClickListener(v -> {
            Intent perfil = new Intent(AcervoActivity.this, PerfilActivity.class);
            startActivity(perfil);
            finish();
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Substitui o comportamento do botão voltar
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}
