package com.example.litteratcc.activities;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.PopupWindow;
import android.widget.Toast;
import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import com.example.litteratcc.R;
import com.example.litteratcc.adapters.EmprestimoAtuaisAdapter;
import com.example.litteratcc.adapters.EmprestimoHistoricoAdapter;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.request.EmprestimoRequest;
import com.example.litteratcc.request.RenovacaoRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class EmprestimoActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, config;
    FrameLayout btnQR;
    View fundo_escuro, menu_layout;
    AppCompatButton btnHistorico, btnAtuais;
    PopupWindow popupWindowSubmenu;
    RecyclerView rvEmprestimosAtuais, rvEmprestimosHistorico;
    ApiService apiService;
    EmprestimoHistoricoAdapter emprestimoHistoricoAdapter;
    EmprestimoAtuaisAdapter emprestimoAtuaisAdapter;
    ClienteSessionManager sessionManager;
    private Cliente cliente;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_emprestimo);

        findViewById();

        sessionManager = new ClienteSessionManager(this);
        cliente = sessionManager.getDadosCliente();
        if (cliente == null) {
            Toast.makeText(this, "Para acessar está funcionalidade você deve estar logado!", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

       emprestimoHistoricoAdapter = new EmprestimoHistoricoAdapter(new ArrayList<>(), EmprestimoActivity.this, this::abrirPagMidia);
        GridLayoutManager glEmprestimoHistorico = new GridLayoutManager(this, 1);
        rvEmprestimosHistorico.setLayoutManager(glEmprestimoHistorico);
        rvEmprestimosHistorico.setAdapter(emprestimoHistoricoAdapter);
        PagerSnapHelper shEmprestimoHistorico = new PagerSnapHelper();
        shEmprestimoHistorico.attachToRecyclerView(rvEmprestimosHistorico);

        btnHistorico.setOnClickListener(v -> {
            btnHistorico.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnAtuais.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
            rvEmprestimosAtuais.setVisibility(View.GONE);
            rvEmprestimosHistorico.setVisibility(View.VISIBLE);
           carregarEmprestimoHistorico(cliente);

        });

        btnAtuais.setOnClickListener(v -> {
            btnAtuais.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnHistorico.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
            rvEmprestimosHistorico.setVisibility(View.GONE);
            rvEmprestimosAtuais.setVisibility(View.VISIBLE);
            carregarEmprestimosAtuais(cliente);
        });
        emprestimoAtuaisAdapter = new EmprestimoAtuaisAdapter(new ArrayList<>(), EmprestimoActivity.this,new EmprestimoAtuaisAdapter.OnItemActionListener(){
            @Override
            public void onItemClick(EmprestimoRequest midia) {
                abrirPagMidia(midia);
            }

          @Override
          public void onItemRenovarClick(EmprestimoRequest midia) {
              Emprestimo emprestimo = midia.getEmprestimo();

              String dtDevolucao = emprestimo.getDtDevolucao();

              try {
                  //como a api devolve
                  SimpleDateFormat formatoApi = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
                  Date dtDevolucaoFormatada = formatoApi.parse(dtDevolucao);

                  Calendar calendar = Calendar.getInstance();//cria calendario com a data atual
                  assert dtDevolucaoFormatada != null;//data formatada nn é nula
                  calendar.setTime(dtDevolucaoFormatada);//
                  calendar.add(Calendar.DAY_OF_MONTH, 7);
                  Date dataSomada = calendar.getTime();//nova data com 7 dias somados
                  Calendar hoje = Calendar.getInstance();

                  if (dataSomada.before(hoje.getTime())) {//ve se a data já passou pra poder renovar e ficar atual
                      hoje.add(Calendar.DAY_OF_MONTH, 7);// o hoje vira a nova data de dev
                      dataSomada = hoje.getTime();
                  }
                  //formato q o banco aceita
                  SimpleDateFormat saida = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
                  String novaDtDevolucao = saida.format(dataSomada);

                  RenovacaoRequest req = new RenovacaoRequest(
                          midia.getMidia(),
                          cliente,
                          emprestimo,
                          midia.getFuncionario(),
                          0, 0, 0,
                          novaDtDevolucao
                  );

                  Gson gson = new GsonBuilder()
                          .serializeNulls()
                          .create();

                  String json = gson.toJson(req);
                  Log.d("Emprestimo_request", json);
                  renovarEmprestimo(req);

              } catch (Exception e) {
                  Log.e("EmprestimoActivity", "Erro ao converter data: " + dtDevolucao, e);
              }
          }


        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        rvEmprestimosAtuais.setLayoutManager(layoutManager);
        rvEmprestimosAtuais.setAdapter(emprestimoAtuaisAdapter);
        carregarEmprestimosAtuais(cliente);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void findViewById() {
        btnHistorico = findViewById(R.id.btnHistorico);
        btnAtuais = findViewById(R.id.btnAtuais);
        rvEmprestimosAtuais = findViewById(R.id.rvEmprestimosAtuais);
        rvEmprestimosHistorico = findViewById(R.id.rvEmprestimosHistorico);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        config = findViewById(R.id.item_config);
        menu_layout = findViewById(R.id.menu_layout);
        fundo_escuro = findViewById(R.id.background_cinza);
        apiService = RetrofitManager.getApiService();
        configurarMenu(home, acervo, btnQR, submenu, config);
        rvEmprestimosHistorico.setVisibility(View.GONE);

    }
    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent atualizarPag = new Intent(EmprestimoActivity.this, MainActivity.class);
            startActivity(atualizarPag);

        });
        acervo.setOnClickListener(v -> {
            Intent acervoActivity= new Intent(EmprestimoActivity.this, AcervoActivity.class);
            startActivity(acervoActivity);

        });
        btnQR.setOnClickListener(v -> {
            Intent qrActivity = new Intent(EmprestimoActivity.this, QRCodeActivity.class);
            startActivity(qrActivity);

        });
        submenu.setOnClickListener(v -> abrirSubmenu());
        config.setOnClickListener(v -> startActivity(new Intent(EmprestimoActivity.this, ConfiguracoesActivity.class)));
    }

    private void abrirSubmenu() {
        if (popupWindowSubmenu != null && popupWindowSubmenu.isShowing()) {
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
            return;
        }

        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        ViewGroup root = findViewById(R.id.main);
        View popupView = inflater.inflate(R.layout.caixa_submenu, root, false);

        popupWindowSubmenu = new PopupWindow(popupView,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                true);

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
    }
    private void abrirPagMidia(EmprestimoRequest midia) {
        Intent intent = new Intent(EmprestimoActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia",midia.getMidia().getIdMidia());
        startActivity(intent);
    }
    private void carregarEmprestimoHistorico(Cliente cliente) {
        Call<List<EmprestimoRequest>> call = apiService.listarHistoricoEmprestimosCliente(cliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<EmprestimoRequest>> call, @NonNull Response<List<EmprestimoRequest>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<EmprestimoRequest> lista = response.body();
                    Log.e("EmprestimoActivity", "Número de emprestimos: " + lista.size());
                    emprestimoHistoricoAdapter.updateList(lista);
                } else {
                    Log.e("EmprestimoActivity", "ERROR: " + response.message());
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<EmprestimoRequest>> call, @NonNull Throwable t) {
                Log.e("EmprestimoActivity", "ERROR: Falha na conexão: " + t.getMessage());
            }
        });
    }
    private void carregarEmprestimosAtuais(Cliente cliente) {
        Call<List<EmprestimoRequest>> call = apiService.listarEmprestimosCliente(cliente);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<EmprestimoRequest>> call, @NonNull Response<List<EmprestimoRequest>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<EmprestimoRequest> lista = response.body();
                    Log.d("RENOVA_REQUEST", new Gson().toJson(lista));
                    Log.e("EmprestimoActivity", "Número de emprestimos: " + lista.size());
                    emprestimoAtuaisAdapter.updateList(lista);
                } else {
                    Log.e("EmprestimoActivity", "ERROR: " + response.message());
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<EmprestimoRequest>> call, @NonNull Throwable t) {
                Log.e("EmprestimoActivity", "ERROR: Falha na conexão: " + t.getMessage());
            }
        });
    }

    private void renovarEmprestimo(RenovacaoRequest midia) {

        Call<String> call = apiService.renovarEmprestimo(midia);

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful() && response.body() != null) {
                    String mensagem = response.body();
                    Toast.makeText(EmprestimoActivity.this, mensagem, Toast.LENGTH_LONG).show();
                    carregarEmprestimosAtuais(cliente);
                } else {
                    Log.e("EmprestimoActivity", "ERROR: " + response.message());
                    Toast.makeText(EmprestimoActivity.this, "ATENÇÃO: Erro ao renovar empréstimo!", Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                Log.e("EmprestimoActivity", "Falha na conexão: " + t.getMessage());
                Toast.makeText(EmprestimoActivity.this, "ERROR: Falha na conexão ao renovar empréstimo!", Toast.LENGTH_LONG).show();
            }
        });
    }


}