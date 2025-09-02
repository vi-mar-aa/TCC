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
import com.example.litteratcc.service.ReservaAdapter;
import com.example.litteratcc.service.RetrofitManager;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ReservaActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, perfil;
    FrameLayout btnQR;
    View fundo_escuro, menu_layout;
    PopupWindow popupWindowSubmenu;
    RecyclerView rvReservas;

    private ApiService apiService;
    private ReservaAdapter adapter;
    private List<Midia> reservados = new ArrayList<>(); // lista inicial vazia

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_reserva);

        home = findViewById(R.id.item_home);
        acervo = findViewById(R.id.item_acervo);
        btnQR = findViewById(R.id.btn_central);
        submenu = findViewById(R.id.item_submenu);
        perfil = findViewById(R.id.item_perfil);
        menu_layout = findViewById(R.id.menu_layout);
        fundo_escuro = findViewById(R.id.background_cinza);

        rvReservas = findViewById(R.id.rvReservas);
        rvReservas.setLayoutManager(new GridLayoutManager(this, 2));


        // inicializa adapter com lista vazia
        adapter = new ReservaAdapter(this, reservados);
        rvReservas.setAdapter(adapter);

        apiService = RetrofitManager.getApiService();

        // busca no json server
        apiService.getReservas().enqueue(new Callback<List<Midia>>() {
            @Override
            public void onResponse(Call<List<Midia>> call, Response<List<Midia>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    reservados.clear(); // limpa a lista antes
                    reservados.addAll(response.body()); // adiciona os dados vindos da API
                    adapter.notifyDataSetChanged(); // atualiza o RecyclerView
                }
            }

            @Override
            public void onFailure(Call<List<Midia>> call, Throwable t) {
                Toast.makeText(ReservaActivity.this, "Erro ao carregar reservas", Toast.LENGTH_SHORT).show();
            }
        });


        // navegação
        home.setOnClickListener(v -> {
            startActivity(new Intent(ReservaActivity.this, MainActivity.class));
            finish();
        });

        acervo.setOnClickListener(v -> {
            startActivity(new Intent(ReservaActivity.this, AcervoActivity.class));
            finish();
        });

        btnQR.setOnClickListener(v -> {
            startActivity(new Intent(ReservaActivity.this, QRCodeActivity.class));
            finish();
        });

        submenu.setOnClickListener(v -> abrirSubmenu());
        perfil.setOnClickListener(v -> {
            startActivity(new Intent(ReservaActivity.this, PerfilActivity.class));
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void abrirSubmenu() {
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
            startActivity(new Intent(ReservaActivity.this, EmprestimoActivity.class));
            popupWindowSubmenu.dismiss();
        });

        popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
            startActivity(new Intent(ReservaActivity.this, ReservaActivity.class));
            popupWindowSubmenu.dismiss();
        });

        popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
            startActivity(new Intent(ReservaActivity.this, DesejosActivity.class));
            popupWindowSubmenu.dismiss();
        });
    }
}
