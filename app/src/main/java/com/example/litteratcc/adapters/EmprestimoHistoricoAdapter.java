package com.example.litteratcc.adapters;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.OvershootInterpolator;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.request.EmprestimoRequest;
import com.example.litteratcc.service.RetrofitManager;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class EmprestimoHistoricoAdapter extends RecyclerView.Adapter<EmprestimoHistoricoAdapter.EmprestimoHistoricoViewHolder>{
    private List<EmprestimoRequest> midias;
    private EmprestimoHistoricoAdapter.OnItemActionListener listener;
    private Context context;

    public interface OnItemActionListener {
        void onItemClick(EmprestimoRequest emprestimo);
    }

    public EmprestimoHistoricoAdapter(List<EmprestimoRequest> midias, Context context, EmprestimoHistoricoAdapter.OnItemActionListener listener) {
        this.midias = midias;
        this.context = context;
        this.listener = listener;
    }

    @NonNull
    @Override
    public EmprestimoHistoricoAdapter.EmprestimoHistoricoViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.layout_item_emprestimo_historico, parent, false);
        return new EmprestimoHistoricoAdapter.EmprestimoHistoricoViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull EmprestimoHistoricoAdapter.EmprestimoHistoricoViewHolder holder, int position) {
        EmprestimoRequest emprestimo = midias.get(position);
        holder.tvTitulo.setText(emprestimo.getMidia().getTitulo()+","+emprestimo.getMidia().getAnoPublicacao());
        holder.tvAutor.setText(emprestimo.getMidia().getAutor());
        //FORMATAÇÃO BONITINHA DA DATA
        try {
            String dtEmprestimo = emprestimo.getEmprestimo().getDtEmprestimo();
            String dtDevolucao = emprestimo.getEmprestimo().getDtDevolucao();

            SimpleDateFormat entrada = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
            SimpleDateFormat saida   = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());

            Date dateEmpr = entrada.parse(dtEmprestimo);
            Date dateDev  = entrada.parse(dtDevolucao); // corrigido

            String dtEmprestimoFormatada = saida.format(dateEmpr);
            String dtDevolucaoFormatada  = saida.format(dateDev);

            holder.tvDtEmprestimo.setText("Data do empréstimo: " + dtEmprestimoFormatada);
            holder.tvDtDevolucao.setText("Data da devolução: " + dtDevolucaoFormatada);

        } catch (ParseException e) {
            e.printStackTrace();
            // opcional: mostrar mensagem de erro ou valor padrão
            holder.tvDtEmprestimo.setText("Data do empréstimo: inválida");
            holder.tvDtDevolucao.setText("Data da devolução: inválida");
        }
        String caminhoImagem = emprestimo.getMidia().getImagem();
          String fullUrl = RetrofitManager.getUrl() + caminhoImagem;

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

        holder.itemView.setOnClickListener(v -> listener.onItemClick(emprestimo));
    }

    @Override
    public int getItemCount() {
        return midias.size();
    }

    public static class EmprestimoHistoricoViewHolder extends RecyclerView.ViewHolder {
        TextView tvTitulo, tvAutor, tvDtEmprestimo,tvDtDevolucao;
        ImageView imgItem;

        public EmprestimoHistoricoViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            tvDtEmprestimo = itemView.findViewById(R.id.tvDtEmprestimo);
            tvDtDevolucao = itemView.findViewById(R.id.tvDtDevolucao);
            imgItem = itemView.findViewById(R.id.imgItem);
        }
    }

    public void updateList(List<EmprestimoRequest> historicoAtualizadoEmprestimos) {
        midias.clear();
        midias.addAll(historicoAtualizadoEmprestimos);
        notifyDataSetChanged();
    }
    private boolean isTouchInsideView(View view, float rawX, float rawY) {
        int[] location = new int[2];
        view.getLocationOnScreen(location);
        float viewX = location[0];
        float viewY = location[1];
        return (rawX >= viewX && rawX <= (viewX + view.getWidth()) &&
                rawY >= viewY && rawY <= (viewY + view.getHeight()));
    }


}

