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
import com.example.litteratcc.activities.MidiaActivity;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.RetrofitManager;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class CarrosselMainAdapter extends RecyclerView.Adapter<CarrosselMainAdapter.CarrosselMainViewHolder> {
    private final List<Midia> midias;
    private List<Integer> favoritosIds;
    private List<Integer> reservasIds;
    private final OnItemActionListener listener;
    private final Context context;


    public interface OnItemActionListener {
        void onItemClick(Midia midia);
        void onItemLongClick(Midia midia);
        void onFavoritarClick(Midia midia);
        void onDesfavoritarClick(Midia midia);
        void onReservarClick(Midia midia);
    }

    public CarrosselMainAdapter(List<Midia> midias, Context context, OnItemActionListener listener, List<Integer> favoritosIds, List<Integer> reservasIds) {
        this.midias = midias;
        this.context = context;
        this.listener = listener;
        this.favoritosIds = (favoritosIds != null) ? favoritosIds : new ArrayList<>();
        this.reservasIds = (reservasIds != null) ? reservasIds : new ArrayList<>();
    }

    @NonNull
    @Override
    public CarrosselMainViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.layout_item_carrossel, parent, false);
        return new CarrosselMainViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull CarrosselMainViewHolder holder, int position) {
        Midia midia = midias.get(position);
        holder.tvTitulo.setText(midia.getTitulo());
        holder.tvAutor.setText(midia.getAutor());

        String caminhoImagem = midia.getImagem();
        Log.e("VERIFICACAMINHO", "Item: " + midia.getTitulo() + " | Caminho imagem: " + midia.getImagem());
        String fullUrl = RetrofitManager.getUrl() + caminhoImagem;
        Log.e("CAMINHOCOMPLETO", "Item: " + midia.getTitulo() + " | Caminho imagem: " + fullUrl);

        Log.e("DEBUGBIND", "onBind ta sendo chamado");
        if (caminhoImagem == null || caminhoImagem.isEmpty()) {
            // Colocar imagem de placeholder local
            Glide.with(context)
                    .load(R.drawable.img_livro_teste)
                    .into(holder.imgItem);
            Log.e("DEBUGNULL", "caminho nulo");
        } else {

            Glide.with(context)
                    .load(Uri.parse(fullUrl).toString())
                    .placeholder(R.drawable.img_livro_teste)
                    .error(R.drawable.img_livro_teste)
                    .into(holder.imgItem);
            Log.e("JOANA_DEBUG", "Caminho completo da imagem: " + fullUrl);

        }
        boolean isFavorito = favoritosIds.contains(midia.getIdMidia());
        boolean isReservado = reservasIds.contains(midia.getIdMidia());

        holder.btnFavoritar.setImageResource(isFavorito ? R.drawable.icon_favoritado : R.drawable.icon_desejo);
        holder.btnReservar.setImageResource(isReservado ? R.drawable.icon_reservado : R.drawable.icon_reservar);

        holder.itemView.setOnClickListener(v -> {
            if (holder.menuAberto) {
                return;// não faz nada quando o menu esta aberto
            }
            listener.onItemClick(midia);
        });

        holder.backgroundCinza.setAlpha(0f);
        holder.backgroundCinza.setVisibility(View.INVISIBLE);
        holder.backgroundCinza.setClickable(true); // deixa clique fora

        // esconde todos os btns
        holder.btnFavoritar.setAlpha(0f);
        holder.btnFavoritar.setScaleX(0.6f);
        holder.btnFavoritar.setScaleY(0.6f);
        holder.btnReservar.setAlpha(0f);
        holder.btnReservar.setScaleX(0.6f);
        holder.btnReservar.setScaleY(0.6f);


        holder.itemView.setOnLongClickListener(v -> {
            listener.onItemLongClick(midia);
            holder.menuAberto = true;

            //atualiza icon btns
            holder.btnFavoritar.setImageResource(favoritosIds.contains(midia.getIdMidia()) ? R.drawable.icon_favoritado : R.drawable.icon_desejo);
            holder.btnReservar.setImageResource(reservasIds.contains(midia.getIdMidia()) ? R.drawable.icon_reservado : R.drawable.icon_reservar);

            if (context instanceof MidiaActivity) {//verifica se tá na midiaactivity(onde tem o scroll)
                RecyclerView rv = ((MidiaActivity) context).findViewById(R.id.rvMidiasSimilares);
                rv.requestDisallowInterceptTouchEvent(true);//o scoll nn interfere nas interações com carrossel
            }

            holder.backgroundCinza.setVisibility(View.VISIBLE);
            holder.backgroundCinza.setClickable(false);
            holder.backgroundCinza.animate().alpha(0.7f).setDuration(200)
                    .withEndAction(() -> holder.backgroundCinza.setClickable(true))
                    .start();

            holder.btnFavoritar.setVisibility(View.VISIBLE);
            holder.btnFavoritar.animate()
                    .alpha(1f).scaleX(1f).scaleY(1f)
                    .setInterpolator(new OvershootInterpolator())//faz o boing sutil
                    .setDuration(250).start();

            holder.btnReservar.setVisibility(View.VISIBLE);
            holder.btnReservar.animate()
                    .alpha(1f).scaleX(1f).scaleY(1f)
                    .setStartDelay(100)//atrasa um pouco para o btnFav aparecer primeiro
                    .setInterpolator(new OvershootInterpolator())
                    .setDuration(250).start();

            return true;
        });

        holder.backgroundCinza.setOnClickListener(v -> {
            if (holder.menuAberto && holder.backgroundCinza.isClickable()) {
                fecharMenu(holder);

                if (context instanceof MidiaActivity) {
                    RecyclerView rv = ((MidiaActivity) context).findViewById(R.id.rvMidiasSimilares);
                    rv.setOnTouchListener(null);
                }
            }
           // Toast.makeText(context, "vc clicou na parte cinza", Toast.LENGTH_SHORT).show();
        });



        holder.btnFavoritar.setOnClickListener(v -> {

            if (listener != null) {
                if(favoritosIds.contains(midia.getIdMidia())){
                    listener.onDesfavoritarClick(midia);
                } else {
                    listener.onFavoritarClick(midia);
                }
                fecharMenu(holder);

            }else{
                Toast.makeText(context, "voltou nulo", Toast.LENGTH_SHORT).show();
            }


        });

        holder.btnReservar.setOnClickListener(v -> {

            if (listener != null) {
                if(reservasIds.contains(midia.getIdMidia())){
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
                        listener.onReservarClick(midia);
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
        return midias.size();
    }
    public static class CarrosselMainViewHolder extends RecyclerView.ViewHolder {
        TextView tvTitulo, tvAutor, btnInformacao;
        ImageView imgItem;
        ImageButton btnFavoritar, btnReservar;
        View backgroundCinza;
        boolean menuAberto = false;

        public CarrosselMainViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitulo = itemView.findViewById(R.id.tvTitulo);
            tvAutor = itemView.findViewById(R.id.tvAutor);
            btnInformacao = itemView.findViewById(R.id.btnInformacao);
            btnFavoritar = itemView.findViewById(R.id.btnFavoritar);
            btnReservar = itemView.findViewById(R.id.btnReservar);
            imgItem = itemView.findViewById(R.id.imgItem);
            backgroundCinza = itemView.findViewById(R.id.background_cinza);

        }
    }
    public void updateList(List<Midia> novasMidias) {
        this.midias.clear();
        this.midias.addAll(novasMidias);
        notifyDataSetChanged();
    }
    public void setFavoritosIds(List<Integer> lista) {
        this.favoritosIds = (lista != null) ? lista : new ArrayList<>();
        notifyDataSetChanged();
    }
    public void setReservasIds(List<Integer> lista) {
        this.reservasIds = (lista != null) ? lista : new ArrayList<>();
        notifyDataSetChanged();
    }
    private void fecharMenu(CarrosselMainViewHolder holder) {

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

        holder.menuAberto = false;
    }

}
