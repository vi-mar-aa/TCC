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
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.request.EmprestimoRequest;
import com.example.litteratcc.request.RenovacaoRequest;
import com.example.litteratcc.service.RetrofitManager;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class EmprestimoAtuaisAdapter extends RecyclerView.Adapter<EmprestimoAtuaisAdapter.EmprestimoAtuaisViewHolder>{
    private List<EmprestimoRequest> midias;
    private EmprestimoAtuaisAdapter.OnItemActionListener listener;
    private Context context;

    public interface OnItemActionListener {
        void onItemClick(EmprestimoRequest emprestimo);
        void onItemRenovarClick(EmprestimoRequest emprestimo);
    }



    public EmprestimoAtuaisAdapter(List<EmprestimoRequest> midias, Context context, EmprestimoAtuaisAdapter.OnItemActionListener listener) {
        this.midias = midias;
        this.context = context;
        this.listener = listener;
    }

    @NonNull
    @Override
    public EmprestimoAtuaisAdapter.EmprestimoAtuaisViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.layout_item_emprestimo_atuais, parent, false);
        return new EmprestimoAtuaisAdapter.EmprestimoAtuaisViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull EmprestimoAtuaisAdapter.EmprestimoAtuaisViewHolder holder, int position) {
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
        if(emprestimo.getValorMulta()>0){
            holder.tvMulta.setVisibility(View.VISIBLE);
            holder.tvMulta.setText("Multa atual: R$ "+emprestimo.getValorMulta()+",00");
        }else{
            holder.tvMulta.setVisibility(View.INVISIBLE);
        }
        int renovacoesRestantes = emprestimo.getEmprestimo().getNumRenovacoes();

// se não pode renovar
        if (renovacoesRestantes <= 0) {
            holder.tvNumDevolucoes.setText("Atenção! Não é possível\nrenovar este empréstimo.");

            holder.btnRenovar.animate()
                    .scaleX(0f)//btn volta pro tamanho normal
                    .scaleY(0f)
                    .setDuration(250)
                    .start();
            holder.btnRenovar.setVisibility(View.INVISIBLE); // mesma altura para todos
        }
        else {
            holder.btnRenovar.setVisibility(View.VISIBLE);

            if (renovacoesRestantes == 1) {
                holder.tvNumDevolucoes.setText("Atenção! Você possui 1\nrenovação restante.");
            }
            else {
                holder.tvNumDevolucoes.setText("Atenção! Você possui "
                        + renovacoesRestantes + "\nrenovações restantes.");
            }
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
            Log.e("JOANA_DEBUG", "Caminho completo da imagem: " + fullUrl);

        }

        holder.imgItem.setOnClickListener(v -> listener.onItemClick(emprestimo));

        holder.btnRenovar.setOnClickListener(v -> {
            listener.onItemRenovarClick(emprestimo);
        });
    }

    @Override
    public int getItemCount() {
        return midias.size();
    }

    public static class EmprestimoAtuaisViewHolder extends RecyclerView.ViewHolder {
        TextView tvTitulo, tvAutor, tvDtEmprestimo,tvDtDevolucao,tvNumDevolucoes, tvMulta;
        ImageView imgItem;
        LinearLayout btnRenovar;

        public EmprestimoAtuaisViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            tvDtEmprestimo = itemView.findViewById(R.id.dtEmprestimo);
            tvDtDevolucao = itemView.findViewById(R.id.dtDevolucao);
            imgItem = itemView.findViewById(R.id.imgItem);
            tvNumDevolucoes = itemView.findViewById(R.id.tvNumDevolucoes);
            btnRenovar = itemView.findViewById(R.id.btnRenovar);
            tvMulta = itemView.findViewById(R.id.tvMulta);
        }
    }

    public void updateList(List<EmprestimoRequest> novosEmprestimos) {
        midias.clear();
        midias.addAll(novosEmprestimos);
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

