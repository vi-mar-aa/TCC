package com.example.litteratcc.service;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;

import java.util.List;

public class ListaDesejoAdapter extends RecyclerView.Adapter<ListaDesejoAdapter.ViewHolder> {

    private Context context;
    private List<Midia> midias;
    private ListaDesejoAdapter.OnListaDesejoActionListener listener;

    public interface OnListaDesejoActionListener {
        void onItemClick(Midia midia);
        void onDeletarClick(Midia midia);
    }


    public ListaDesejoAdapter(Context context, List<Midia> midias, OnListaDesejoActionListener listener) {
        this.context = context;
        this.midias = midias;
        this.listener = listener;

    }


    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.layout_item_desejo, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Midia midia = midias.get(position);
        holder.tvTitulo.setText(midia.getTitulo() + ", " + midia.getAnoPublicacao());
        holder.tvAutor.setText(midia.getAutor());

        holder.btnInformacao.setOnClickListener(v -> {
            if (listener != null) listener.onItemClick(midia);
        });

        holder.btnDelete.setOnClickListener(v -> {
            Toast.makeText(context, "Você quer deletar?", Toast.LENGTH_SHORT).show();
            if (listener != null) listener.onDeletarClick(midia);
            midias.remove(midia);
            notifyDataSetChanged();
        });
    }

    @Override
    public int getItemCount() {
        return midias.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        ImageView imageViewItem;
        TextView tvTitulo, tvAutor, btnInformacao;
        ImageButton btnDelete;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            imageViewItem = itemView.findViewById(R.id.imgItem);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            btnInformacao = itemView.findViewById(R.id.btnInformacao);
            btnDelete = itemView.findViewById(R.id.btnDelete);
        }
    }
}
