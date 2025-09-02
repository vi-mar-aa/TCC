package com.example.litteratcc.activities;

import com.example.litteratcc.EspacoItem;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.CarrosselAdapter;
import com.example.litteratcc.service.RetrofitManager;

import android.content.Intent;
import android.os.Bundle;
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
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;


public class MainActivity extends AppCompatActivity {
ImageButton home, acervo, submenu, perfil, btnNotificacao;
View fundo_escuro, menu_layout,indicador_home;
RecyclerView rvPopLivros, rvArtigos, rvRomance, rvBiografia, rvManuais, rvCronicas, rvRevista, rvDidatico, rvPoesia, rvOutros;
PopupWindow popupWindowSubmenu;
private ApiService apiService;

    FrameLayout btnQR;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        fundo_escuro = findViewById(R.id.background_cinza);
        perfil = findViewById(R.id.item_perfil);
        menu_layout = findViewById(R.id.menu_layout);
        rvPopLivros = findViewById(R.id.rvPopLivros);
        rvArtigos = findViewById(R.id.rvArtigos);
        rvRomance = findViewById(R.id.rvRomance);
        rvBiografia = findViewById(R.id.rvBiografia);
        rvManuais = findViewById(R.id.rvManuais);
        rvCronicas = findViewById(R.id.rvCronicas);
        rvRevista = findViewById(R.id.rvRevista);
        rvDidatico = findViewById(R.id.rvDidatico);
        rvPoesia = findViewById(R.id.rvPoesia);
        rvOutros = findViewById(R.id.rvOutros);
        indicador_home = findViewById(R.id.indicador_home);
        indicador_home.setVisibility(View.VISIBLE);
        int spacingInPixels = getResources().getDimensionPixelSize(R.dimen.item_espaco);

        apiService = RetrofitManager.getApiService();

