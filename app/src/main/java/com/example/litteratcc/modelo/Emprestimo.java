package com.example.litteratcc.modelo;

import com.google.gson.annotations.SerializedName;

public class Emprestimo {
    @SerializedName("idEmprestimo")
    private int idEmprestimo;
    @SerializedName("idCliente")
    private int idUser;
    @SerializedName("idMidia")
    private int idMidia;
    @SerializedName("id_reserva")
    private int idReserva;
    @SerializedName("dataEmprestimo")
    private String dtEmprestimo;
    @SerializedName("dataDevolucao")
    private String dtDevolucao;
    @SerializedName("limiteRenovacoes")
    private int numRenovacoes;
    @SerializedName("titulo")
    private String titulo;
    @SerializedName("autor")
    private String autor;

    @SerializedName("anopublicacao")
    private String anoPublicacao;
    @SerializedName("imagem")
    private String imagem;


   /* public Emprestimo(int numRenovacoes) {
        this.idEmprestimo = idEmprestimo;
        this.idUser = idUser;
        this.idMidia = idMidia;
        this.idReserva = idReserva;
        this.dtEmprestimo = dtEmprestimo;
        this.dtDevolucao = dtDevolucao;
        this.numRenovacoes = numRenovacoes;
    }*/
    public int getIdEmprestimo() {
        return idEmprestimo;
    }
    public void setIdEmprestimo(int idEmprestimo) {
        this.idEmprestimo = idEmprestimo;
    }
    public int getIdUser() {
        return idUser;
    }
    public void setIdUser(int idUser) {
        this.idUser = idUser;
    }
    public int getIdMidia() {
        return idMidia;
    }
    public void setIdMidia(int idMidia) {
        this.idMidia = idMidia;
    }
    public int getIdReserva() {
        return idReserva;
    }
    public void setIdReserva(int idReserva) {
        this.idReserva = idReserva;
    }
    public String getDtEmprestimo() {
        return dtEmprestimo;
    }
    public void setDtEmprestimo(String dtEmprestimo) {
        this.dtEmprestimo = dtEmprestimo;
    }
    public String getDtDevolucao() {
        return dtDevolucao;
    }
    public void setDtDevolucao(String dtDevolucao) {
        this.dtDevolucao = dtDevolucao;
    }
    public int getNumRenovacoes() {
        return numRenovacoes;
    }
    public void setNumRenovacoes(int numRenovacoes) {
        this.numRenovacoes = numRenovacoes;
    }
    public String getTitulo() {
        return titulo;
    }
    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
    public String getAutor() {
        return autor;
    }
    public void setAutor(String autor) {
        this.autor = autor;
    }
    public String getAnoPublicacao() {
        return anoPublicacao;
    }
    public void setAnoPublicacao(String anoPublicacao) {
        this.anoPublicacao = anoPublicacao;
    }
    public String getImagem() {
        return imagem;
    }

    public void setImagem(String imagem) {
        this.imagem = imagem;
    }


}
