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
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.bumptech.glide.Glide;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.modelo.Reserva;
import com.example.litteratcc.request.ReservaRequest;
import com.example.litteratcc.service.RetrofitManager;

import java.text.DateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Handler;

public class ReservaAdapter extends RecyclerView.Adapter<com.example.litteratcc.adapters.ReservaAdapter.ReservaViewHolder> {

        private List<ReservaRequest> lista;
        private com.example.litteratcc.adapters.ReservaAdapter.OnItemActionListener listener;

        Context context;

        private final List<com.example.litteratcc.adapters.ReservaAdapter.ReservaViewHolder> menusAbertos = new ArrayList<>();


        public ReservaAdapter(Context context,List<ReservaRequest> lista, com.example.litteratcc.adapters.ReservaAdapter.OnItemActionListener listener) {
            this.context =context;
            this.lista = lista;
            this.listener = listener;
        }
        public interface OnItemActionListener {
            void onItemClick(ReservaRequest reserva);

        }

        @NonNull
        @Override
        public com.example.litteratcc.adapters.ReservaAdapter.ReservaViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.layout_item_reserva, parent, false);
            return new com.example.litteratcc.adapters.ReservaAdapter.ReservaViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull com.example.litteratcc.adapters.ReservaAdapter.ReservaViewHolder holder, int position) {
            ReservaRequest reserva = lista.get(position);
            Midia midia = reserva.getMidia();

            holder.tvTitulo.setText(midia.getTitulo());
            holder.tvAutor.setText(midia.getAutor());
            int prazoEmDias = reserva.getTempoRestante();
            Log.e("tempo", "temporestante: " + prazoEmDias);
            if(prazoEmDias==1){
                holder.tvPrazo.setText("Resta "+prazoEmDias+" dia!");
            }else{
            holder.tvPrazo.setText("Restam "+prazoEmDias+" dias!");}
            String caminhoImagem = midia.getImagem();
            String fullUrl = RetrofitManager.getUrl() + caminhoImagem;

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
            holder.itemView.setOnClickListener(v -> listener.onItemClick(reserva));


        }

        @Override
        public int getItemCount() {
            return lista.size();
        }

        public void updateList(List<ReservaRequest> novasReservas) {
            lista.clear();
            lista.addAll(novasReservas);
            notifyDataSetChanged();
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
