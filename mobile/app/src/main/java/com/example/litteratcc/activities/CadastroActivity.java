package com.example.litteratcc.activities;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.util.Patterns;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;
import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.CadastroRequest;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.LoginRequest;
import com.example.litteratcc.request.EmailRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.FormatacaoTextoAutomatica;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class CadastroActivity extends AppCompatActivity {
    EditText edtEmail,edtNome, edtUser, edtSenha, edtConfirmaSenha, edtTelefone, edtCPF;
    AppCompatButton btnCadastro;
    ImageView icon_senha, icon_senhaConf;
    ApiService apiService;
    ClienteSessionManager clienteSessionManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_cadastro);

        findViewById();

        clienteSessionManager = new ClienteSessionManager(this);// pra salvar as infos e usar nas rotas das pags
        final boolean[] senhaVisivel = {false};
        final boolean[] confSenhaVisivel = {true};
        icon_senha.setOnClickListener(v -> togglePasswordVisibility(edtSenha, icon_senha, senhaVisivel));

        icon_senhaConf.setOnClickListener(v -> togglePasswordVisibility(edtConfirmaSenha, icon_senhaConf, confSenhaVisivel));

        edtCPF.addTextChangedListener(new FormatacaoTextoAutomatica(edtCPF, "###.###.###-##"));

        edtTelefone.addTextChangedListener(new TextWatcher() {//pra formatar o telefone enquanto digita
            private boolean statusMudanca = false;//avisa quando o texto está sendo escrito(p/ nn entrar em looping)
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}//nn faz nada, só tá poq o textwathcer pede
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {}//tbm nn faz nada
            @Override
            public void afterTextChanged(Editable telefone) {//aqui começa a formatar
                if (statusMudanca) return;
                statusMudanca = true;

                String digitos = telefone.toString().replaceAll("[^0-9]", "");//tira tudo que nn é num
                String formatacao = digitos.length() > 10 ? "(##) #####-####" : "(##) ####-####";//formatação por quant de digito(cel ou tel fixo)

                StringBuilder out = new StringBuilder();//começa a montar
                int d = 0;
                for (int i = 0; i < formatacao.length(); i++) {
                    char m = formatacao.charAt(i);
                    if (m == '#') {//pega o item e vê se é numero
                        if (d < digitos.length()) {//ve se ainda tem num
                            out.append(digitos.charAt(d++));//coloca o num na string formatada
                        } else break;
                    } else {//se nn for num, coloca o caractere da formatação
                        if (d < digitos.length()) out.append(m); else break;
                    }
                }

                edtTelefone.setText(out.toString());
                edtTelefone.setSelection(out.length());//coloca o cursor no final
                statusMudanca = false;
            }
        });

        btnCadastro.setOnClickListener(v -> {
            CadastroRequest cadastroRequest = verificaCampos();
            Gson gson = new Gson();
            String json = gson.toJson(cadastroRequest);
            Log.e("JSON_CADASTRO_VERIFICA", json);
            cadastrarCliente(cadastroRequest);

        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void findViewById() {
        edtEmail = findViewById(R.id.edtEmail);
        edtCPF = findViewById(R.id.edtCPF);
        edtTelefone = findViewById(R.id.edtTelefone);
        edtUser = findViewById(R.id.edtUser);
        edtNome = findViewById(R.id.edtNome);
        edtSenha = findViewById(R.id.edtSenha);
        edtConfirmaSenha = findViewById(R.id.edtConfirmaSenha);
        btnCadastro = findViewById(R.id.btnCadastro);
        icon_senha = findViewById(R.id.icon_senha);
        icon_senhaConf = findViewById(R.id.icon_senhaConf);
        apiService = RetrofitManager.getApiService();

    }
    //pra mudar a visibilidade dos campos de senha(toggle=alternar)
    private void togglePasswordVisibility(EditText campo, ImageView icone, boolean[] visivel) {
        if (visivel[0]) {
            campo.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);//campo de texto vira campo de senha que esconde(bitwise or
            icone.setImageResource(R.drawable.icon_closed_eye);
        } else {
            campo.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
            icone.setImageResource(R.drawable.icon_open_eye);
        }
        campo.setSelection(campo.getText().length());
        visivel[0] = !visivel[0];//toggle
    }
    private CadastroRequest verificaCampos(){
        String email = edtEmail.getText().toString().trim();
        String senha = edtSenha.getText().toString().trim();
        String confirmaSenha = edtConfirmaSenha.getText().toString().trim();
        String user = edtUser.getText().toString().trim();
        String nome = edtNome.getText().toString().trim();
        String telefone = edtTelefone.getText().toString().trim();
        String cpf = edtCPF.getText().toString().trim();
        if(email.isEmpty()||senha.isEmpty()||confirmaSenha.isEmpty()||user.isEmpty()||nome.isEmpty()||telefone.isEmpty()||cpf.isEmpty()){
            Toast.makeText(this, "ATENÇÃO: Todos os campos devem estar preenchidos!", Toast.LENGTH_SHORT).show();
        }
        else if(!senha.equals(confirmaSenha)){
            Toast.makeText(this, "ATENÇÃO: Senhas não coincidem!", Toast.LENGTH_SHORT).show();
            return null;
        }
        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {//ve se a formatacao do email ta certa
            Toast.makeText(this, "E-mail inválido!", Toast.LENGTH_SHORT).show();
            return null;
        }
        return new CadastroRequest(nome, user, cpf, email, senha, telefone, "ativo");
    }

    private void cadastrarCliente(CadastroRequest cadastroRequest) {
        Call<String> call = apiService.cadastrarCliente(cadastroRequest);
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(CadastroActivity.this, "Cadastro realizado com sucesso!", Toast.LENGTH_SHORT).show();
                    Intent pagLogin = new Intent(CadastroActivity.this, LoginActivity.class);
                    startActivity(pagLogin);
                    finish();
                    fazerLoginAutomatico(cadastroRequest.getEmail(), cadastroRequest.getSenha());
                } else {
                    Toast.makeText(CadastroActivity.this, "Erro no cadastro: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                Toast.makeText(CadastroActivity.this, "Erro ao cadastrar: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void fazerLoginAutomatico(String email, String senha) {
        LoginRequest loginRequest = new LoginRequest(email, senha);
        Call<String> call = apiService.loginCliente(loginRequest);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful() && response.body() != null) {
                    String retorno = response.body();
                    guardarClienteSession(email);

                    Toast.makeText(CadastroActivity.this, retorno, Toast.LENGTH_SHORT).show();
                    Intent intent = new Intent(CadastroActivity.this, MainActivity.class);
                    startActivity(intent);
                    finish();//coloca se quiser q o user nn volte
                } else {
                    String errorBody = "";
                    try {//se o erro nn for nulo, pega a msg
                        errorBody = response.errorBody() != null ? response.errorBody().string() : "Erro desconhecido";
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    Toast.makeText(CadastroActivity.this, "Erro API: " + response.code() + " - " + errorBody, Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                Toast.makeText(CadastroActivity.this, "Falha de rede: " + t.getMessage(), Toast.LENGTH_LONG).show();
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
                    Toast.makeText(CadastroActivity.this, "Cliente não encontrado!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Cliente> call, @NonNull Throwable t) {
                Toast.makeText(CadastroActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    //TESTE A API
    /*private void testarAPI(){
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

    }*/



}
