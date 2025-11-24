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
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.request.ReservaRequest;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.ClienteSessionManager;
import com.example.litteratcc.adapters.ReservaAdapter;
import com.example.litteratcc.service.RetrofitManager;
import java.util.ArrayList;
import java.util.List;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ReservaActivity extends AppCompatActivity {
    ImageButton home, acervo, submenu, config;
    FrameLayout btnQR;
    View fundo_escuro, menu_layout;
    PopupWindow popupWindowSubmenu;
    RecyclerView rvReservas;
    ApiService apiService;
     ReservaAdapter adapterReserva;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_reserva);

        findViewbyId();

        ClienteSessionManager clienteSessionManager = new ClienteSessionManager(this);
        Cliente cliente = clienteSessionManager.getDadosCliente();

        adapterReserva = new ReservaAdapter(ReservaActivity.this,new ArrayList<>(), this::abrirPagMidia);
        rvReservas.setLayoutManager(new GridLayoutManager(this, 2));
        rvReservas.setAdapter(adapterReserva);
        carregarReservas(cliente);

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
        menu_layout = findViewById(R.id.menu_layout);
        fundo_escuro = findViewById(R.id.background_cinza);
        rvReservas = findViewById(R.id.rvReservas);
        configurarMenu(home, acervo, btnQR, submenu, config);
        apiService = RetrofitManager.getApiService();
    }
    private void abrirPagMidia(ReservaRequest reserva) {
        Intent intent = new Intent(ReservaActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia", reserva.getMidia().getIdMidia());
        startActivity(intent);
    }

    private void configurarMenu(ImageButton home, ImageButton acervo, FrameLayout btnQR, ImageButton submenu, ImageButton config) {
        home.setOnClickListener(v -> {
            Intent atualizarPag = new Intent(ReservaActivity.this, MainActivity.class);
            startActivity(atualizarPag);

        });
        acervo.setOnClickListener(v -> {
            Intent acervoActivity= new Intent(ReservaActivity.this, AcervoActivity.class);
            startActivity(acervoActivity);

        });
        btnQR.setOnClickListener(v -> {
            Intent qrActivity = new Intent(ReservaActivity.this, QRCodeActivity.class);
            startActivity(qrActivity);

        });
        submenu.setOnClickListener(v -> abrirSubmenu());
        config.setOnClickListener(v -> startActivity(new Intent(ReservaActivity.this, ConfiguracoesActivity.class)));
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
            startActivity(new Intent(ReservaActivity.this, EmprestimoActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_reserva).setOnClickListener(view -> {
            startActivity(new Intent(ReservaActivity.this, ReservaActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });

        popupView.findViewById(R.id.item_desejo).setOnClickListener(view -> {
            startActivity(new Intent(ReservaActivity.this, DesejosActivity.class));
            popupWindowSubmenu.dismiss();
            fundo_escuro.setVisibility(View.GONE);
        });
    }

    private void carregarReservas(Cliente cliente) {
        apiService.listarReservasCliente(cliente).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<ReservaRequest>> call, @NonNull Response<List<ReservaRequest>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<ReservaRequest> reservas = response.body();
                    List<ReservaRequest> validas = new ArrayList<>();
                    for (ReservaRequest r : reservas) {
                        if (r.getTempoRestante() > 0) validas.add(r);
                    }
                    adapterReserva.updateList(validas);
                }

            }

            @Override
            public void onFailure(@NonNull Call<List<ReservaRequest>> call, @NonNull Throwable t) {
                Toast.makeText(ReservaActivity.this, "ATENÇÃO: Erro ao carregar reservas!", Toast.LENGTH_SHORT).show();
            }
        });
    }

}
