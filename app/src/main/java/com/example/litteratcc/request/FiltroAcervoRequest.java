package com.example.litteratcc.request;

import com.example.litteratcc.modelo.Midia;
import com.google.gson.annotations.SerializedName;

import java.util.List;
public class FiltroAcervoRequest {
          // busca por título, autor etc.
    private String tipo;          // tipo de mídia (obrigatório)
    private List<String> generos; // lista de gêneros (opcional)
    private List<String> anos;    // lista de anos (opcional)

    public String getTipo() {
        return tipo;
    }
    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
    public List<String> getGeneros() {
        return generos;
    }
    public void setGeneros(List<String> generos) {
        this.generos = generos;
    }
    public List<String> getAnos() {
        return anos;
    }
    public void setAnos(List<String> anos) {
        this.anos = anos;
    }



}
