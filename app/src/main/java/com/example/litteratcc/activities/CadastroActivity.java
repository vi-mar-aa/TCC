package com.example.litteratcc.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.CadastroRequest;
import com.example.litteratcc.modelo.LoginRequest;
import com.example.litteratcc.modelo.MessageResponse;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class CadastroActivity extends AppCompatActivity {
    EditText edtEmail, edtUser, edtSenha, edtConfirmaSenha, edtTelefone, edtCPF;
    AppCompatButton btnCadastro;
    ImageView icon_senha, icon_senhaConf;
    ApiService apiService;
    ClienteSessionManager clienteSessionManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_cadastro);

        // findViewById e outras inicializações
        edtEmail = findViewById(R.id.edtEmail);
        edtCPF = findViewById(R.id.edtCPF);
        edtTelefone = findViewById(R.id.edtTelefone);
        edtUser = findViewById(R.id.edtUser);
        edtSenha = findViewById(R.id.edtSenha);
        edtConfirmaSenha = findViewById(R.id.edtConfirmaSenha);
        btnCadastro = findViewById(R.id.btnCadastro);
        icon_senha = findViewById(R.id.icon_senha);
        icon_senhaConf = findViewById(R.id.icon_senhaConf);

        clienteSessionManager = new ClienteSessionManager(this);

        final boolean[] isPasswordVisible = {false};

        icon_senha.setOnClickListener(v -> togglePasswordVisibility(edtSenha, icon_senha, isPasswordVisible));
        icon_senhaConf.setOnClickListener(v -> togglePasswordVisibility(edtConfirmaSenha, icon_senhaConf, isPasswordVisible));

        initRetrofit();
        //testarAPI();
        // Chama o método para inicializar Retrofit aqui

        btnCadastro.setOnClickListener(v -> {
            String email = edtEmail.getText().toString().trim();
            String senha = edtSenha.getText().toString();
            String confirmaSenha = edtConfirmaSenha.getText().toString();
            String user = edtUser.getText().toString().trim();
            String telefone = edtTelefone.getText().toString().trim();
            String cpfTexto = edtCPF.getText().toString().trim();
            long cpf = 0;
            try {
                cpf = Long.parseLong(edtCPF.getText().toString());
            } catch (NumberFormatException e) {
                cpf = 0; // valor padrão temporário
            }

            try {
                cpf = Long.parseLong(cpfTexto);
            } catch (NumberFormatException e) {
                Toast.makeText(this, "CPF inválido", Toast.LENGTH_SHORT).show();
                return;
            }

            CadastroRequest cadastroRequest = new CadastroRequest();
            cadastroRequest.setNome(user);
            cadastroRequest.setCpf(cpf);
            cadastroRequest.setEmail(email);
            cadastroRequest.setSenha(senha);
            cadastroRequest.setTelefone(telefone);
            cadastroRequest.setStatusConta("ativo");

           cadastrarCliente(cadastroRequest);
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    // Método initRetrofit fora do onCreate
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

    private void testarAPI(){
        Call<MessageResponse> call = apiService.getMensagem();
        call.enqueue(new Callback<MessageResponse>() {
            @Override
            public void onResponse(Call<MessageResponse> call, Response<MessageResponse> response) {
                if (response.isSuccessful()) {
                    MessageResponse body = response.body();
                    Log.d("API", body.mensagem);
                    Toast.makeText(CadastroActivity.this, body.mensagem, Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<MessageResponse> call, Throwable t) {
                t.printStackTrace();
            }
        });

    }
    private void cadastrarCliente(CadastroRequest cadastroRequest) {
        Call<String> call = apiService.cadastrarCliente(cadastroRequest);
        call.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(CadastroActivity.this, "Cadastro realizado com sucesso!", Toast.LENGTH_SHORT).show();
                    fazerLoginAutomatico(cadastroRequest.getEmail(), cadastroRequest.getSenha());
                } else {
                    Toast.makeText(CadastroActivity.this, "Erro no cadastro: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                Toast.makeText(CadastroActivity.this, "Erro ao cadastrar: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void fazerLoginAutomatico(String email, String senha) {
        LoginRequest loginRequest = new LoginRequest(email, senha);
        Call<String> call = apiService.loginCliente(loginRequest);
        call.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                if (response.isSuccessful()) {
                    // Login feito, independente da string de retorno, considere sucesso.
                    clienteSessionManager.salvaCliente(-1, email, "Usuário");
                    Toast.makeText(CadastroActivity.this, "Login realizado com sucesso!", Toast.LENGTH_SHORT).show();
                    startActivity(new Intent(CadastroActivity.this, MainActivity.class));
                    finish();
                } else {
                    Toast.makeText(CadastroActivity.this, "Falha ao fazer login automático: " + response.message(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                Toast.makeText(CadastroActivity.this, "Erro no login automático: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
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
}
