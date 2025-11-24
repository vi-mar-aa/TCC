package com.example.litteratcc.activities;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.litteratcc.EspacoItem;
import com.example.litteratcc.R;
import com.example.litteratcc.adapters.CarrosselMainAdapter;
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
import com.example.litteratcc.request.MidiaRequest;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.ArrayList;
import java.util.List;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class MidiaActivity extends AppCompatActivity {

    TextView tvNumExemplares, tvTitulo, tvAutor, tvAno, tvEditora, tvIsbn, tvGenero, tvEdicao, tvSinopse, tvDuracao, tvEstudio, tvRoteirista;
    RecyclerView rvMidiasSimilares;
    LinearLayout llTitulo, llAutor, llAno, llEditora, llIsbn, llGenero, llEdicao, llDuracao, llEstudio, llRoteirista, btnReservar;
    ImageView imgItem, iconReserva;
    ImageButton btnVoltar, btnFavoritar;
    CarrosselMainAdapter carrosselMainAdapter;
    ClienteSessionManager sessionManager;
    Cliente cliente;
    ApiService apiService;
    private Midia midiaCarregada;

    //para a midia carregada
    private boolean favoritagemStatus = false;
    private boolean reservaStatus = false;

    // para as midias do carrossel
    List<Integer> listaFavoritos = new ArrayList<>();
    List<Integer> listaReservas = new ArrayList<>();



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_midia);

        findViewbyId();

        sessionManager = new ClienteSessionManager(this);
        cliente = sessionManager.getDadosCliente();
        if (cliente == null) {
            Toast.makeText(this, "Para acessar está funcionalidade você deve estar logado!", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        int idMidia = getIntent().getIntExtra("idMidia", -1);
        if (idMidia == -1) {
            Toast.makeText(this, "ID da mídia inválido!", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        carrosselMainAdapter = new CarrosselMainAdapter(new ArrayList<>(),MidiaActivity.this, new CarrosselMainAdapter.OnItemActionListener() {
            @Override
            public void onItemClick(Midia midia) {
                abrirPagMidia(midia); }

            @Override
            public void onItemLongClick(Midia midia) {

            }

            @Override
            public void onFavoritarClick(Midia midia) {
                favoritarMidia(cliente,midia);
                getListaMidiasSimilares(midiaCarregada.getIdMidia());
            }
            @Override
            public void onDesfavoritarClick(Midia midia) {
                desfavoritarMidia(cliente,midia);

                getListaMidiasSimilares(midiaCarregada.getIdMidia());

            }

            @Override
            public void onReservarClick(Midia midia) {
                reservarMidia(cliente,midia);

                getListaMidiasSimilares(midiaCarregada.getIdMidia());
            }
        }, listaFavoritos,listaReservas );
        LinearLayoutManager layoutManager = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvMidiasSimilares.setLayoutManager(layoutManager);
        rvMidiasSimilares.setAdapter(carrosselMainAdapter);
        PagerSnapHelper snapHelper = new PagerSnapHelper();//faz o rv agir como carrossel, se arrastar para quando um item estiver centralizado
        snapHelper.attachToRecyclerView(rvMidiasSimilares);//ativa o snapHelper no rv
        rvMidiasSimilares.setNestedScrollingEnabled(false);//trava o scroll do rv dentro do scrollview da pag
        rvMidiasSimilares.setHasFixedSize(false);//tamanho do rv nn muda
        int spacingInPixels = getResources().getDimensionPixelSize(R.dimen.item_espaco);
        rvMidiasSimilares.addItemDecoration(new EspacoItem(spacingInPixels));
        carregarMidia(idMidia);
        verificaReserva(cliente, idMidia);
        verificaFavoritagem(cliente, idMidia);
        getCarrosselFavoritados(cliente);
        getCarrosselReservados(cliente);
        getListaMidiasSimilares(idMidia);

        btnVoltar.setOnClickListener(v -> onBackPressed());
        btnFavoritar.setOnClickListener(v -> {
            //Toast.makeText(this, String.valueOf(favoritagemStatus), Toast.LENGTH_SHORT).show();
            if (favoritagemStatus==false) {
                favoritarMidia(cliente, midiaCarregada);
            } else {
                desfavoritarMidia(cliente, midiaCarregada);
            }
            verificaFavoritagem(cliente, midiaCarregada.getIdMidia());


        });
        btnReservar.setOnClickListener(v -> {
            //Toast.makeText(MidiaActivity.this, String.valueOf(reservaStatus), Toast.LENGTH_SHORT).show();
            if(reservaStatus==false){
                    reservarMidia(cliente,midiaCarregada);
            }else{
                Toast.makeText(MidiaActivity.this, "ATENÇÃO: Esta mídia já foi reservada!", Toast.LENGTH_SHORT).show();
            }

        });
    }
    private void findViewbyId() {
        tvNumExemplares = findViewById(R.id.tvNumExemplares);
        tvTitulo = findViewById(R.id.tvTitulo);
        tvAutor = findViewById(R.id.tvAutor);
        tvAno = findViewById(R.id.tvAno);
        tvEditora = findViewById(R.id.tvEditora);
        tvIsbn = findViewById(R.id.tvIsbn);
        tvGenero = findViewById(R.id.tvGenero);
        tvEdicao = findViewById(R.id.tvEdicao);
        tvSinopse = findViewById(R.id.tvSinopse);
        tvDuracao = findViewById(R.id.tvDuracao);
        tvEstudio = findViewById(R.id.tvEstudio);
        tvRoteirista = findViewById(R.id.tvRoteirista);
        llTitulo = findViewById(R.id.llTitulo);
        llAutor = findViewById(R.id.llAutor);
        llAno = findViewById(R.id.llAno);
        llEditora = findViewById(R.id.llEditora);
        llIsbn = findViewById(R.id.llIsbn);
        llGenero = findViewById(R.id.llGenero);
        llEdicao = findViewById(R.id.llEdicao);
        llDuracao = findViewById(R.id.llDuracao);
        llEstudio = findViewById(R.id.llEstudio);
        llRoteirista = findViewById(R.id.llRoteirista);
        rvMidiasSimilares = findViewById(R.id.rvMidiasSimilares);
        btnReservar = findViewById(R.id.btnReservar);
        btnVoltar = findViewById(R.id.btnVoltar);
        btnFavoritar = findViewById(R.id.btnFavoritar);
        imgItem = findViewById(R.id.imgItem);
        iconReserva = findViewById(R.id.icon_reserva_status);
        apiService = RetrofitManager.getApiService();
    }
    private void atualizarUIComMidia(Midia midia) {


        tvTitulo.setText(midia.getTitulo());
        tvAutor.setText(midia.getAutor());
        tvAno.setText(String.valueOf(midia.getAnoPublicacao()));
        tvGenero.setText(midia.getGenero());
        tvSinopse.setText(midia.getSinopse());
        tvNumExemplares.setText(String.valueOf(midia.getContExemplares()));
        carregarImagem(midia.getImagem());


        if (midia.getIdTpMidia() == 2) {

            llEditora.setVisibility(View.GONE);
            llIsbn.setVisibility(View.GONE);
            llEdicao.setVisibility(View.GONE);
            tvEditora.setVisibility(View.GONE);
            tvIsbn.setVisibility(View.GONE);
            tvEdicao.setVisibility(View.GONE);


            tvDuracao.setVisibility(View.VISIBLE);
            tvDuracao.setText(midia.getDuracao());
            tvEstudio.setVisibility(View.VISIBLE);
            tvEstudio.setText(midia.getEstudio());
            tvRoteirista.setVisibility(View.VISIBLE);
            tvRoteirista.setText(midia.getRoterista());

        } else {
            tvEditora.setVisibility(View.VISIBLE);
            tvIsbn.setVisibility(View.VISIBLE);
            tvEdicao.setVisibility(View.VISIBLE);

            tvEditora.setText(midia.getEditora());
            tvIsbn.setText(midia.getIsbn());
            tvEdicao.setText(midia.getEdicao());

            llDuracao.setVisibility(View.GONE);
            llEstudio.setVisibility(View.GONE);
            llRoteirista.setVisibility(View.GONE);
            tvDuracao.setVisibility(View.GONE);
            tvEstudio.setVisibility(View.GONE);
            tvRoteirista.setVisibility(View.GONE);
        }
    }

    private void carregarImagem(String imgUrl) {
        String fullUrl = RetrofitManager.getUrl() + imgUrl;
        Glide.with(MidiaActivity.this)
                .load(Uri.parse(fullUrl).toString())
                .placeholder(R.drawable.img_livro_teste)
                .error(R.drawable.img_livro_teste)
                .into(imgItem);
    }

    private void carregarMidia(int idMidia) {
        MidiaRequest request = new MidiaRequest(idMidia);
        apiService.getMidiaById(request).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<Midia>> call, @NonNull Response<List<Midia>> response) {
                if (response.isSuccessful() && response.body() != null && !response.body().isEmpty()) {

                    midiaCarregada = response.body().get(0);
                    Gson gson = new GsonBuilder().serializeNulls().create();

                    String json = gson.toJson(midiaCarregada);
                    Log.d("midia_info", json);
                    Log.e("tipo_midia", String.valueOf(midiaCarregada.getIdTpMidia()));
                    atualizarUIComMidia(midiaCarregada);

                    verificaFavoritagem(cliente, midiaCarregada.getIdMidia());
                    verificaReserva(cliente, midiaCarregada.getIdMidia());

                } else {
                    Toast.makeText(MidiaActivity.this, "ATENÇÃO: Erro ao carregar mídia!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<Midia>> call, @NonNull Throwable t) {
                Toast.makeText(MidiaActivity.this, "ERROR: Falha na conexão!", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void verificaFavoritagem(Cliente cliente, int idMidia) {
        apiService.listarDesejosCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ListaDesejos>> call, @NonNull Response<List<ListaDesejos>> response) {
                if (response.isSuccessful() && response.body() != null) {

                    boolean favoritada = false;

                    for (ListaDesejos r : response.body()) {
                        if (r.getMidia().getIdMidia() == idMidia) {
                            favoritada = true;
                            break;
                        }
                    }

                    favoritagemStatus = favoritada;

                    atualizarIconeFavorito(favoritada);
                } else {
                    favoritagemStatus = false;
                    atualizarIconeFavorito(false);
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<ListaDesejos>> call, @NonNull Throwable t) {
                favoritagemStatus = false;
                atualizarIconeFavorito(false);
            }
        });
    }

    private void verificaReserva(Cliente cliente, int idMidia) {
        apiService.listarReservasCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ReservaRequest>> call, @NonNull Response<List<ReservaRequest>> response) {

                boolean reservada = false;

                if (response.isSuccessful() && response.body() != null) {
                    for (ReservaRequest r : response.body()) {
                        if (r.getMidia().getIdMidia() == idMidia) {
                            reservada = true;
                            break;
                        }
                    }
                }

                reservaStatus = reservada;

                atualizarIconeReserva(reservada);
            }

            @Override
            public void onFailure(@NonNull Call<List<ReservaRequest>> call, @NonNull Throwable t) {
                reservaStatus = false;
                atualizarIconeReserva(false);
            }
        });
    }


    public void favoritarMidia(Cliente cliente, Midia midia) {
        if (midiaCarregada == null) return;
        Gson gson = new GsonBuilder().serializeNulls().create();
        ListaDesejos lista = new ListaDesejos(cliente.getIdCliente(), midia.getIdMidia());
        FavoritoRequest favorito = new FavoritoRequest(lista, cliente, midia);
        String json = gson.toJson(favorito);
        Log.d("favoritar_midia", json);
        apiService.favoritarMidia(favorito).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<Boolean> call, @NonNull Response<Boolean> response) {
                if (response.isSuccessful()) {
                    favoritagemStatus = true; // alterna estado
                    atualizarIconeFavorito(true);
                    Toast.makeText(MidiaActivity.this, "Midia favoritada com sucesso!", Toast.LENGTH_SHORT).show();
                    getCarrosselFavoritados(cliente);
                } else {
                    Toast.makeText(MidiaActivity.this, "ATENÇÃO: Erro ao favoritar!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Toast.makeText(MidiaActivity.this, "ATENÇÃO: Erro de conexão!", Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void reservarMidia(Cliente cliente, Midia midia) {
        if(midiaCarregada==null){
            return;
        }
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
                    reservaStatus = true; // alterna estado
                    atualizarIconeReserva(true);
                    Toast.makeText(MidiaActivity.this, "Reserva realizada!", Toast.LENGTH_SHORT).show();
                    getCarrosselReservados(cliente);
                } else {
                    Toast.makeText(MidiaActivity.this, "Erro ao reservar!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Toast.makeText(MidiaActivity.this, "Erro de conexão!", Toast.LENGTH_SHORT).show();
            }
        });


    }

    private void atualizarIconeFavorito(boolean favoritagemStatus) {
        if (favoritagemStatus) {
            btnFavoritar.setImageResource(R.drawable.icon_favoritado);
        } else {
            btnFavoritar.setImageResource(R.drawable.icon_desejo);
        }
    }

    private void atualizarIconeReserva(boolean reservaStatus) {
        if (reservaStatus) {
            iconReserva.setImageResource(R.drawable.icon_reservado);
        } else {
            iconReserva.setImageResource(R.drawable.icon_reservar);
        }
    }

    private void desfavoritarMidia(Cliente cliente, Midia midia){
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
                    Toast.makeText(MidiaActivity.this, "Midia desfavoritada com sucesso!", Toast.LENGTH_SHORT).show();
                    favoritagemStatus=false;
                    atualizarIconeFavorito(false);
                    getCarrosselFavoritados(cliente);
                } else {
                    Toast.makeText(MidiaActivity.this, "ERROR: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                Toast.makeText(MidiaActivity.this, "ERROR: Falha na conexão: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void getListaMidiasSimilares(int idMidia) {
        MidiaRequest request = new MidiaRequest(idMidia);
        Call<List<Midia>> call = apiService.getMidiasSimilares(request);
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<Midia>> call, @NonNull Response<List<Midia>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<Midia> lista = response.body();
                    Log.d("MidiaActivity", "Qtd similares: " + lista.size());
                    carrosselMainAdapter.updateList(lista);
                } else {
                    Log.e("MidiaActivity", "MidiasSimilares - resposta sem sucesso: " + response.code());
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<Midia>> call, @NonNull Throwable t) {
                Log.e("MidiaActivity", "ERROR: " + t.getMessage());
            }
        });
    }

    private void getCarrosselFavoritados(Cliente cliente){

        apiService.listarDesejosCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ListaDesejos>> call, @NonNull Response<List<ListaDesejos>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    listaFavoritos.clear();

                    for (ListaDesejos midia : response.body()) {
                        listaFavoritos.add(midia.getMidia().getIdMidia());
                    }
                    carrosselMainAdapter.setFavoritosIds(listaFavoritos);

                }
            }

            @Override
            public void onFailure(@NonNull Call<List<ListaDesejos>> call, @NonNull Throwable t) {
                Toast.makeText(MidiaActivity.this, "Erro ao carregar lista de desejos!", Toast.LENGTH_SHORT).show();
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
                    carrosselMainAdapter.setReservasIds(listaReservas);
                }

            }

            @Override
            public void onFailure(@NonNull Call<List<ReservaRequest>> call, @NonNull Throwable t) {
                Toast.makeText(MidiaActivity.this, "ATENÇÃO: Erro ao carregar reservas!", Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void abrirPagMidia(Midia midia) {
        Intent intent = new Intent(MidiaActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia", midia.getIdMidia());
        startActivity(intent);
    }


}
