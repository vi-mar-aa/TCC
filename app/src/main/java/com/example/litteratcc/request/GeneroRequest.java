package com.example.litteratcc.request;

import com.google.gson.annotations.SerializedName;

public class GeneroRequest {
    @SerializedName("genero")
    private String generoMidia;

    public GeneroRequest(String generoMidia) {
        this.generoMidia = generoMidia;
    }

    // Getters e setters (opcional, mas recomendados)
    public String getGeneroMidia() {
        return generoMidia;
    }

    public void setGeneroMidia(String generoMidia) {
        this.generoMidia = generoMidia;
    }


}