        //CARROSSEL DE POPULARES
        LinearLayoutManager managerPop = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvPopLivros.setLayoutManager(managerPop);
        rvPopLivros.setClipToPadding(false);
        rvPopLivros.setClipChildren(false);
        rvPoesia.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
         spacingInPixels = getResources().getDimensionPixelSize(R.dimen.item_espaco);
        rvPopLivros.addItemDecoration(new EspacoItem(spacingInPixels));
       rvPopLivros.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                int centerX = recyclerView.getWidth() / 2;
                for (int i = 0; i < recyclerView.getChildCount(); i++) {
                    View child = recyclerView.getChildAt(i);
                    int childCenterX = (child.getLeft() + child.getRight()) / 2;

                    // Distância do centro do RecyclerView
                    int distanceFromCenter = Math.abs(centerX - childCenterX);

                    // Quanto mais longe do centro, menor a escala
                    float scale = 1 - (distanceFromCenter / (float) recyclerView.getWidth());

                    // Ajusta escala mínima e máxima
                    scale = Math.max(0.8f, Math.min(scale, 1f));

                    child.setScaleX(scale);
                    child.setScaleY(scale);
                }
            }
        });

        CarrosselAdapter.OnItemActionListener actionListener = new CarrosselAdapter.OnItemActionListener() {
            @Override
            public void onItemClick(Midia midia) {
                Intent intent;
                if (midia.getIdTpMidia()==1) {
                    intent = new Intent(MainActivity.this, LivroActivity.class);
                } else {
                    intent = new Intent(MainActivity.this, FilmeActivity.class);
                }
                intent.putExtra("idMidia", Integer.parseInt(midia.getIdMidia()));
                startActivity(intent);
            }

            @Override
            public void onItemLongClick(Midia midia) {
                // mostrar os ícones (UI)
            }

            @Override
            public void onFavoritarClick(Midia midia) {
                Toast.makeText(MainActivity.this, "Favoritou: " + midia.getIdMidia(), Toast.LENGTH_SHORT).show();
                apiService.favoritarMidia(midia).enqueue(new Callback<Midia>() {
                    @Override
                    public void onResponse(Call<Midia> call, Response<Midia> response) {
                        if (response.isSuccessful()) {
                            Toast.makeText(MainActivity.this, "Favoritado com sucesso!", Toast.LENGTH_SHORT).show();
                        }
                    }
                    @Override
                    public void onFailure(Call<Midia> call, Throwable t) {
                        Toast.makeText(MainActivity.this, "Erro ao favoritar", Toast.LENGTH_SHORT).show();
                    }
                });

            }

            @Override
            public void onReservarClick(Midia midia) { Toast.makeText(MainActivity.this, "Reservou: " + midia.getIdMidia(), Toast.LENGTH_SHORT).show();

                    apiService.reservarMidia(midia).enqueue(new Callback<Midia>() {
                        @Override
                        public void onResponse(Call<Midia> call, Response<Midia> response) {
                            if (response.isSuccessful()) {
                                Toast.makeText(MainActivity.this, "Reservado com sucesso!", Toast.LENGTH_SHORT).show();
                            }
                        }
                        @Override
                        public void onFailure(Call<Midia> call, Throwable t) {
                            Toast.makeText(MainActivity.this, "Erro ao reservar", Toast.LENGTH_SHORT).show();
                        }
                    });
            }
        };


        //CARROSSEL DE ARTIGOS
        CarrosselAdapter artigoAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerArtigo = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvArtigos.setLayoutManager(managerArtigo);
        rvArtigos.setClipToPadding(false);
        rvArtigos.setClipChildren(false);
        rvArtigos.addItemDecoration(new EspacoItem(spacingInPixels));
        rvArtigos.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvArtigos.setAdapter(artigoAdapter);
        getMidias("Artigos", artigoAdapter);

        //CARROSSEL DE ROMANCE
        CarrosselAdapter romanceAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerRomance = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvRomance.setLayoutManager(managerRomance);
        rvRomance.setClipToPadding(false);
        rvRomance.setClipChildren(false);
        rvRomance.addItemDecoration(new EspacoItem(spacingInPixels));
        rvRomance.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvRomance.setAdapter(romanceAdapter);
        getMidias("Romance", romanceAdapter);

        //CARROSSEL DE BIOGRAFIAS
        CarrosselAdapter biografiaAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerBiografia = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvBiografia.setLayoutManager(managerBiografia);
        rvBiografia.setClipToPadding(false);
        rvBiografia.setClipChildren(false);
        rvBiografia.addItemDecoration(new EspacoItem(spacingInPixels));
        rvBiografia.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvBiografia.setAdapter(biografiaAdapter);
        getMidias("Biografia", biografiaAdapter);

        //CARROSSEL DE MANUAIS
        CarrosselAdapter manuaisAdapter = new CarrosselAdapter(new ArrayList<>(), this,actionListener);
        LinearLayoutManager managerManuais = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvManuais.setLayoutManager(managerManuais);
        rvManuais.setClipToPadding(false);
        rvManuais.setClipChildren(false);
        rvManuais.addItemDecoration(new EspacoItem(spacingInPixels));
        rvManuais.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvManuais.setAdapter(manuaisAdapter);
        getMidias("Manuais", manuaisAdapter);

        //CARROSSEL DE CRÔNICAS
        CarrosselAdapter cronicasAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerCronicas = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvCronicas.setLayoutManager(managerCronicas);
        rvCronicas.setClipToPadding(false);
        rvCronicas.setClipChildren(false);
        rvCronicas.addItemDecoration(new EspacoItem(spacingInPixels));
        rvCronicas.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvCronicas.setAdapter(cronicasAdapter);
        getMidias("Crônicas", cronicasAdapter);

        //CARROSSEL DE REVISTAS
        CarrosselAdapter revistaAdapter = new CarrosselAdapter(new ArrayList<>(), this,actionListener);
        LinearLayoutManager managerRevistas = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvRevista.setLayoutManager(managerRevistas);
        rvRevista.setClipToPadding(false);
        rvRevista.setClipChildren(false);
        rvRevista.addItemDecoration(new EspacoItem(spacingInPixels));
        rvRevista.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvRevista.setAdapter(revistaAdapter);
        getMidias("Revista", revistaAdapter);

        //CARROSSEL DE DIDÁTICOS
        CarrosselAdapter didaticosAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerDidaticos = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvDidatico.setLayoutManager(managerDidaticos);
        rvDidatico.setClipToPadding(false);
        rvDidatico.setClipChildren(false);
        rvDidatico.addItemDecoration(new EspacoItem(spacingInPixels));
        rvDidatico.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvDidatico.setAdapter(didaticosAdapter);
        getMidias("Didáticos", didaticosAdapter);

        //CARROSSEL DE POESIA
       CarrosselAdapter poesiaAdapter = new CarrosselAdapter(new ArrayList<>(), this,actionListener);
        LinearLayoutManager managerPoesia = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvPoesia.setLayoutManager(managerPoesia);
        rvPoesia.setClipToPadding(false);
        rvPoesia.setClipChildren(false);
        rvPoesia.addItemDecoration(new EspacoItem(spacingInPixels));
        rvPoesia.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvPoesia.setAdapter(poesiaAdapter);
        getMidias("Poesia", poesiaAdapter);

        //CARROSSEL DE OUTROS
        CarrosselAdapter outrosAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerOutros = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvDidatico.setLayoutManager(managerOutros);
        rvDidatico.setClipToPadding(false);
        rvDidatico.setClipChildren(false);
        rvDidatico.addItemDecoration(new EspacoItem(spacingInPixels));
        rvDidatico.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvDidatico.setAdapter(outrosAdapter);
        getMidias("Outros", outrosAdapter);

        btnNotificacao = findViewById(R.id.btnNotificacao);
        home.setOnClickListener(v -> {
            Intent home = new Intent(MainActivity.this, MainActivity.class);
            startActivity(home);
            finish();
        });
        acervo.setOnClickListener(v -> {
            Intent acervo= new Intent(MainActivity.this, AcervoActivity.class);
            startActivity(acervo);
            finish();
        });
        btnQR.setOnClickListener(v -> {
            Intent qr = new Intent(MainActivity.this, QRCodeActivity.class);
            startActivity(qr);
            finish();
        });
        submenu.setOnClickListener(v -> {
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
            // Mede o tamanho do layout
            popupView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            int width = popupView.getMeasuredWidth();
            int height = popupView.getMeasuredHeight();

// Pega posição do botão
            int[] coordenadasPop = new int[2];
            submenu.getLocationOnScreen(coordenadasPop);

// Alinha o balão para que a seta fique centralizada no botão submenu
            int popupX = coordenadasPop[0] + submenu.getWidth() / 2 - (int) (width * 0.83); // Ajuste o fator conforme necessário
            int popupY = coordenadasPop[1] - height;

            popupWindowSubmenu.setElevation(10f);
            popupWindowSubmenu.showAtLocation(submenu, Gravity.NO_GRAVITY, popupX, popupY);
            fundo_escuro.setVisibility(View.VISIBLE);
            popupWindowSubmenu.setOnDismissListener(() -> {
                fundo_escuro.setVisibility(View.GONE);
                popupWindowSubmenu = null;
            });

            // Clique em cada item do submenu
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
        });
        perfil.setOnClickListener(v -> {
            Intent perfil = new Intent(MainActivity.this, PerfilActivity.class);
            startActivity(perfil);
        });
        btnNotificacao.setOnClickListener(v -> {

                    Intent notificacao = new Intent(MainActivity.this, NotificacaoActivity.class);
                    startActivity(notificacao);
                });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    public void getMidias(String genero, CarrosselAdapter adapter) {
        if (apiService == null) {
            Toast.makeText(this, "Conexão com API não foi possível", Toast.LENGTH_SHORT).show();
            return;
        }

        Call<List<Midia>> call = apiService.getMidiaCarrossel(genero);
        call.enqueue(new Callback<List<Midia>>() {
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {
                if (!response.isSuccessful()) {
                    Toast.makeText(MainActivity.this, "Erro: " + response.code(), Toast.LENGTH_SHORT).show();
                    return;
                }

                List<Midia> midias = response.body();
                adapter.updateData(midias); // precisa criar método updateData no adapter
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Toast.makeText(MainActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }



}
