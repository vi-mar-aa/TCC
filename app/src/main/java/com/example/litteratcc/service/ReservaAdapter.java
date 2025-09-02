package com.example.litteratcc.service;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;

import java.util.List;

public class ReservaAdapter extends RecyclerView.Adapter<ReservaAdapter.ReservaViewHolder> {

    private Context context;
    private List<Midia> midias;
    private OnReservaActionListener listener;

    // Interface para comunicação com a Activity
    public interface OnReservaActionListener {
        void onInfoClick(Midia midia);
    }

    public ReservaAdapter(Context context, List<Midia> midias) {
        this.context = context;
        this.midias = midias;

    }

    @NonNull
    @Override
    public ReservaViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_item_reserva, parent, false);
        return new ReservaViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ReservaViewHolder holder, int position) {
        Midia midia = midias.get(position);

        holder.tvTitulo.setText(midia.getTitulo());
        holder.tvAutor.setText(midia.getAutor());
        holder.tvPrazo.setText("Prazo: 20horas");

    }

    @Override
    public int getItemCount() {
        return midias.size();
    }

    public static class ReservaViewHolder extends RecyclerView.ViewHolder {
        TextView tvTitulo, tvAutor, tvPrazo;
        ImageView imgItem;


        public ReservaViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            imgItem = itemView.findViewById(R.id.imgItem);
            tvPrazo = itemView.findViewById(R.id.tvPrazo);
        }
    }
}
