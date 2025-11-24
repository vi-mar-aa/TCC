package com.example.litteratcc.request;

import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.google.gson.annotations.SerializedName;

public class FavoritoRequest {
    private ListaDesejos listaDesejos;
    private Cliente cliente;
    private Midia midia;

    public FavoritoRequest(ListaDesejos listaDesejos, Cliente cliente, Midia midia) {
        this.listaDesejos = listaDesejos;
        this.cliente = cliente;
        this.midia = midia;
    }

    public ListaDesejos getListaDesejos() { return listaDesejos; }
    public Cliente getCliente() { return cliente; }
    public Midia getMidia() { return midia; }
}
