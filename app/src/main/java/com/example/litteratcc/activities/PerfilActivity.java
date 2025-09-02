package com.example.litteratcc.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class PerfilActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, perfil;
    FrameLayout btnQR;
    PopupWindow popupWindowSubmenu;
    View fundo_escuro, menu_layout,indicador_perfil;
    ApiService apiService;
    TextView tvEmailPerfil, tvUserPerfil;
    LinearLayout btnSalvar;
    EditText edtSenha, edtConfirmaSenha;
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
        indicador_perfil = findViewById(R.id.indicador_perfil);
        indicador_perfil.setVisibility(View.VISIBLE);
        fundo_escuro = findViewById(R.id.background_cinza);
        menu_layout = findViewById(R.id.menu_layout);
        tvEmailPerfil = findViewById(R.id.tvEmailPerfil);
        tvUserPerfil = findViewById(R.id.tvUserPerfil);
        btnSalvar = findViewById(R.id.btnSalvar);
        edtSenha = findViewById(R.id.edtSenha);
        edtConfirmaSenha = findViewById(R.id.edtConfirmaSenha);
        home.setOnClickListener(v -> {
            Intent home = new Intent(PerfilActivity.this, MainActivity.class);
            startActivity(home);
            finish();
        });
        acervo.setOnClickListener(v -> {
            Intent acervo = new Intent(PerfilActivity.this, AcervoActivity.class);
            startActivity(acervo);
            finish();
        });
        btnQR.setOnClickListener(v -> {
            Intent qr = new Intent(PerfilActivity.this, QRCodeActivity.class);
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

                startActivity(new Intent(PerfilActivity.this, EmprestimoActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
                startActivity(new Intent(PerfilActivity.this, ReservaActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
                startActivity(new Intent(PerfilActivity.this, DesejosActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });
        });
        perfil.setOnClickListener(v -> {
            Intent perfil = new Intent(PerfilActivity.this, PerfilActivity.class);
            startActivity(perfil);
            finish();
        });
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl("https://b21b64b2b752.ngrok-free.app/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        apiService = retrofit.create(ApiService.class);
        ClienteSessionManager sessionManager = new ClienteSessionManager(this);

        String nome = sessionManager.getNome();
        String email = sessionManager.getEmail();
        int id = sessionManager.getIdCliente();
        tvUserPerfil.setText(nome);
        tvEmailPerfil.setText(email);
        btnSalvar.setOnClickListener(v -> {
            String senha = edtSenha.getText().toString();
            String confirma = edtConfirmaSenha.getText().toString();

            if (!senha.equals(confirma)) {
                Toast.makeText(PerfilActivity.this, "As senhas não conferem", Toast.LENGTH_SHORT).show();
                return;
            }
            alteraSenha(id, senha);
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
   private void alteraSenha(int idCliente, String novaSenha){
       Cliente cliente = new Cliente();
       cliente.setSenha(novaSenha);
       Call<Cliente> call = apiService.alteraSenha(idCliente, cliente);

       call.enqueue(new Callback<Cliente>() {
           @Override
           public void onResponse(Call<Cliente> call, Response<Cliente> response) {
               if (!response.isSuccessful()) {
                   Toast.makeText(PerfilActivity.this, "Erro ao atualizar: " + response.code(), Toast.LENGTH_SHORT).show();
                   return;
               }
               Toast.makeText(PerfilActivity.this, "Senha atualizada com sucesso!", Toast.LENGTH_SHORT).show();
           }

           @Override
           public void onFailure(Call<Cliente> call, Throwable t) {
               // Handle failure
               Toast.makeText(PerfilActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
           }
       });

   }
}