package com.example.litteratcc.modelo;

import android.content.Context;
import android.widget.Toast;

import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.RetrofitManager;

import java.util.Date;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
public class ListaDeDesejos {
    private int idCliente;
    private Midia midia;
    private Date dtAdicionada;

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public Midia getMidia() { return midia; }
    public void setMidia(Midia midia) { this.midia = midia; }

    public Date getDtAdicionada() { return dtAdicionada; }
    public void setDtAdicionada(Date dtAdicionada) { this.dtAdicionada = dtAdicionada; }

    // Interface do listener
    public interface OnCheckFavoritoListener {
        void onResult(boolean isFavorito);
    }

    // Verifica se já está favoritado
    public void verificaFavoritado(Midia midia, Context context, OnCheckFavoritoListener listener) {
        ApiService apiService = RetrofitManager.getApiService();
        Call<ListaDeDesejos> call = apiService.getFavoritado(Integer.parseInt(midia.getIdMidia()));
        call.enqueue(new Callback<ListaDeDesejos>() {
            @Override
            public void onResponse(Call<ListaDeDesejos> call, Response<ListaDeDesejos> response) {
                if (!response.isSuccessful() || response.body() == null) {
                    listener.onResult(false); // não está favoritado
                    return;
                }
                listener.onResult(true); // já está favoritado
            }

            @Override
            public void onFailure(Call<ListaDeDesejos> call, Throwable t) {
                Toast.makeText(context, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                listener.onResult(false);
            }
        });
    }

    // Favorita o item, chamando a verificação antes
    public void favoritar(Midia midia, Context context) {
        verificaFavoritado(midia, context, isFavorito -> {
            if (isFavorito) {
                Toast.makeText(context, "Item já foi favoritado!", Toast.LENGTH_SHORT).show();
            } else {
                ApiService apiService = RetrofitManager.getApiService();
                Call<Midia> call = apiService.favoritarMidia(midia);
                call.enqueue(new Callback<Midia>() {
                    @Override
                    public void onResponse(Call<Midia> call, Response<Midia> response) {
                        if (!response.isSuccessful()) {
                            Toast.makeText(context, "Erro ao favoritar: " + response.code(), Toast.LENGTH_SHORT).show();
                            return;
                        }
                        Toast.makeText(context, "Item favoritado com sucesso!", Toast.LENGTH_SHORT).show();
                    }

                    @Override
                    public void onFailure(Call<Midia> call, Throwable t) {
                        Toast.makeText(context, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });
    }

    // Deleta um item favorito
    public void deleteFavorito(Midia midia, Context context) {
        ApiService apiService = RetrofitManager.getApiService();
        Call<Void> call = apiService.deleteFavorito(Integer.parseInt(midia.getIdMidia()));
        call.enqueue(new Callback<Void>() {
            @Override
            public void onResponse(Call<Void> call, Response<Void> response) {
                if (!response.isSuccessful()) return;
                Toast.makeText(context, "Item deletado com sucesso!", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onFailure(Call<Void> call, Throwable t) {
                Toast.makeText(context, "Erro: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
}
