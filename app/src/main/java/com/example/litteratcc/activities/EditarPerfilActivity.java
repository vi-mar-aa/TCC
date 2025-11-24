package com.example.litteratcc.activities;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.request.EmailRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.FormatacaoTextoAutomatica;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.ByteArrayOutputStream;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class EditarPerfilActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, config, ibUploadFoto;
    FrameLayout btnQR;
    LinearLayout btnSalvar, btnExcluirConta;
    PopupWindow popupWindowSubmenu;
    View fundo_escuro, menu_layout, indicador_config;
    ApiService apiService;
    ClienteSessionManager sessionManager;
    Cliente cliente;
    TextView tvEmailPerfil, tvUserPerfil;
    EditText edtUsername, edtTelefone, edtNovaSenha, edtConfirmaNovaSenha;
    ImageView imgUser;
    ActivityResultLauncher<Intent> resultLauncher;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_editar_perfil);

        findViewById();
        sessionManager = new ClienteSessionManager(this);
        cliente = sessionManager.getDadosCliente();
        Gson gson = new GsonBuilder()
                .serializeNulls()
                .create();
        String json = gson.toJson(cliente);
        Log.d("cliente_info_config",json);

        if (cliente == null) {
            Toast.makeText(this, "Para acessar está funcionalidade você deve estar logado!", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        carregarImagemDoCliente(cliente.getIdCliente());
        carregarInfo(cliente);

        ibUploadFoto.setOnClickListener(v -> abrirGaleria());

        btnSalvar.setOnClickListener(v -> {

            String telefone = edtTelefone.getText().toString().trim();
            String username = edtUsername.getText().toString().trim();
            String senha = edtNovaSenha.getText().toString().trim();
            String confirmaSenha = edtConfirmaNovaSenha.getText().toString().trim();
            Drawable drawable = imgUser.getDrawable();

            Cliente req = new Cliente();
            req.setIdCliente(cliente.getIdCliente());
            req.setEmail(cliente.getEmail());
            req.setNome(cliente.getNome());
            req.setCpf(cliente.getCpf());
            req.setFotoPerfil(cliente.getFotoPerfil());
            req.setUsername(cliente.getUsername());
            req.setTelefone(cliente.getTelefone());
            String enviadoJson = gson.toJson(req);
            Log.e("salvar_edicao_cliente", enviadoJson);

           //ve oq vai ser alterado
            if (!username.isEmpty()) {
                req.setUsername(username);
            }
            else if (!telefone.isEmpty()) {
                req.setTelefone(telefone);
            }
            else if (!senha.isEmpty() || !confirmaSenha.isEmpty()) {
                if (!senha.equals(confirmaSenha)) {
                    Toast.makeText(this, "ATENÇÃO:As senhas não coincidem!", Toast.LENGTH_SHORT).show();
                    return;
                }
                req.setSenha(senha);
            }
            else if (drawable instanceof BitmapDrawable) {//se for tipo bitmap
                Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
                String base64 = convertImagemPerfil(bitmap);//apisó deixa base64

                if (base64 != null && !base64.isEmpty()) {
                    req.setFotoPerfil(base64);
                }
            }

            atualizaCliente(req);
        });


        btnExcluirConta.setOnClickListener(v -> {
            LayoutInflater inflater = LayoutInflater.from(EditarPerfilActivity.this);
            View popupView = inflater.inflate(R.layout.popup_confirma_delete_conta, null);

            AlertDialog.Builder builder = new AlertDialog.Builder(EditarPerfilActivity.this);
            builder.setView(popupView);
            AlertDialog dialog = builder.create();
            dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
            dialog.show();
            LinearLayout btnCancelar = popupView.findViewById(R.id.btnCancelar);
            btnCancelar.setOnClickListener(x ->dialog.dismiss());
            LinearLayout btnConfirmar = popupView.findViewById(R.id.btnConfirmar);

            btnConfirmar.setOnClickListener(x -> {
                sessionManager.limpaCliente();
                excluirConta(cliente);
                String json1 = gson.toJson(cliente);
                Log.d("delete_cliente", json1);
            });

        });
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void findViewById() {
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        config = findViewById(R.id.item_config);
        ibUploadFoto = findViewById(R.id.ibUploadFoto);
        indicador_config = findViewById(R.id.indicador_config);
        indicador_config.setVisibility(View.VISIBLE);
        btnSalvar = findViewById(R.id.btnSalvar);
        btnExcluirConta = findViewById(R.id.btnExcluirConta);
        edtNovaSenha = findViewById(R.id.edtNovaSenha);
        edtConfirmaNovaSenha = findViewById(R.id.edtConfirmaNovaSenha);
        edtUsername = findViewById(R.id.edtUsername);
        edtTelefone = findViewById(R.id.edtTelefone);
        fundo_escuro = findViewById(R.id.background_cinza);
        menu_layout = findViewById(R.id.menu_layout);
        imgUser = findViewById(R.id.imgUser);
        tvUserPerfil = findViewById(R.id.tvUsername);
        tvEmailPerfil = findViewById(R.id.tvEmail);
        apiService = RetrofitManager.getApiService();
        configurarMenu(home, acervo, btnQR, submenu, config);

        resultLauncher = registerForActivityResult(//resultLauncher = ferramenta p/ guardar a ação de abrir galeria
                new ActivityResultContracts.StartActivityForResult(),//abre e pega o resultado
                result -> {
                    if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {//se pegou a img certinho
                        Uri imageUri = result.getData().getData();//só o caminho da img
                        if (imageUri != null) {
                            getContentResolver().takePersistableUriPermission(//mantem a permissão de usar a img mesmo com o app fechado
                                    imageUri,
                                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                            );

                            imgUser.setImageURI(imageUri);
                        }
                    }
                }
        );

    }
    private void carregarInfo(Cliente cliente) {
        tvUserPerfil.setText(cliente.getUsername());
        tvEmailPerfil.setText(cliente.getEmail());
        edtUsername.setText(cliente.getUsername());
        edtTelefone.addTextChangedListener(new FormatacaoTextoAutomatica(edtTelefone, "(##) #####-####"));//só pra verificar o formato
        edtTelefone.setText(cliente.getTelefone());
    }

    private void atualizaCliente(Cliente clienteEditado) {

        Call<String> call = apiService.alterarInfosClienteTeste(clienteEditado);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(EditarPerfilActivity.this, "Perfil atualizado com Sucesso!", Toast.LENGTH_SHORT).show();
                    getClienteEditado(clienteEditado.getEmail());

                } else {
                    Toast.makeText(EditarPerfilActivity.this, "ATENÇÃO:Erro ao atualizar o perfil!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                Toast.makeText(EditarPerfilActivity.this, "Falha: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void getClienteEditado(String email) {
        EmailRequest emailCliente = new EmailRequest(email);
        Call<Cliente> call = apiService.getClienteByEmail(emailCliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<Cliente> call, @NonNull Response<Cliente> response) {
                if (response.isSuccessful() && response.body() != null) {
                    Cliente clienteAtualizado = response.body();
                    sessionManager.limpaCliente();
                    sessionManager.salvaCliente(clienteAtualizado.getIdCliente(),
                            clienteAtualizado.getEmail(),
                            clienteAtualizado.getNome(),
                            clienteAtualizado.getUsername(),
                            clienteAtualizado.getCpf(),
                            clienteAtualizado.getFotoPerfil(),
                            clienteAtualizado.getTelefone());

                    carregarImagemDoCliente(clienteAtualizado.getIdCliente());
                    carregarInfo(clienteAtualizado);

                    Log.e("clienteEditado_verifica", new Gson().toJson(clienteAtualizado));


                } else {
                    Toast.makeText(EditarPerfilActivity.this, "ATENÇÃO: Cliente não encontrado!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Cliente> call, @NonNull Throwable t) {
                Toast.makeText(EditarPerfilActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void excluirConta(Cliente cliente) {
        Call<String> call = apiService.inativarConta(cliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(EditarPerfilActivity.this, response.body(), Toast.LENGTH_SHORT).show();
                    sessionManager.limpaCliente();
                    Intent intent = new Intent(EditarPerfilActivity.this, LoginActivity.class);
                    startActivity(intent);
                    finish();
                } else {
                    Toast.makeText(EditarPerfilActivity.this, "ERROR: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                Toast.makeText(EditarPerfilActivity.this, "Falha: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent homePag = new Intent(EditarPerfilActivity.this, MainActivity.class);
            startActivity(homePag);
        });
        acervo.setOnClickListener(v -> {
            Intent acervoPag = new Intent(EditarPerfilActivity.this, AcervoActivity.class);
            startActivity(acervoPag);
        });
        btnQR.setOnClickListener(v -> {
            Intent qrPag = new Intent(EditarPerfilActivity.this, QRCodeActivity.class);
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
            // Mede o tamanho do layout
            popupView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            int width = popupView.getMeasuredWidth();
            int height = popupView.getMeasuredHeight();

            int[] coordenadasPop = new int[2];
            submenu.getLocationOnScreen(coordenadasPop);

            int popupX = coordenadasPop[0] + submenu.getWidth() / 2 - (int) (width * 0.83);
            int popupY = coordenadasPop[1] - height;

            popupWindowSubmenu.setElevation(10f);
            popupWindowSubmenu.showAtLocation(submenu, Gravity.NO_GRAVITY, popupX, popupY);
            fundo_escuro.setVisibility(View.VISIBLE);
            popupWindowSubmenu.setOnDismissListener(() -> {
                fundo_escuro.setVisibility(View.GONE);
                popupWindowSubmenu = null;
            });

            popupView.findViewById(R.id.item_emprestimo).setOnClickListener(view -> {

                startActivity(new Intent(EditarPerfilActivity.this, EmprestimoActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
                startActivity(new Intent(EditarPerfilActivity.this, ReservaActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });

            popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
                startActivity(new Intent(EditarPerfilActivity.this, DesejosActivity.class));
                popupWindowSubmenu.dismiss();
                fundo_escuro.setVisibility(View.GONE);
            });
        });
        config.setOnClickListener(v -> {
            Intent configPag = new Intent(EditarPerfilActivity.this, ConfiguracoesActivity.class);
            startActivity(configPag);
        });
    }

    private void abrirGaleria() {
        Intent escolhaFoto = new Intent(Intent.ACTION_OPEN_DOCUMENT);//user abre doc
        escolhaFoto.addCategory(Intent.CATEGORY_OPENABLE);//nn pode ser pasta
        escolhaFoto.setType("image/*");//só imagem
        escolhaFoto.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);//deixar ler e guardar mesmo fechando app
        resultLauncher.launch(escolhaFoto);
    }
    private String convertImagemPerfil(Bitmap bitmap) {
        Bitmap resized = Bitmap.createScaledBitmap(bitmap, 300, 300, true);//coloca em outro formato mais leve
        ByteArrayOutputStream imgByte = new ByteArrayOutputStream();//obj que guarda a imagem em byte
        resized.compress(Bitmap.CompressFormat.JPEG, 80, imgByte);

        byte[] byteArray = imgByte.toByteArray();
        return Base64.encodeToString(byteArray, Base64.DEFAULT);
    }
    private void carregarImagemDoCliente(int idCliente) {
        Call<ResponseBody> call = apiService.getImagemCliente(idCliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<ResponseBody> call, @NonNull Response<ResponseBody> response) {
                if (response.isSuccessful() && response.body() != null) {
                    try {
                        byte[] bytes = response.body().bytes();
                        Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);//transforma byte em array
                        imgUser.setImageBitmap(bitmap);//carrega img

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    Glide.with(EditarPerfilActivity.this)
                            .load(R.drawable.img_perfil)
                            .into(imgUser);
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                Glide.with(EditarPerfilActivity.this)
                        .load(R.drawable.img_perfil)
                        .into(imgUser);
            }
        });
    }



}
