package com.example.litteratcc.activities;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.litteratcc.EspacoItem;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.ListaDeDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.CarrosselAdapter;
import com.example.litteratcc.service.RetrofitManager;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class LivroActivity extends AppCompatActivity {

    TextView tvNumExemplares, tvTitulo, tvAutor, tvAno, tvEditora, tvIsbn, tvGenero, tvEdicao, tvSinopse;
    RecyclerView rvMidiasSimilares;
    LinearLayout btnReservar;
    ImageButton btnVoltar;
    private ApiService apiService;
    View fundo_escuro;
    PopupWindow popupWindow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_livro);

        // --- Inicializa views ---
        fundo_escuro = findViewById(R.id.background_cinza);
        tvNumExemplares = findViewById(R.id.tvNumExemplares);
        tvTitulo = findViewById(R.id.tvTitulo);
        tvAutor = findViewById(R.id.tvAutor);
        tvAno = findViewById(R.id.tvAno);
        tvEditora = findViewById(R.id.tvEditora);
        tvIsbn = findViewById(R.id.tvIsbn);
        tvGenero = findViewById(R.id.tvGenero);
        tvEdicao = findViewById(R.id.tvEdicao);
        tvSinopse = findViewById(R.id.tvSinopse);
        rvMidiasSimilares = findViewById(R.id.rvMidiasSimilares);
        btnReservar = findViewById(R.id.btnReservar);
        btnVoltar = findViewById(R.id.btnVoltar);


        apiService = RetrofitManager.getApiService();

        // --- Recebe id do livro ---
        // Recebendo o id da mídia
        int idMidia = getIntent().getIntExtra("idMidia", -1);
        if (idMidia != -1) {
            // Aqui você pode buscar o livro/filme pelo id no seu banco ou JSON
            Log.d("LivroActivity", "Recebi idMidia = " + idMidia);
        } else {
            Log.e("LivroActivity", "idMidia não recebido!");
        }


        // --- Carrega informações do livro ---
        carregarInfoMidia(idMidia);
        CarrosselAdapter.OnItemActionListener actionListener = new CarrosselAdapter.OnItemActionListener() {
            @Override
            public void onItemClick(Midia midia) {
                Intent intent;
                if (midia.getIdTpMidia()==1) {
                    intent = new Intent(LivroActivity.this, LivroActivity.class);
                } else {
                    intent = new Intent(LivroActivity.this, FilmeActivity.class);
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
                Toast.makeText(LivroActivity.this, "Favoritou: " + midia.getIdMidia(), Toast.LENGTH_SHORT).show();
                ListaDeDesejos novoFavorito = new ListaDeDesejos();
                novoFavorito.favoritar(midia, LivroActivity.this);

            }

            @Override
            public void onReservarClick(Midia midia) { Toast.makeText(LivroActivity.this, "Favoritou: " + midia.getIdMidia(), Toast.LENGTH_SHORT).show();
            }
        };

        // --- Configura RecyclerView de livros similares ---
        CarrosselAdapter similaresAdapter = new CarrosselAdapter(new ArrayList<>(), this, actionListener);
        LinearLayoutManager managerSimilares = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rvMidiasSimilares.setLayoutManager(managerSimilares);

        int spacingInPixels = getResources().getDimensionPixelSize(R.dimen.item_espaco);
        rvMidiasSimilares.setClipToPadding(false);
        rvMidiasSimilares.setClipChildren(false);
        rvMidiasSimilares.addItemDecoration(new EspacoItem(spacingInPixels));
        rvMidiasSimilares.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        rvMidiasSimilares.setAdapter(similaresAdapter);

        // Exemplo: buscar similares do mesmo gênero
        // (você pode alterar para buscar realmente pelo gênero do livro)
        getMidiasSimilares("Romance", similaresAdapter);

        // --- Popup de reserva ---
        btnReservar.setOnClickListener(v -> {

            // aqui você pode exibir o fundo escuro
            fundo_escuro.setVisibility(View.VISIBLE);
            // se já existe popup aberto, fecha e não cria outro
            if (popupWindow != null && popupWindow.isShowing()) {
                popupWindow.dismiss();
                return;
            }

            LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
            View popupView = inflater.inflate(R.layout.popup_reserva, null);

             popupWindow = new PopupWindow(
                    popupView,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    true // permite interação
            );

            popupWindow.setElevation(10f);
            View rootView = findViewById(android.R.id.content);
            popupWindow.showAtLocation(rootView, Gravity.CENTER, 0, 0);

            LinearLayout btnFechar = popupView.findViewById(R.id.btnFechar);
            btnFechar.setOnClickListener(view -> {
                fundo_escuro.setVisibility(View.GONE);
                popupWindow.dismiss();
            });
            popupWindow.setOnDismissListener(() -> {
                fundo_escuro.setVisibility(View.GONE);
            });

        });


        // --- Ajusta padding para barras do sistema ---
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // --- Botão voltar ---
        btnVoltar.setOnClickListener(v -> finish());
    }

    private void carregarInfoMidia(int idMidia) {
        Call<List<Midia>> call = apiService.getMidiaById(idMidia);
        call.enqueue(new Callback<List<Midia>>() {   // <---- aqui é List<Midia>
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {
                if (!response.isSuccessful()) {
                    Toast.makeText(LivroActivity.this, "Erro: " + response.code(), Toast.LENGTH_SHORT).show();
                    return;
                }

                List<Midia> midias = response.body();
                if (midias != null && !midias.isEmpty()) {
                    Midia midia = midias.get(0);  // pega o primeiro elemento
                    tvTitulo.setText(midia.getTitulo());
                    tvAutor.setText(midia.getAutor());
                    tvEditora.setText(midia.getEditora());
                    tvGenero.setText(midia.getGenero());
                    tvEdicao.setText(midia.getEdicao());
                    tvSinopse.setText(midia.getSinopse());
                    tvIsbn.setText(String.valueOf(midia.getIsbn()));
                    tvAno.setText(String.valueOf(midia.getAnoPublicacao()));
                }
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Toast.makeText(LivroActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }


    private void getMidiasSimilares(String genero, CarrosselAdapter adapter) {
        if (apiService == null) {
            Toast.makeText(this, "Conexão com API não foi possível", Toast.LENGTH_SHORT).show();
            return;
        }

        Call<List<Midia>> call = apiService.getMidiaCarrossel(genero);
        call.enqueue(new Callback<List<Midia>>() {
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {
                if (!response.isSuccessful()) {
                    Toast.makeText(LivroActivity.this, "Erro: " + response.code(), Toast.LENGTH_SHORT).show();
                    return;
                }

                List<Midia> midias = response.body();
                adapter.updateData(midias);
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Toast.makeText(LivroActivity.this, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }



}
