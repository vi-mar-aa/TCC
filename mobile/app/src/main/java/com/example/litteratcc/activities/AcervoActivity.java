package com.example.litteratcc.activities;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.Spinner;
import android.widget.TextView;
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
import androidx.recyclerview.widget.RecyclerView;
import com.example.litteratcc.R;
import com.example.litteratcc.adapters.CarrosselMainAdapter;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.Funcionario;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.modelo.Reserva;
import com.example.litteratcc.request.FavoritoRequest;
import com.example.litteratcc.request.FiltroAcervoRequest;
import com.example.litteratcc.request.RequestPesquisaAcervo;
import com.example.litteratcc.request.ReservaRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.service.RetrofitManager;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class AcervoActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, config, ivSearch;
    FrameLayout btnQR;
    EditText edtPesquisa;
    AppCompatButton btnLivros,btnAudiovisual;

    //dentro do layout de filtro
    View llFiltro;
    TextView llTitFiltroGenero;
    LinearLayout llFiltroGenero;
    ImageButton btnGeneroFiltro;
    Spinner spinnerAno;

    View indicador_acervo, fundo_escuro, menu_layout;
    PopupWindow popupWindowSubmenu;
    RecyclerView rvAcervo;

    ApiService apiService;
    CarrosselMainAdapter carrosselMainAdapter;
    ClienteSessionManager sessionManager;
    Cliente cliente;
    CheckBox cbArtigo, cbAventura, cbBiografia, cbCiencia, cbComedia, cbConto, cbCronica, cbDiario,
            cbDistopia, cbDrama, cbEnsaio, cbFabula, cbFantasia, cbFiccaoCientifica, cbNovela, cbOutros,
            cbPeriodico, cbPoesia, cbPolicial, cbReportagem, cbRevista, cbRomance, cbSuspense, cbTerror, cbUtopia;

    List<CheckBox> listaCheckBox;
    private List<Midia> listaFiltrada = new ArrayList<>();
    private String tipoSelecionado = "livros";
    private String anoSelecionado = null;
    private List<String> generosSelecionados = new ArrayList<>();
    private Handler handler = new Handler();
    private Runnable filtroRunnable;
    List<Integer> listaFavoritos = new ArrayList<>();
    List<Integer> listaReservas = new ArrayList<>();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_acervo);

        findViewbyId();
        sessionManager = new ClienteSessionManager(this);
        cliente = sessionManager.getDadosCliente();
        if (cliente == null) {
            Toast.makeText(this, "Nenhum cliente logado", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        cbArtigo = findViewById(R.id.cbArtigo);
        cbAventura = findViewById(R.id.cbAventura);
        cbBiografia = findViewById(R.id.cbBiografia);
        cbCiencia = findViewById(R.id.cbCiencia);
        cbComedia = findViewById(R.id.cbComedia);
        cbConto = findViewById(R.id.cbConto);
        cbCronica = findViewById(R.id.cbCronica);
        cbDiario = findViewById(R.id.cbDiario);
        cbDistopia = findViewById(R.id.cbDistopia);
        cbDrama = findViewById(R.id.cbDrama);
        cbEnsaio = findViewById(R.id.cbEnsaio);
        cbFabula = findViewById(R.id.cbFabula);
        cbFantasia = findViewById(R.id.cbFantasia);
        cbFiccaoCientifica = findViewById(R.id.cbFiccaoCientifica);
        cbNovela = findViewById(R.id.cbNovela);
        cbOutros = findViewById(R.id.cbOutros);
        cbPeriodico = findViewById(R.id.cbPeriodico);
        cbPoesia = findViewById(R.id.cbPoesia);
        cbPolicial = findViewById(R.id.cbPolicial);
        cbReportagem = findViewById(R.id.cbReportagem);
        cbRevista = findViewById(R.id.cbRevista);
        cbRomance = findViewById(R.id.cbRomance);
        cbSuspense = findViewById(R.id.cbSuspense);
        cbTerror = findViewById(R.id.cbTerror);
        cbUtopia = findViewById(R.id.cbUtopia);

        listaCheckBox = Arrays.asList(
                cbArtigo, cbAventura, cbBiografia, cbCiencia, cbComedia, cbConto, cbCronica, cbDiario,
                cbDistopia, cbDrama, cbEnsaio, cbFabula, cbFantasia, cbFiccaoCientifica, cbNovela, cbOutros,
                cbPeriodico, cbPoesia, cbPolicial, cbReportagem, cbRevista, cbRomance, cbSuspense, cbTerror, cbUtopia
        );

        buscarMidias();

        List<String> anosFiltro = new ArrayList<>();
        anosFiltro.add("Selecione o ano"); // posição 0
        for(int i =0; i<200; i++){
            int ano = 2025 - i;
            anosFiltro.add(String.valueOf(ano));
        }

        ArrayAdapter<String> adapterAnos = new ArrayAdapter<>(
                this,
                android.R.layout.simple_spinner_item,
                anosFiltro
        );

        adapterAnos.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerAno.setAdapter(adapterAnos);
        spinnerAno.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                anoSelecionado = parent.getItemAtPosition(position).toString();

                if (filtroRunnable != null) handler.removeCallbacks(filtroRunnable);//se já tiver uma call tira e refaz
                filtroRunnable = AcervoActivity.this::buscarMidias;
                handler.postDelayed(filtroRunnable, 500);//pra evitar de travar
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        btnLivros.setOnClickListener(v -> {
            btnLivros.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnAudiovisual.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
            tipoSelecionado = "livros";
            cbArtigo.setVisibility(View.VISIBLE);
            cbConto.setVisibility(View.VISIBLE);
            cbCronica.setVisibility(View.VISIBLE);
            cbFabula.setVisibility(View.VISIBLE);
            cbPoesia.setVisibility(View.VISIBLE);
            if (filtroRunnable != null) handler.removeCallbacks(filtroRunnable);
            filtroRunnable = this::buscarMidias;
            handler.postDelayed(filtroRunnable, 500);
        });

        btnAudiovisual.setOnClickListener(v -> {
            btnAudiovisual.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicado_design));
            btnLivros.setBackground(ContextCompat.getDrawable(this, R.drawable.btn_clicavel_design));
            tipoSelecionado = "filmes";
            llTitFiltroGenero.setText("Gênero");
            //oq nn dá pra selecionar no audiovisual
            cbArtigo.setVisibility(View.GONE);
            cbConto.setVisibility(View.GONE);
            cbCronica.setVisibility(View.GONE);
            cbFabula.setVisibility(View.GONE);
            cbPoesia.setVisibility(View.GONE);
            spinnerAno.setSelection(0);
            if (filtroRunnable != null) handler.removeCallbacks(filtroRunnable);
            filtroRunnable = this::buscarMidias;
            handler.postDelayed(filtroRunnable, 500);
        });

        for (CheckBox cb : listaCheckBox) {
            cb.setOnCheckedChangeListener((buttonView, isChecked) -> {

                String genero = cb.getText().toString(); // mantém acento e uppercase do texto do checkbox, pq é assim que o sql aceita

                if (isChecked) {
                    if (!generosSelecionados.contains(genero)) {
                        generosSelecionados.add(genero);
                    }
                } else {
                    generosSelecionados.remove(genero);
                }

                // debounce real
                if (filtroRunnable != null)
                    handler.removeCallbacks(filtroRunnable);

                filtroRunnable = this::buscarMidias;

                handler.postDelayed(filtroRunnable, 1000);
            });
        }


        btnGeneroFiltro.setOnClickListener(v -> {
            if (btnGeneroFiltro.getTag().equals("closed")) {
                llFiltroGenero.setVisibility(View.VISIBLE);
                llFiltroGenero.setAlpha(0f);
                llFiltroGenero.setTranslationY(-llFiltroGenero.getHeight());
                llFiltroGenero.animate()
                        .translationY(0)
                        .alpha(1f)//visivel
                        .setDuration(200)
                        .start();
                btnGeneroFiltro.setTag("open");
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_down);
            } else {
                llFiltroGenero.animate()
                        .translationY(-llFiltroGenero.getHeight())
                        .alpha(0f)
                        .setDuration(200)
                        .withEndAction(() -> llFiltroGenero.setVisibility(View.GONE))
                        .start();
                btnGeneroFiltro.setTag("closed");
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_up);
            }
        });


      carrosselMainAdapter = new CarrosselMainAdapter(listaFiltrada, AcervoActivity.this, new CarrosselMainAdapter.OnItemActionListener() {
            @Override
            public void onItemClick(Midia midia) {
                abrirPagMidia(midia);
            }

            @Override
            public void onItemLongClick(Midia midia) {


            }

            @Override
            public void onFavoritarClick(Midia midia) {
                favoritarMidia(cliente, midia);
            }
            @Override
            public void onDesfavoritarClick(Midia midia) {
                desfavoritarMidia(cliente,midia);
            }

            @Override
            public void onReservarClick(Midia midia) {
                reservarMidia(cliente, midia);
            }
        }, listaFavoritos,listaReservas );
        GridLayoutManager glAcervo = new GridLayoutManager(this, 2);//pra aparecer 2 colunas
        rvAcervo.setLayoutManager(glAcervo);
        rvAcervo.setAdapter(carrosselMainAdapter);
        rvAcervo.setItemAnimator(null);
        getCarrosselFavoritados(cliente);
        getCarrosselReservados(cliente);

        ivSearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String palavraChave = edtPesquisa.getText().toString();
                if (palavraChave.isEmpty()) {
                    Toast.makeText(AcervoActivity.this, "Digite uma palavra-chave para pesquisar!", Toast.LENGTH_SHORT).show();
                    return;
                }
                pesquisarAcervo(palavraChave);
                llFiltroGenero.animate()
                        .translationY(-llFiltroGenero.getHeight())
                        .alpha(0f)
                        .setDuration(300)
                        .withEndAction(() -> llFiltroGenero.setVisibility(View.GONE))
                        .start();
                btnGeneroFiltro.setTag("closed");
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_up);
            }
        });
        //ou direto do teclado, quando clica em ok
        edtPesquisa.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH || actionId == EditorInfo.IME_ACTION_DONE) {
                String palavraChave = edtPesquisa.getText().toString();
                if (palavraChave.isEmpty()) {
                    Toast.makeText(AcervoActivity.this, "Digite uma palavra-chave para pesquisar!", Toast.LENGTH_SHORT).show();
                    return false;
                }
                pesquisarAcervo(palavraChave);
                //para zerar tudo
                llFiltroGenero.animate()
                        .translationY(-llFiltroGenero.getHeight())
                        .alpha(0f)
                        .setDuration(300)
                        .withEndAction(() -> llFiltroGenero.setVisibility(View.GONE))
                        .start();
                btnGeneroFiltro.setTag("closed");
                btnGeneroFiltro.setImageResource(R.drawable.icon_combobox_up);
                spinnerAno.setSelection(0);
                for (CheckBox cb : listaCheckBox) {
                    cb.setOnCheckedChangeListener((buttonView, isChecked) -> {

                        String genero = cb.getText().toString(); // mantém acento e uppercase do texto do checkbox

                        if (isChecked) {
                            if (!generosSelecionados.contains(genero)) {
                                generosSelecionados.add(genero);
                            }
                        } else {
                            generosSelecionados.remove(genero);
                        }

                        // debounce real
                        if (filtroRunnable != null)
                            handler.removeCallbacks(filtroRunnable);

                    });
                }
                return true;
            }
            return false;
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    public void findViewbyId() {

        ivSearch = findViewById(R.id.ivSearch);
        edtPesquisa = findViewById(R.id.edtPesquisa);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        menu_layout = findViewById(R.id.menu_layout);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        fundo_escuro = findViewById(R.id.background_cinza);
        config = findViewById(R.id.item_config);
        indicador_acervo = findViewById(R.id.indicador_acervo);
        indicador_acervo.setVisibility(View.VISIBLE);
        btnLivros = findViewById(R.id.btnLivros);
        btnAudiovisual = findViewById(R.id.btnAudiovisual);
        rvAcervo = findViewById(R.id.rvAcervo);
        llFiltro = findViewById(R.id.llFiltro);
        llTitFiltroGenero = findViewById(R.id.tvGeneroFiltro);
        btnGeneroFiltro = findViewById(R.id.btnGeneroFiltro);
        spinnerAno = findViewById(R.id.spinAno);
        llFiltroGenero = findViewById(R.id.llFiltroGenero);
        configurarMenu(home, acervo, btnQR, submenu, config);
        apiService = RetrofitManager.getApiService();

    }
    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent atualizarPag = new Intent(AcervoActivity.this, MainActivity.class);
            startActivity(atualizarPag);
        });
        acervo.setOnClickListener(v -> {
            Intent acervoActivity= new Intent(AcervoActivity.this, AcervoActivity.class);
            startActivity(acervoActivity);
        });
        btnQR.setOnClickListener(v -> {
            Intent qrActivity = new Intent(AcervoActivity.this, QRCodeActivity.class);
            startActivity(qrActivity);
        });
        submenu.setOnClickListener(v -> abrirSubmenu());
        config.setOnClickListener(v -> startActivity(new Intent(AcervoActivity.this, ConfiguracoesActivity.class)));
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
            startActivity(new Intent(AcervoActivity.this, EmprestimoActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
            startActivity(new Intent(AcervoActivity.this, ReservaActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
            startActivity(new Intent(AcervoActivity.this, DesejosActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });
    }

    //pra procurar midia
    private void buscarMidias() {

        FiltroAcervoRequest filtro = new FiltroAcervoRequest();
        filtro.setTipo(tipoSelecionado);

        if (anoSelecionado != null && !anoSelecionado.equals("Selecione o ano"))
            filtro.setAnos(Arrays.asList(anoSelecionado));
        else
            filtro.setAnos(null);//tem q aparecer no corpo do json

        if (!generosSelecionados.isEmpty()) {
            filtro.setGeneros(generosSelecionados);
        } else {
            filtro.setGeneros(null);
        }
        Gson gson = new GsonBuilder()
                .serializeNulls() // inclui oq é nulo
                .create();
        String json = gson.toJson(filtro);
        Log.e("AcervoActivity", "filtro_busca: " +json);
        apiService.filtrarAcervo(filtro).enqueue(new Callback<List<Midia>>() {
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {

                if (response.isSuccessful()) {

                    listaFiltrada.clear();//zera o rv
                    listaFiltrada.addAll(response.body());

                    runOnUiThread(() -> carrosselMainAdapter.notifyDataSetChanged());//atualiza a pag inteira, nn é a thread princ pq tá usando enqueue(back pra nn travar a UI)
                    //onResponse nn é chamada na thread principal
                } else {
                    Log.e("Busca_Midia_Acervo", "ERROR: " + response.code());
                }
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Log.e("Busca_Midia_Acervo", "ERROR: " + t.getMessage());
            }
        });
    }
    private void pesquisarAcervo(String termoBusca) {
        Midia midiaFiltro = new Midia();
        RequestPesquisaAcervo request = new RequestPesquisaAcervo(midiaFiltro,termoBusca);
        request.setSearchText(termoBusca);
        apiService.pesquisarAcervo(request).enqueue(new Callback<List<Midia>>() {
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<Midia> midias = response.body();
                    listaFiltrada.clear();
                    listaFiltrada.addAll(midias);
                    carrosselMainAdapter.notifyDataSetChanged();

                } else {
                    Toast.makeText(AcervoActivity.this, "Nenhum resultado encontrado", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Toast.makeText(AcervoActivity.this, "Erro ao pesquisar: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                t.printStackTrace();
            }
        });
    }


    //click nas midias
    private void abrirPagMidia(Midia midia) {
        Intent intent = new Intent(AcervoActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia", midia.getIdMidia()); // mesma chave usada no get
        startActivity(intent);
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
                    Toast.makeText(AcervoActivity.this, "Midia desfavoritada com sucesso!", Toast.LENGTH_SHORT).show();
                    buscarMidias();
                } else {
                    Toast.makeText(AcervoActivity.this, "ERROR: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                Toast.makeText(AcervoActivity.this, "ERROR: Falha na conexão: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
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

                    Toast.makeText(AcervoActivity.this, "Midia favoritada com sucesso!", Toast.LENGTH_SHORT).show();
                    buscarMidias();
                } else {
                    Toast.makeText(AcervoActivity.this, "ATENÇÃO: Erro ao favoritar!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Toast.makeText(AcervoActivity.this, "ATENÇÃO: Erro de conexão!", Toast.LENGTH_SHORT).show();
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

                    Toast.makeText(AcervoActivity.this, "Reserva realizada!", Toast.LENGTH_SHORT).show();
                    buscarMidias();
                } else {
                    Toast.makeText(AcervoActivity.this, "Erro ao reservar!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<Boolean> call, @NonNull Throwable t) {
                Toast.makeText(AcervoActivity.this, "Erro de conexão!", Toast.LENGTH_SHORT).show();
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
                Toast.makeText(AcervoActivity.this, "Erro ao carregar lista de desejos!", Toast.LENGTH_SHORT).show();
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
                Toast.makeText(AcervoActivity.this, "ATENÇÃO: Erro ao carregar reservas!", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
