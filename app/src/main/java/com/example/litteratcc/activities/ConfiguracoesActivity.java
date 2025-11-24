package com.example.litteratcc.activities;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.bumptech.glide.Glide;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ConfiguracoesActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, config, ibEditarPerfil;
    FrameLayout btnQR;
    PopupWindow popupWindowSubmenu;
    View fundo_escuro, menu_layout,indicador_config;
    ApiService apiService;
    ClienteSessionManager sessionManager;
    Cliente cliente;
    TextView tvUsername, tvEmail;
    LinearLayout llEditarPerfil, llContraste, llFavoritos, llEmprestimo, llLogout;
    ImageView ivModoDesign, imgUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_configuracoes);

        findViewById();

        sessionManager = new ClienteSessionManager(this);
        cliente = sessionManager.getDadosCliente();

        Gson gson = new GsonBuilder()
                .serializeNulls() // força incluir campos nulos, pra api aceitar o json
                .create();
        String json = gson.toJson(cliente);
        Log.d("cliente_info_config",json);

        if (cliente == null) {
            Toast.makeText(this, "Para acessar está funcionalidade você deve estar logado!", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }


        SharedPreferences contraste = getSharedPreferences("modo_design", MODE_PRIVATE);//cria tp um json que guarda se tá claro ou escuro
        atualizarIconeModo();

        carregarImagemDoCliente(cliente.getIdCliente());
        tvUsername.setText(cliente.getUsername());
        tvEmail.setText(cliente.getEmail());

        ibEditarPerfil.setOnClickListener(v -> {
            Intent pagEditar = new Intent(ConfiguracoesActivity.this, EditarPerfilActivity.class);
            startActivity(pagEditar);
        });

        llEditarPerfil.setOnClickListener(v -> {
            Intent pagEditar = new Intent(ConfiguracoesActivity.this, EditarPerfilActivity.class);
            startActivity(pagEditar);
        });

        llContraste.setOnClickListener(v -> {
            boolean modoEscuro = contraste.getBoolean("modo_escuro", false);//se nn tiver é falso

            if (modoEscuro) {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
                contraste.edit().putBoolean("modo_escuro", false).apply();
            } else {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                contraste.edit().putBoolean("modo_escuro", true).apply();
            }

            recreate();//recria tudo
        });

        llFavoritos.setOnClickListener(v -> {
            Intent pagFavoritos = new Intent(ConfiguracoesActivity.this, DesejosActivity.class);
            startActivity(pagFavoritos);
        });

        llEmprestimo.setOnClickListener(v -> {
            Intent pagEmrpestimo = new Intent(ConfiguracoesActivity.this, EmprestimoActivity.class);
            startActivity(pagEmrpestimo);
        });

        llLogout.setOnClickListener(v -> {
            LayoutInflater inflater = LayoutInflater.from(ConfiguracoesActivity.this);//transforma xml em obj
            View popupView = inflater.inflate(R.layout.popup_confirma_logout, null);//fala qual é o obj

            AlertDialog.Builder builder = new AlertDialog.Builder(ConfiguracoesActivity.this);//poe o xml na cx pro user interagir
            builder.setView(popupView);
            AlertDialog dialog = builder.create();//cria a cx
            dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
            dialog.show();//mostra a cx
            LinearLayout btnCancelar = popupView.findViewById(R.id.btnCancelar);
            btnCancelar.setOnClickListener(x ->dialog.dismiss());//fecha
            LinearLayout btnConfirmar = popupView.findViewById(R.id.btnConfirmar);
            btnConfirmar.setOnClickListener(x -> {

                sessionManager.limpaCliente();
                Intent pagLogin = new Intent(ConfiguracoesActivity.this, LoginActivity.class);
                startActivity(pagLogin);
                finish();
                String json1 = gson.toJson(cliente);
                Log.d("logout_cliente", json1);
            });
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    public void findViewById() {

        imgUser = findViewById(R.id.imgUser);
        tvUsername = findViewById(R.id.tvUsername);
        tvEmail = findViewById(R.id.tvEmail);
        ibEditarPerfil = findViewById(R.id.ibEditarPerfil);
        llEditarPerfil = findViewById(R.id.llEditarPerfil);
        llContraste = findViewById(R.id.llContraste);
        llFavoritos = findViewById(R.id.llFavoritos);
        llEmprestimo = findViewById(R.id.llEmprestimo);
        llContraste = findViewById(R.id.llContraste);
        llLogout = findViewById(R.id.llLogout);
        fundo_escuro = findViewById(R.id.background_cinza);
        ivModoDesign = findViewById(R.id.ivModoDesign);
        menu_layout = findViewById(R.id.menu_layout);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        config = findViewById(R.id.item_config);
        indicador_config = findViewById(R.id.indicador_config);
        indicador_config.setVisibility(View.VISIBLE);
        apiService = RetrofitManager.getApiService();
        configurarMenu(home, acervo, btnQR, submenu, config);
    }
    private void atualizarIconeModo() {
        SharedPreferences contraste = getSharedPreferences("modo_design", MODE_PRIVATE);
        boolean modoEscuroAtual = contraste.getBoolean("modo_escuro", false);
        if (modoEscuroAtual) {
            ivModoDesign.setImageDrawable(getDrawable(R.drawable.icon_dark_mode));
        } else {
            ivModoDesign.setImageDrawable(getDrawable(R.drawable.icon_light_mode));
        }
    }
    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent homePag = new Intent(ConfiguracoesActivity.this, MainActivity.class);
            startActivity(homePag);

        });

        acervo.setOnClickListener(v -> {
            Intent acervoPag = new Intent(ConfiguracoesActivity.this, AcervoActivity.class);
            startActivity(acervoPag);

        });

        btnQR.setOnClickListener(v -> {
            Intent qrPag = new Intent(ConfiguracoesActivity.this, QRCodeActivity.class);
            startActivity(qrPag);

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

            popupView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            int width = popupView.getMeasuredWidth();
            int height = popupView.getMeasuredHeight();


            int[] coordenadasPop = new int[2];
            submenu.getLocationOnScreen(coordenadasPop);


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

                startActivity(new Intent(ConfiguracoesActivity.this, EmprestimoActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
                startActivity(new Intent(ConfiguracoesActivity.this, ReservaActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
                startActivity(new Intent(ConfiguracoesActivity.this, DesejosActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });
        });
        config.setOnClickListener(v -> {
            Intent configPag = new Intent(ConfiguracoesActivity.this, ConfiguracoesActivity.class);
            startActivity(configPag);
            finish();
        });
    }
    private void carregarImagemDoCliente(int idCliente) {
        Call<ResponseBody> call = apiService.getImagemCliente(idCliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<ResponseBody> call, @NonNull Response<ResponseBody> response) {
                if (response.isSuccessful() && response.body() != null) {
                    try {
                        byte[] bytes = response.body().bytes();
                        Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                        //android entende bitmap
                        imgUser.setImageBitmap(bitmap);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    //glide é biblioteca
                    Glide.with(ConfiguracoesActivity.this)
                            .load(R.drawable.img_perfil)
                            .into(imgUser);
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                Glide.with(ConfiguracoesActivity.this)
                        .load(R.drawable.img_perfil)
                        .into(imgUser);
            }
        });
    }

}