package com.example.litteratcc.service;

import android.content.Context;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.OvershootInterpolator;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.RecyclerView;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;

import java.util.List;

public class CarrosselAdapter extends RecyclerView.Adapter<CarrosselAdapter.ViewHolder> {

    public interface OnItemActionListener {//mostra que se o usuário fizer isso acontece algo
        void onItemClick(Midia midia);
        void onItemLongClick(Midia midia);
        void onFavoritarClick(Midia item);
        void onReservarClick(Midia item);
    }

    private List<Midia> lista;
    private int itemWidth;
    private Context context;
    private OnItemActionListener listener;

    public CarrosselAdapter(List<Midia> lista, Context context, OnItemActionListener listener) {
        this.lista = lista;
        this.context = context;
        this.listener = listener;

        DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
        int screenWidth = displayMetrics.widthPixels;
        this.itemWidth = screenWidth / 4;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.layout_item_carrossel, parent, false);
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
        layoutParams.width = itemWidth;
        view.setLayoutParams(layoutParams);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        Midia item = lista.get(position);
        holder.tvTitulo.setText(item.getTitulo() + "," + item.getAnoPublicacao());
        holder.tvAutor.setText(item.getAutor());

        // Clique normal no item
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onItemClick(item);
            }
        });

        // Inicialmente esconder fundo
        holder.backgroundCinza.setAlpha(0f);
        holder.backgroundCinza.setVisibility(View.INVISIBLE);
        holder.backgroundCinza.setClickable(true); // permite clique fora

        // Inicialmente esconder botões com alpha 0 e scale reduzida
        holder.btnFavoritar.setAlpha(0f);
        holder.btnFavoritar.setScaleX(0.6f);
        holder.btnFavoritar.setScaleY(0.6f);
        holder.btnReservar.setAlpha(0f);
        holder.btnReservar.setScaleX(0.6f);
        holder.btnReservar.setScaleY(0.6f);

        // Long click para mostrar menu
        holder.itemView.setOnLongClickListener(v -> {
            Toast.makeText(context, "Ícone pressionado por muito tempo!", Toast.LENGTH_SHORT).show();
            listener.onItemLongClick(item);
            // Fundo escuro fade-in
            holder.backgroundCinza.setVisibility(View.VISIBLE);
            holder.backgroundCinza.animate()
                    .alpha(0.7f)
                    .setDuration(200)
                    .start();

            // Botão Favoritar fade + scale
            holder.btnFavoritar.setVisibility(View.VISIBLE);

            holder.btnFavoritar.animate()
                    .alpha(1f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .setInterpolator(new OvershootInterpolator())
                    .setDuration(250)
                    .start();

            // Botão Reservar fade + scale com atraso
            holder.btnReservar.setVisibility(View.VISIBLE);
            holder.btnReservar.animate()
                    .alpha(1f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .setStartDelay(100)
                    .setInterpolator(new OvershootInterpolator())
                    .setDuration(250)
                    .start();

            return true;
        });

        // Clique fora fecha menu
        holder.backgroundCinza.setOnClickListener(v -> {
            // Fundo fade-out
            holder.backgroundCinza.animate()
                    .alpha(0f)
                    .setDuration(200)
                    .withEndAction(() -> holder.backgroundCinza.setVisibility(View.GONE))
                    .start();

            holder.btnFavoritar.animate()
                    .alpha(0f)
                    .scaleX(0.6f)
                    .scaleY(0.6f)
                    .setDuration(200)
                    .withEndAction(() -> holder.btnFavoritar.setVisibility(View.GONE))
                    .start();

            holder.btnReservar.animate()
                    .alpha(0f)
                    .scaleX(0.6f)
                    .scaleY(0.6f)
                    .setDuration(200)
                    .withEndAction(() -> holder.btnReservar.setVisibility(View.GONE))
                    .start();

        });

        // Ações dos botões
        holder.btnFavoritar.setOnClickListener(v -> {
            Toast.makeText(context, "Você quer favoritar?", Toast.LENGTH_SHORT).show();
            if (listener != null) {
                listener.onFavoritarClick(item);
            }

        });

        holder.btnReservar.setOnClickListener(v -> {
            Toast.makeText(context, "Você quer reservar?", Toast.LENGTH_SHORT).show();
            if (listener != null) {
                item.setReservado(true); // marca o item como reservado

                listener.onReservarClick(item);
            }
        });
    }


    @Override
    public int getItemCount() {
        return lista.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        ImageView imageViewItem;
        TextView tvTitulo;
        TextView tvAutor;
        ImageButton btnFavoritar, btnReservar;
        View backgroundCinza;

        public ViewHolder(View itemView) {
            super(itemView);
            imageViewItem = itemView.findViewById(R.id.imgItem);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            btnFavoritar = itemView.findViewById(R.id.btnFavoritar);
            btnReservar = itemView.findViewById(R.id.btnReservar);
            backgroundCinza = itemView.findViewById(R.id.background_cinza);
        }
    }

    public void updateData(List<Midia> novaLista) {
        lista.clear();
        lista.addAll(novaLista);
        notifyDataSetChanged();
    }
}
