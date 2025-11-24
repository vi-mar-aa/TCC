package com.example.litteratcc.activities;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.util.Patterns;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.LoginRequest;
import com.example.litteratcc.request.EmailRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class LoginActivity extends AppCompatActivity {

    EditText edtEmail, edtSenha;
    ImageView iconSenha;
    LinearLayout btnLogin;
    TextView tvCadastro, tvEsqueceuSenha;
    ApiService apiService;
    ClienteSessionManager clienteSessionManager;

    final boolean[] senhaVisivel = {false};//conteudo muda a array nn

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);
        findViewById();

        tvCadastro.setOnClickListener(v -> startActivity(new Intent(this, CadastroActivity.class)));

        tvEsqueceuSenha.setOnClickListener(v ->
                Toast.makeText(this, "Funcionalidade não implementada!", Toast.LENGTH_SHORT).show()
        );

        iconSenha.setOnClickListener(v -> togglePasswordVisibility(edtSenha, iconSenha, senhaVisivel));

        btnLogin.setOnClickListener(v -> {
            String email = edtEmail.getText().toString().trim();
            String senha = edtSenha.getText().toString().trim();

            if (email.isEmpty() || senha.isEmpty()) {
                Toast.makeText(this, "Preencha todos os campos!", Toast.LENGTH_SHORT).show();

            }
            else if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                Toast.makeText(this, "E-mail inválido!", Toast.LENGTH_SHORT).show();

            }
            logarCliente(email,senha);

        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    public void findViewById() {
        edtEmail = findViewById(R.id.edtEmail);
        edtSenha = findViewById(R.id.edtSenha);
        btnLogin = findViewById(R.id.btnLogin);
        tvCadastro = findViewById(R.id.tvCadastro);
        tvEsqueceuSenha = findViewById(R.id.tvEsqueceuSenha);
        iconSenha = findViewById(R.id.icon_senha);
        clienteSessionManager = new ClienteSessionManager(this);
        apiService = RetrofitManager.getApiService();
    }
    private void togglePasswordVisibility(EditText campo, ImageView icone, boolean[] visivel) {
        if (visivel[0]) {
            campo.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
            icone.setImageResource(R.drawable.icon_closed_eye);
        } else {
            campo.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
            icone.setImageResource(R.drawable.icon_open_eye);
        }
        campo.setSelection(campo.getText().length());
        visivel[0] = !visivel[0];
    }
    private void logarCliente(String email, String senha) {
        LoginRequest loginRequest = new LoginRequest(email, senha);
        Call<String> call = apiService.loginCliente(loginRequest);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful() && response.body() != null) {
                    String retorno = response.body();
                    guardarClienteSession(email);
                    Toast.makeText(LoginActivity.this, retorno, Toast.LENGTH_SHORT).show();
                    Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                    startActivity(intent);
                    finish();
                } else {
                    String errorBody = "";
                    try {
                        errorBody = response.errorBody() != null ? response.errorBody().string() : "Erro desconhecido";
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    Toast.makeText(LoginActivity.this, "Erro API: " + response.code() + " - " + errorBody, Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                Log.e("LOGIN_ERROR", "Falha de rede ou conversão", t);
                Toast.makeText(LoginActivity.this, "Falha: " + t.getClass().getSimpleName() + " - " + t.getMessage(), Toast.LENGTH_LONG).show();
            }

        });
    }

    public void guardarClienteSession(String email) {
        EmailRequest emailCliente = new EmailRequest(email);
        Call<Cliente> call = apiService.getClienteByEmail(emailCliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<Cliente> call, @NonNull Response<Cliente> response) {
                if (response.isSuccessful() && response.body() != null) {
                    Cliente cliente = response.body();

                    clienteSessionManager.salvaCliente(
                            cliente.getIdCliente(),
                            cliente.getEmail(),
                            cliente.getNome(),
                            cliente.getUsername(),
                            cliente.getCpf(),
                            cliente.getFotoPerfil(),
                            cliente.getTelefone()
                    );

                    Log.e("JSON_ARMAZENA_INFO_CLIENTE_VERIFICA", new Gson().toJson(cliente));

                } else {
                    Toast.makeText(LoginActivity.this, "Cliente não encontrado!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Cliente> call, @NonNull Throwable t) {
                Toast.makeText(LoginActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }




}







