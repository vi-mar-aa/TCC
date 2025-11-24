package com.example.litteratcc.adapters;


import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.OvershootInterpolator;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.RetrofitManager;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class FavoritosAdapter extends RecyclerView.Adapter<FavoritosAdapter.FavoritosViewHolder> {

    private List<ListaDesejos> lista;
    private List<Integer> listaReservados;
    private OnItemActionListener listener;
    RetrofitManager apiService;
    Context context;

    private final List<FavoritosAdapter.FavoritosViewHolder> menusAbertos = new ArrayList<>();
    public interface OnItemActionListener {
        void onItemClick(Midia desejo);
        void onItemLongClick(Midia desejo);
        void onDeletarClick(Midia desejo);
         void onReservarClick(ListaDesejos desejo);
    }

    public FavoritosAdapter(Context context,List<ListaDesejos> lista, OnItemActionListener listener,List<Integer> listaReservados) {
        this.context =context;
        this.lista = lista;
        this.listener = listener;
        this.listaReservados = (listaReservados != null) ? listaReservados : new ArrayList<>();
    }

    @NonNull
    @Override
    public FavoritosViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.layout_item_desejo, parent, false);
        return new FavoritosViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull FavoritosViewHolder holder, int position) {
        ListaDesejos desejo = lista.get(position);
        Midia midia = desejo.getMidia();

        holder.tvTitulo.setText(midia.getTitulo());
        holder.tvAutor.setText(midia.getAutor());

        String caminhoImagem = midia.getImagem();
        String fullUrl = RetrofitManager.getUrl() + caminhoImagem;
        Log.e("Adapter", "onBindViewHolder chamado para item: " + midia.getTitulo());
        Log.e("Url", "fullUrl: " + fullUrl);
        if(context!=null)
        if (caminhoImagem == null || caminhoImagem.isEmpty()) {
            // Colocar imagem de placeholder local
            Glide.with(context)
                    .load(R.drawable.img_livro_teste)
                    .into(holder.imgItem);
        } else {

            Glide.with(context)
                    .load(Uri.parse(fullUrl).toString())
                    .placeholder(R.drawable.img_livro_teste)
                    .error(R.drawable.img_livro_teste)
                    .into(holder.imgItem);
        }
        boolean isReservado = listaReservados.contains(midia.getIdMidia());
        holder.btnReservar.setImageResource(isReservado ? R.drawable.icon_reservado : R.drawable.icon_reservar);
        holder.itemView.setOnClickListener(v -> listener.onItemClick(desejo.getMidia()));
        holder.itemView.setOnLongClickListener(v -> {
            listener.onItemLongClick(desejo.getMidia());
            return true;
        });
        holder.background_cinza.setAlpha(0f);
        holder.background_cinza.setVisibility(View.INVISIBLE);
        holder.background_cinza.setClickable(true);
        holder.btnDelete.setAlpha(0f);
        holder.btnDelete.setScaleX(0.6f);
        holder.btnDelete.setScaleY(0.6f);
        holder.btnReservar.setAlpha(0f);
        holder.btnReservar.setScaleX(0.6f);
        holder.btnReservar.setScaleY(0.6f);
        holder.itemView.setTag(false);



        holder.itemView.setOnLongClickListener(v -> {
            listener.onItemLongClick(desejo.getMidia());
            holder.btnReservar.setImageResource(listaReservados.contains(midia.getIdMidia()) ? R.drawable.icon_reservado : R.drawable.icon_reservar);

            holder.background_cinza.setVisibility(View.VISIBLE);
            holder.background_cinza.animate()
                    .alpha(0.7f)
                    .setDuration(200)
                    .start();


            holder.btnDelete.setVisibility(View.VISIBLE);

            holder.btnDelete.animate()
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

        // Clique no fundo cinza
        holder.background_cinza.setOnClickListener(v -> fecharMenu(holder));

        // Favoritar
        holder.btnDelete.setOnClickListener(v -> {

            int pos = holder.getAdapterPosition();
            if (pos != RecyclerView.NO_POSITION) {
                listener.onDeletarClick(desejo.getMidia());

                // remove da lista
                lista.remove(pos);

                // notifica que o item foi removido
                notifyItemRemoved(pos);

                // opcional: atualiza as posições dos demais
                notifyItemRangeChanged(pos, lista.size());
            }
        });

        holder.btnReservar.setOnClickListener(v -> {

            if (listener != null) {
                if(listaReservados.contains(midia.getIdMidia())){
                    Toast.makeText(context, "ATENÇÃO: Esta mídia já foi reservada!", Toast.LENGTH_SHORT).show();
                }else{
                    LayoutInflater inflater = LayoutInflater.from(context);
                    View popupView = inflater.inflate(R.layout.popup_reserva, null);
                    AlertDialog.Builder builder = new AlertDialog.Builder(context);
                    builder.setView(popupView);
                    AlertDialog dialog = builder.create();
                    Objects.requireNonNull(dialog.getWindow()).setBackgroundDrawableResource(android.R.color.transparent);
                    dialog.show();
                    LinearLayout btnFechar = popupView.findViewById(R.id.btnFechar);
                    btnFechar.setOnClickListener(v1 -> {
                        listener.onReservarClick(desejo);
                        dialog.dismiss();
                    });
                }
                fecharMenu(holder);
            }else{
                Toast.makeText(context, "voltou nulo", Toast.LENGTH_SHORT).show();
            }

        });
    }

    @Override
    public int getItemCount() {
        return lista.size();
    }

    public void updateList(List<ListaDesejos> novosDesejos) {
        lista.clear();
        lista.addAll(novosDesejos);
        notifyDataSetChanged();
    }

    public static class FavoritosViewHolder extends RecyclerView.ViewHolder {
        TextView tvTitulo, tvAutor, btnInformacao;
        ImageView imgItem;
        View background_cinza;
        ImageButton btnDelete, btnReservar;

        public FavoritosViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            imgItem = itemView.findViewById(R.id.imgItem);
            btnDelete = itemView.findViewById(R.id.btnDelete);
            btnReservar = itemView.findViewById(R.id.btnReservar);
            btnInformacao = itemView.findViewById(R.id.btnInformacao);
            background_cinza = itemView.findViewById(R.id.background_cinza);

        }
    }
    private void fecharMenu(FavoritosAdapter.FavoritosViewHolder holder) {
        holder.background_cinza.setAlpha(0f);
        holder.background_cinza.setVisibility(View.INVISIBLE);
        holder.background_cinza.setAlpha(0f);
        holder.background_cinza.setScaleX(0.6f);
        holder.background_cinza.setScaleY(0.6f);
        holder.btnReservar.setAlpha(0f);
        holder.btnReservar.setScaleX(0.6f);
        holder.btnReservar.setScaleY(0.6f);
        holder.btnDelete.setAlpha(0f);
        holder.btnDelete.setScaleX(0.6f);
        holder.btnDelete.setScaleY(0.6f);
        holder.itemView.setTag(false);
        menusAbertos.remove(holder);
    }

    public void setReservasIds(List<Integer> lista) {
        this.listaReservados = (lista != null) ? lista : new ArrayList<>();
        notifyDataSetChanged();
    }
}
