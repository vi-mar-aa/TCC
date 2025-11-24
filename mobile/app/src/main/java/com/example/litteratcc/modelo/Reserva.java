package com.example.litteratcc.modelo;

import com.google.gson.annotations.SerializedName;

public class Reserva {
@SerializedName("idReserva")
    private int idReserva;
    @SerializedName("dataReserva")
    private String dtReserva;
    @SerializedName("dataLimite")
    private String dtLimite;
    @SerializedName("statusReserva")
    private String statusReserva;

    private Midia midia;


    public Midia getMidia() {
        return midia;
    }
    public int getIdReserva() {
        return idReserva;
    }
    public String getDtReserva() {
        return dtReserva;
    }
    public String getDtLimite() {
        return dtLimite;
    }
    public String getStatusReserva() {
        return statusReserva;
    }

}
