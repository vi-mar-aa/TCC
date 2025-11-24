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
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.litteratcc.R;
import com.example.litteratcc.adapters.FavoritosAdapter;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.Funcionario;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.modelo.Reserva;
import com.example.litteratcc.request.FavoritoRequest;
import com.example.litteratcc.request.ReservaRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.ArrayList;
import java.util.List;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DesejosActivity extends AppCompatActivity {

    private ImageButton home, acervo, submenu, config;
    private FrameLayout btnQR;
    private View fundo_escuro;
    private PopupWindow popupWindowSubmenu;
    private ApiService apiService;
    private RecyclerView rvDesejo;
    private FavoritosAdapter adapterDesejo;
    List<Integer> listaReservas = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_desejos);
        findViewbyId();

        ClienteSessionManager clienteSessionManager = new ClienteSessionManager(this);
        Cliente cliente = clienteSessionManager.getDadosCliente();

        adapterDesejo = new FavoritosAdapter(DesejosActivity.this,new ArrayList<>(), new FavoritosAdapter.OnItemActionListener() {
            @Override
            public void onItemClick(Midia desejo) {
                abrirPagMidia(desejo);
            }

            @Override
            public void onItemLongClick(Midia desejo) { }//tá configurado no adapter

            @Override
            public void onDeletarClick(Midia desejo) {
                deleteItem(cliente,desejo);
            }

            @Override
            public void onReservarClick(ListaDesejos desejo) {
                reservarMidia(cliente,desejo.getMidia());
                getFavoritos(cliente);
            }
        },listaReservas);
        rvDesejo.setLayoutManager(new GridLayoutManager(this, 2));//como vai aparecer(forma de grade, 2 por linha)
        rvDesejo.setAdapter(adapterDesejo);
        getFavoritos(cliente);
        getCarrosselReservados(cliente);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
    private void findViewbyId() {
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        config = findViewById(R.id.item_config);
        fundo_escuro = findViewById(R.id.background_cinza);
        rvDesejo = findViewById(R.id.rvDesejo);
        apiService = RetrofitManager.getApiService();
        configurarMenu(home, acervo, btnQR, submenu, config);
    }
    private void abrirPagMidia(Midia midia) {
        Intent intent = new Intent(DesejosActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia", midia.getIdMidia());
        startActivity(intent);
    }
    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent atualizarPag = new Intent(DesejosActivity.this, MainActivity.class);
            startActivity(atualizarPag);
        });
        acervo.setOnClickListener(v -> {
            Intent acervoActivity= new Intent(DesejosActivity.this, AcervoActivity.class);
            startActivity(acervoActivity);
        });
        btnQR.setOnClickListener(v -> {
            Intent qrActivity = new Intent(DesejosActivity.this, QRCodeActivity.class);
            startActivity(qrActivity);
        });
        submenu.setOnClickListener(v -> abrirSubmenu());
        config.setOnClickListener(v -> startActivity(new Intent(DesejosActivity.this, ConfiguracoesActivity.class)));
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
            startActivity(new Intent(DesejosActivity.this, EmprestimoActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
            startActivity(new Intent(DesejosActivity.this, ReservaActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
            startActivity(new Intent(DesejosActivity.this, DesejosActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });
    }

    private void getFavoritos(Cliente cliente) {
        apiService.listarDesejosCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ListaDesejos>> call, @NonNull Response<List<ListaDesejos>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<ListaDesejos> desejos = response.body();
                    Log.e("DesejosActivity", "Número de desejos recebidos: " + desejos.size());
                    adapterDesejo.updateList(desejos);
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<ListaDesejos>> call, @NonNull Throwable t) {
                Toast.makeText(DesejosActivity.this, "Erro ao carregar lista de desejos!", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void deleteItem(Cliente cliente, Midia midia){
        Gson gson = new GsonBuilder()
                .serializeNulls()
                .create();
        ListaDesejos lista = new ListaDesejos(cliente.getIdCliente(), midia.getIdMidia());
        FavoritoRequest favorito = new FavoritoRequest(lista, cliente, midia);
        String json = gson.toJson(favorito);
        Log.d("DesejoActivity","Item favorito conteudo:"+json);

        apiService.deletarDesejoCliente(favorito).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<ResponseBody> call, @NonNull Response<ResponseBody> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(DesejosActivity.this, "Desejo removido com sucesso!", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(DesejosActivity.this, "ERROR: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                Toast.makeText(DesejosActivity.this, "ERROR: Falha na conexão: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void reservarMidia(Cliente cliente, Midia midia) {
        Reserva reserva = new Reserva();
        Funcionario funcionario = new Funcionario();
        Emprestimo emprestimo = new Emprestimo();
        Gson gson = new GsonBuilder().serializeNulls().create();
        ReservaRequest reservaRequest = new ReservaRequest(reserva, cliente, midia, funcionario, emprestimo, "", 0);
        String json = gson.toJson(reservaRequest);
        Log.d("DesejosActivity","Reserva desejo: "+ json);

        apiService.reservarMidia(reservaRequest).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<Boolean> call, @NonNull Response<Boolean> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(DesejosActivity.this, "Reserva adicionado!", Toast.LENGTH_SHORT).show();
                    getCarrosselReservados(cliente);
                } else {
                    Toast.makeText(DesejosActivity.this, "Erro ao reservar: " + response.code(), Toast.LENGTH_SHORT).show();
                    Log.e("Reserva_Desejo", "Erro ao reservar: " + response.code());
                }

            }

            @Override

            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Log.e("Reserva_Desejo", "Erro ao reservar: " + t.getMessage());
            }
        });

    }
    private void getCarrosselReservados(Cliente cliente) {
        apiService.listarReservasCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ReservaRequest>> call, @NonNull Response<List<ReservaRequest>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    listaReservas.clear();

                    for (ReservaRequest midia : response.body()) {
                        listaReservas.add(midia.getMidia().getIdMidia());
                    }
                    adapterDesejo.setReservasIds(listaReservas);
                }

            }

            @Override
            public void onFailure(@NonNull Call<List<ReservaRequest>> call, @NonNull Throwable t) {
                Toast.makeText(DesejosActivity.this, "ATENÇÃO: Erro ao carregar reservas!", Toast.LENGTH_SHORT).show();
            }
        });
    }




}