package com.example.litteratcc.request;

import com.example.litteratcc.modelo.Midia;
import com.google.gson.annotations.SerializedName;

public class RequestPesquisaAcervo {
    @SerializedName("searchText")
    private String searchText;
    @SerializedName("midia")
    private Midia midia;



    public RequestPesquisaAcervo(Midia midia,String searchText) {
        this.midia = midia;
        this.searchText = searchText;
    }

    public Midia getMidia() {
        return midia;
    }
    public void setMidia(Midia midia) {
        this.midia = midia;
    }
    public String getSearchText() {
        return searchText;
    }

    public void setSearchText(String searchText) {
        this.searchText = searchText;
    }
}
