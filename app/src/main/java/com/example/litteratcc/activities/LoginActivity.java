package com.example.litteratcc.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.LoginRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class LoginActivity extends AppCompatActivity {

    private EditText edtEmail, edtSenha;
    private ImageView iconSenha;
    private LinearLayout btnLogin;
    private TextView tvCadastro, tvEsqueceuSenha;
    private ApiService apiService;
    private ClienteSessionManager clienteSessionManager;
    private boolean isPasswordVisible = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);

        initViews();
        initRetrofit();
        setListeners();
    }

    private void initViews() {
        edtEmail = findViewById(R.id.edtEmail);
        edtSenha = findViewById(R.id.edtSenha);
        btnLogin = findViewById(R.id.btnLogin);
        tvCadastro = findViewById(R.id.tvCadastro);
        tvEsqueceuSenha = findViewById(R.id.tvEsqueceuSenha);
        iconSenha = findViewById(R.id.icon_senha);

        clienteSessionManager = new ClienteSessionManager(this);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void initRetrofit() {
        // Cria o interceptor de log
        HttpLoggingInterceptor loggingInterceptor = new HttpLoggingInterceptor();
        loggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY); // loga corpo da requisição e resposta

        // Adiciona o interceptor ao client OkHttp
        OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(loggingInterceptor)
                .build();

        // Cria Retrofit usando esse client
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl("https://b21b64b2b752.ngrok-free.app/") // seu endereço da API
                .client(client)
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        apiService = retrofit.create(ApiService.class);
    }



    private void setListeners() {
        tvCadastro.setOnClickListener(v -> {
            startActivity(new Intent(this, CadastroActivity.class));
            finish();
        });

        tvEsqueceuSenha.setOnClickListener(v ->
                Toast.makeText(this, "Funcionalidade não implementada!", Toast.LENGTH_SHORT).show()
        );

        iconSenha.setOnClickListener(v -> togglePasswordVisibility());

        btnLogin.setOnClickListener(v -> {
            String email = edtEmail.getText().toString().trim();
            String senha = edtSenha.getText().toString().trim();

            if (email.isEmpty() || senha.isEmpty()) {
                Toast.makeText(this, "Preencha todos os campos!", Toast.LENGTH_SHORT).show();
                return;
            }

            login(email, senha);
        });
    }

    private void togglePasswordVisibility() {
        if (isPasswordVisible) {
            edtSenha.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
            iconSenha.setImageResource(R.drawable.icon_closed_eye);
        } else {
            edtSenha.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
            iconSenha.setImageResource(R.drawable.icon_open_eye);
        }
        edtSenha.setSelection(edtSenha.getText().length());
        isPasswordVisible = !isPasswordVisible;
    }

    private void login(String email, String senha) {
        LoginRequest request = new LoginRequest(email, senha);
        Call<String> call = apiService.loginCliente(request);
        call.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(LoginActivity.this, "Login bem-sucedido!", Toast.LENGTH_SHORT).show();
                    clienteSessionManager.salvaCliente(-1, email, "Usuário");
                    startActivity(new Intent(LoginActivity.this, MainActivity.class));
                    finish();
                } else if (response.code() == 404) {
                    Toast.makeText(LoginActivity.this, "E-mail ou senha inválidos", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(LoginActivity.this, "Erro no login: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                Toast.makeText(LoginActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }


}
