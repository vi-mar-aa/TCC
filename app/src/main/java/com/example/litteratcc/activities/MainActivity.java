package com.example.litteratcc.activities;
import com.example.litteratcc.EspacoItem;
import com.example.litteratcc.R;
import com.example.litteratcc.adapters.MainAdapter;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.Funcionario;
import com.example.litteratcc.modelo.Reserva;
import com.example.litteratcc.request.FavoritoRequest;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.request.ReservaRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class MainActivity extends AppCompatActivity {

    ImageButton home, acervo, submenu, config;
    View fundo_escuro, menu_layout, indicador_home;
    FrameLayout btnQR;
    RecyclerView rvMain;
    PopupWindow popupWindowSubmenu;
    ApiService apiService;
    ClienteSessionManager sessionManager;
    Cliente cliente;
    MainAdapter mainAdapter;
    List<Integer> listaFavoritos = new ArrayList<>();
    List<Integer> listaReservas = new ArrayList<>();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        findViewbyId();

        sessionManager = new ClienteSessionManager(this);
        cliente = sessionManager.getDadosCliente();

        if (cliente == null) {
            Toast.makeText(this, "Para acessar está funcionalidade você deve estar logado!", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        //lista de gêneros fixos para o main adapter
        List<String> generos = Arrays.asList(
                "Romance", "Novela", "Conto", "Fábula", "Fantasia",
                "Ficção Científica", "Distopia", "Utopia", "Terror", "Suspense",
                "Policial", "Aventura", "Biografia", "Diário", "Ensaio",
                "Artigo", "Crônica", "Reportagem", "Revista", "Periódico",
                "Poesia", "Comédia", "Ciência", "Drama", "Outros"
        );

        getCarrosselFavoritados(cliente);
        getCarrosselReservados(cliente);
        rvMain.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        mainAdapter = new MainAdapter(apiService, this, generos, new MainAdapter.OnItemClickListener() {

            @Override
            public void onItemClick(Midia midia) {
                abrirPagMidia(midia);
            }

            @Override
            public void onFavoritarClick(Midia midia) {
                favoritarMidia(cliente, midia);
            }
            @Override
            public void onDesfavoritarClick(Midia midia) {
                desfavoritarMidia(cliente, midia);
            }

            @Override
            public void onReservarClick(Midia midia) {
                reservarMidia(cliente,midia);
            }
            @Override
            public void onItemLongClick(Midia midia) {
                Toast.makeText(MainActivity.this, "Favoritos"+listaFavoritos.size(), Toast.LENGTH_SHORT).show();
                Toast.makeText(MainActivity.this, "RESERVAS"+listaReservas.size(), Toast.LENGTH_SHORT).show();

            }
        },listaFavoritos, listaReservas);        rvMain.setAdapter(mainAdapter);
        int spacingInPixels = getResources().getDimensionPixelSize(R.dimen.item_espaco);
        rvMain.addItemDecoration(new EspacoItem(spacingInPixels));

    }
    public void findViewbyId() {
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        fundo_escuro = findViewById(R.id.background_cinza);
        config = findViewById(R.id.item_config);
        menu_layout = findViewById(R.id.menu_layout);
        indicador_home = findViewById(R.id.indicador_home);
        rvMain = findViewById(R.id.rvMain);
        indicador_home.setVisibility(View.VISIBLE);
        configurarMenu(home, acervo, btnQR, submenu, config);
        apiService = RetrofitManager.getApiService();
    }
    private void abrirPagMidia(Midia midia) {
        Intent intent = new Intent(MainActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia", midia.getIdMidia());
        Log.e("idMidiaAberta",String.valueOf(midia.getIdMidia()));
        startActivity(intent);
    }

    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent atualizarPag = new Intent(MainActivity.this, MainActivity.class);
            startActivity(atualizarPag);

        });
        acervo.setOnClickListener(v -> {
            Intent acervoActivity= new Intent(MainActivity.this, AcervoActivity.class);
            startActivity(acervoActivity);

        });
        btnQR.setOnClickListener(v -> {
            Intent qrActivity = new Intent(MainActivity.this, QRCodeActivity.class);
            startActivity(qrActivity);

        });
        submenu.setOnClickListener(v -> abrirSubmenu());
        config.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, ConfiguracoesActivity.class)));
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
            startActivity(new Intent(MainActivity.this, EmprestimoActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
            startActivity(new Intent(MainActivity.this, ReservaActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
            startActivity(new Intent(MainActivity.this, DesejosActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });
    }
    public void favoritarMidia(Cliente cliente, Midia midia) {

        Gson gson = new GsonBuilder().serializeNulls().create();
        ListaDesejos lista = new ListaDesejos(cliente.getIdCliente(), midia.getIdMidia());
        FavoritoRequest favorito = new FavoritoRequest(lista, cliente, midia);
        String json = gson.toJson(favorito);
        Log.d("favoritar_midia", json);
        apiService.favoritarMidia(favorito).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<Boolean> call, @NonNull Response<Boolean> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(MainActivity.this, "Midia favoritada com sucesso!", Toast.LENGTH_SHORT).show();

                } else {
                    Toast.makeText(MainActivity.this, "ATENÇÃO: Erro ao favoritar!", Toast.LENGTH_SHORT).show();
                }
                getCarrosselFavoritados(cliente);
            }

            @Override
            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Toast.makeText(MainActivity.this, "ATENÇÃO: Erro de conexão!", Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void reservarMidia(Cliente cliente, Midia midia) {

        Reserva reserva = new Reserva();
        Funcionario funcionario = new Funcionario();
        Emprestimo emprestimo = new Emprestimo();
        Gson gson = new GsonBuilder().serializeNulls().create();
        ReservaRequest reservaRequest = new ReservaRequest(reserva, cliente, midia, funcionario, emprestimo, "", 0);
        String json = gson.toJson(reservaRequest);
        Log.d("reserva_midia", json);

        apiService.reservarMidia(reservaRequest).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<Boolean> call, @NonNull Response<Boolean> response) {
                if (response.isSuccessful()) {

                    Toast.makeText(MainActivity.this, "Reserva realizada!", Toast.LENGTH_SHORT).show();


                } else {
                    Toast.makeText(MainActivity.this, "Erro ao reservar!", Toast.LENGTH_SHORT).show();
                }
                getCarrosselReservados(cliente);
            }

            @Override
            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Toast.makeText(MainActivity.this, "Erro de conexão!", Toast.LENGTH_SHORT).show();
            }
        });


    }
    private void desfavoritarMidia(Cliente cliente, Midia midia){
        Gson gson = new GsonBuilder()
                .serializeNulls()
                .create();
        ListaDesejos lista = new ListaDesejos(cliente.getIdCliente(), midia.getIdMidia());
        FavoritoRequest favorito = new FavoritoRequest(lista, cliente, midia);
        String json = gson.toJson(favorito);
        Log.d("MainActivity","Item favorito conteudo:"+json);

        apiService.deletarDesejoCliente(favorito).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<ResponseBody> call, @NonNull Response<ResponseBody> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(MainActivity.this, "Midia desfavoritada com sucesso!", Toast.LENGTH_SHORT).show();


                } else {
                    Toast.makeText(MainActivity.this, "ERROR: " + response.code(), Toast.LENGTH_SHORT).show();
                }
                getCarrosselFavoritados(cliente);
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                Toast.makeText(MainActivity.this, "ERROR: Falha na conexão: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
    // para aparecer nos itens do carrossel
    private void getCarrosselFavoritados(Cliente cliente){

        apiService.listarDesejosCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ListaDesejos>> call, @NonNull Response<List<ListaDesejos>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    listaFavoritos.clear();

                    for (ListaDesejos midia : response.body()) {
                        listaFavoritos.add(midia.getMidia().getIdMidia());
                    }
                    if (mainAdapter != null) {
                        mainAdapter.setFavoritosIds(new ArrayList<>(listaFavoritos));
                    }
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<ListaDesejos>> call, @NonNull Throwable t) {
                Toast.makeText(MainActivity.this, "Erro ao carregar lista de desejos!", Toast.LENGTH_SHORT).show();
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
                    if (mainAdapter != null) {
                        mainAdapter.setReservasIds(new ArrayList<>(listaReservas));
                    }
                }

            }

            @Override
            public void onFailure(@NonNull Call<List<ReservaRequest>> call, @NonNull Throwable t) {
                Toast.makeText(MainActivity.this, "ATENÇÃO: Erro ao carregar reservas!", Toast.LENGTH_SHORT).show();
            }
        });
    }

}
