package com.example.litteratcc.modelo;

import android.content.Context;
import android.widget.Toast;

import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.service.RetrofitManager;

import java.util.Date;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
public class ListaDesejos {
    private int idCliente;
    private int idMidia;
  //  private String dataAdicionada;
    private Midia midia;

    public ListaDesejos(int idCliente, int idMidia) {
        this.idCliente = idCliente;
        this.idMidia = idMidia;
       // this.dataAdicionada = dataAdicionada;
    }
    public Midia getMidia() {
        return midia;
    }
    public int getIdCliente() { return idCliente; }
    public int getIdMidia() { return idMidia; }
   // public String getDataAdicionada() { return dataAdicionada; }
}

