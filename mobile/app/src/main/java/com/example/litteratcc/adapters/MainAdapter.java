package com.example.litteratcc.adapters;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.litteratcc.EspacoItem;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.request.GeneroRequest;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.ArrayList;
import java.util.List;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class MainAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final Context context;
    private final ApiService api;
    private final List<String> generos;
    private List<Integer> favoritosIds;
    private List<Integer> reservasIds;
    private final OnItemClickListener listener;
    //rvmain dividido em carrossel pop e de genero
    private static final int TYPE_POPULARES = 0;
    private static final int TYPE_GENERO = 1;

    public interface OnItemClickListener {
        void onItemClick(Midia midia);
        void onItemLongClick(Midia midia);
        void onFavoritarClick(Midia midia);
        void onDesfavoritarClick(Midia midia);
        void onReservarClick(Midia midia);
    }

    public MainAdapter(ApiService apiService, Context context, List<String> generos, OnItemClickListener listener, List<Integer> favoritosIds, List<Integer> reservasIds) {
        this.api = apiService;
        this.context = context;
        this.generos = generos;
        this.listener = listener;
        this.favoritosIds = (favoritosIds != null) ? favoritosIds : new ArrayList<>();
        this.reservasIds = (reservasIds != null) ? reservasIds : new ArrayList<>();
    }

    @Override
    public int getItemViewType(int position) {//que tipo de item na posição tal
        return position == 0 ? TYPE_POPULARES : TYPE_GENERO;
    }

    @Override
    public int getItemCount() {//quantos itens tem no total
        return generos.size() + 1; // +1 para o carrossel de populares
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(context);
        if (viewType == TYPE_POPULARES) {
            View view = inflater.inflate(R.layout.layout_item_populares, parent, false);
            return new PopularesViewHolder(view);
        } else {
            View view = inflater.inflate(R.layout.layout_item_genero, parent, false);
            return new GeneroViewHolder(view);
        }
    }

    @Override//colocando os dados
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {

        if (getItemViewType(position) == TYPE_POPULARES) {
            PopularesViewHolder vh = (PopularesViewHolder) holder;

            vh.rvCarrossel.setLayoutManager(new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false));
            vh.rvCarrossel.setNestedScrollingEnabled(false);//para evitar bug com o rv princ
            int spacingInPixels = context.getResources().getDimensionPixelSize(R.dimen.item_espaco);


            if (vh.rvCarrossel.getItemDecorationCount() == 0) {
                vh.rvCarrossel.addItemDecoration(new EspacoItem(spacingInPixels));
            }


            CarrosselMainAdapter popularesAdapter = new CarrosselMainAdapter(
                    new ArrayList<>(), context, new CarrosselMainAdapter.OnItemActionListener() {
                @Override
                public void onItemClick(Midia midia) {
                    listener.onItemClick(midia);
                }

                @Override
                public void onItemLongClick(Midia midia) {
                    listener.onItemLongClick(midia);
                }

                @Override
                public void onFavoritarClick(Midia midia) {
                    listener.onFavoritarClick(midia);
                }
               @Override
                public void onDesfavoritarClick(Midia midia) {
                    listener.onDesfavoritarClick(midia);
                }

                @Override
                public void onReservarClick(Midia midia) {
                    listener.onReservarClick(midia);
                }
            },favoritosIds,reservasIds);
            popularesAdapter.setFavoritosIds(this.favoritosIds);
            popularesAdapter.setReservasIds(this.reservasIds);
            vh.rvCarrossel.setAdapter(popularesAdapter);

            api.getMidiasPop().enqueue(new Callback<>() {
                @Override
                public void onResponse(@NonNull Call<List<Midia>> call, @NonNull Response<List<Midia>> response) {
                    int adapterPos = vh.getAdapterPosition();
                    if (adapterPos == RecyclerView.NO_POSITION) return;

                    if (response.isSuccessful() && response.body() != null) {
                        atualizarCarrosselComFavoritosEReservas(popularesAdapter, response.body());
                    }
                }

                @Override
                public void onFailure(@NonNull Call<List<Midia>> call, @NonNull Throwable t) {
                    Log.e("API", "Erro ao buscar populares: " + t.getMessage());
                }
            });

        } else {
            GeneroViewHolder vh = (GeneroViewHolder) holder;

            int currentPos = vh.getAdapterPosition();
            if (currentPos == RecyclerView.NO_POSITION) return;

            String genero = generos.get(currentPos - 1);//item 0 é pop, item 1 é o 0 da lista de generos
            vh.tvHeader.setText(genero);

            vh.rvCarrossel.setLayoutManager(new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false));
            vh.rvCarrossel.setNestedScrollingEnabled(false);
            int spacingInPixels = context.getResources().getDimensionPixelSize(R.dimen.item_espaco);
            if (vh.rvCarrossel.getItemDecorationCount() == 0) {
                vh.rvCarrossel.addItemDecoration(new EspacoItem(spacingInPixels));
            }



            CarrosselMainAdapter midiaAdapter = new CarrosselMainAdapter(
                    new ArrayList<>(), context, new CarrosselMainAdapter.OnItemActionListener() {
                @Override
                public void onItemClick(Midia midia) {
                    listener.onItemClick(midia);
                }

                @Override
                public void onItemLongClick(Midia midia) {
                    listener.onItemLongClick(midia);
                }

                @Override
                public void onFavoritarClick(Midia midia) {
                    listener.onFavoritarClick(midia);
                }
                @Override
                public void onDesfavoritarClick(Midia midia) {
                    listener.onDesfavoritarClick(midia);
                }


                @Override
                public void onReservarClick(Midia midia) {
                    listener.onReservarClick(midia);
                }
            },favoritosIds,reservasIds);
            midiaAdapter.setFavoritosIds(this.favoritosIds);
            midiaAdapter.setReservasIds(this.reservasIds);
            vh.rvCarrossel.setAdapter(midiaAdapter);

            Gson gson = new GsonBuilder().serializeNulls().create();

            String generoMidia = genero.replace(" ", "");//tira o espaço pq a api nn reconhece com
            GeneroRequest request = new GeneroRequest(generoMidia);
            String json = gson.toJson(request);
            Log.d("midia_genero", json);
            api.listarMidiasPorGenero(request).enqueue(new Callback<>() {
                @Override
                public void onResponse(@NonNull Call<List<Midia>> call, @NonNull Response<List<Midia>> response) {
                    int adapterPos = vh.getAdapterPosition();
                    if (adapterPos == RecyclerView.NO_POSITION) return;

                    if (response.isSuccessful() && response.body() != null) {
                        atualizarCarrosselComFavoritosEReservas(midiaAdapter, response.body());
                    }
                }

                @Override
                public void onFailure(@NonNull Call<List<Midia>> call, @NonNull Throwable t) {
                    Log.e("carrossel_genero", "Erro ao buscar mídias por gênero: " + t.getMessage());
                }
            });
        }
    }



    public static class PopularesViewHolder extends RecyclerView.ViewHolder {
        RecyclerView rvCarrossel;

        public PopularesViewHolder(@NonNull View itemView) {
            super(itemView);
            rvCarrossel = itemView.findViewById(R.id.rvPopulares);
        }
    }


    public static class GeneroViewHolder extends RecyclerView.ViewHolder {
        TextView tvHeader;
        RecyclerView rvCarrossel;

        public GeneroViewHolder(@NonNull View itemView) {
            super(itemView);
            tvHeader = itemView.findViewById(R.id.tvHeader);
            rvCarrossel = itemView.findViewById(R.id.rvCarrossel);
        }
    }
    public void setFavoritosIds(List<Integer> lista) {
        this.favoritosIds = (lista != null) ? lista : new ArrayList<>();
        notifyDataSetChanged();

    }
    public void setReservasIds(List<Integer> lista) {
        this.reservasIds = (lista != null) ? lista : new ArrayList<>();
        notifyDataSetChanged();
    }
    private void atualizarCarrosselComFavoritosEReservas(CarrosselMainAdapter adapter, List<Midia> midias) {
        adapter.updateList(midias);
        adapter.setFavoritosIds(this.favoritosIds);
        adapter.setReservasIds(this.reservasIds);
    }

}
