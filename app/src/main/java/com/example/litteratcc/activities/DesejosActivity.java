package com.example.litteratcc.activities;


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
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ListaDesejoAdapter;
import com.example.litteratcc.service.RetrofitManager;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DesejosActivity extends AppCompatActivity {

    private ImageButton home, acervo, submenu, perfil;
    private FrameLayout btnQR;
    private View fundo_escuro, menu_layout;
    private PopupWindow popupWindowSubmenu;
    private ApiService apiService;
    private RecyclerView rvDesejo;
    private ListaDesejoAdapter adapter;
    private List<Midia> favoritos = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_desejos);

        // Inicializa views
        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        perfil = findViewById(R.id.item_perfil);
        menu_layout = findViewById(R.id.menu_layout);
        fundo_escuro = findViewById(R.id.background_cinza);
        rvDesejo = findViewById(R.id.rvDesejo);
        rvDesejo.setLayoutManager(new GridLayoutManager(this, 2));



        apiService = RetrofitManager.getApiService();

        // busca no json server
        apiService.getFavoritos().enqueue(new Callback<List<Midia>>() {
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    favoritos.clear(); // limpa a lista antes
                    favoritos.addAll(response.body()); // adiciona os dados vindos da API
                    adapter.notifyDataSetChanged(); // atualiza o RecyclerView
                }
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Toast.makeText(DesejosActivity.this, "Erro ao carregar reservas", Toast.LENGTH_SHORT).show();
            }
        });
        ListaDesejoAdapter.OnListaDesejoActionListener actionListener = new ListaDesejoAdapter.OnListaDesejoActionListener() {
            @Override
            public void onItemClick(Midia midia) {
                Intent intent;
                if (midia.getIdTpMidia()==1) {
                    intent = new Intent(DesejosActivity.this, LivroActivity.class);
                } else {
                    intent = new Intent(DesejosActivity.this, FilmeActivity.class);
                }
                intent.putExtra("idMidia", Integer.parseInt(midia.getIdMidia()));
                startActivity(intent);
            }

            @Override
            public void onDeletarClick(Midia midia) {
                Toast.makeText(DesejosActivity.this, "Deletou: " + Integer.parseInt(midia.getIdMidia()), Toast.LENGTH_SHORT).show();
                apiService.deleteFavorito(Integer.parseInt(midia.getIdMidia())).enqueue(new Callback<Void>() {
                    @Override
                    public void onResponse(Call<Void> call, Response<Void> response) {
                        if (response.isSuccessful()) {
                            Toast.makeText(DesejosActivity.this, "Item removido", Toast.LENGTH_SHORT).show();
                            favoritos.remove(midia);       // remove da lista local
                            adapter.notifyDataSetChanged(); // atualiza o RecyclerView
                        } else {
                            Toast.makeText(DesejosActivity.this, "Falha ao remover", Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onFailure(Call<Void> call, Throwable t) {
                        Toast.makeText(DesejosActivity.this, "Erro de rede", Toast.LENGTH_SHORT).show();
                    }
                });
            }

        };
        adapter = new ListaDesejoAdapter(this, favoritos, actionListener);
        rvDesejo.setAdapter(adapter);

        // Navegação inferior
        home.setOnClickListener(v -> { startActivity(new Intent(DesejosActivity.this, MainActivity.class)); finish(); });
        acervo.setOnClickListener(v -> { startActivity(new Intent(DesejosActivity.this, AcervoActivity.class)); finish(); });
        btnQR.setOnClickListener(v -> { startActivity(new Intent(DesejosActivity.this, QRCodeActivity.class)); finish(); });
        submenu.setOnClickListener(v -> toggleSubmenu());
        perfil.setOnClickListener(v -> startActivity(new Intent(DesejosActivity.this, PerfilActivity.class)));

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void toggleSubmenu() {
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

        popupView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
        int width = popupView.getMeasuredWidth();
        int height = popupView.getMeasuredHeight();

        int[] coords = new int[2];
        submenu.getLocationOnScreen(coords);
        int popupX = coords[0] + submenu.getWidth() / 2 - (int) (width * 0.83);
        int popupY = coords[1] - height;

        popupWindowSubmenu.setElevation(10f);
        popupWindowSubmenu.showAtLocation(submenu, Gravity.NO_GRAVITY, popupX, popupY);
        fundo_escuro.setVisibility(View.VISIBLE);

        popupWindowSubmenu.setOnDismissListener(() -> fundo_escuro.setVisibility(View.GONE));

        popupView.findViewById(R.id.item_emprestimo).setOnClickListener(v -> {
            startActivity(new Intent(this, EmprestimoActivity.class));
            popupWindowSubmenu.dismiss();
        });
        popupView.findViewById(R.id.item_reserva).setOnClickListener(v -> {
            startActivity(new Intent(this, ReservaActivity.class));
            popupWindowSubmenu.dismiss();
        });
        popupView.findViewById(R.id.item_desejo).setOnClickListener(v -> {
            startActivity(new Intent(this, DesejosActivity.class));
            popupWindowSubmenu.dismiss();
        });
    }

}
