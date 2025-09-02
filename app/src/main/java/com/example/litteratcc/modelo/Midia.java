package com.example.litteratcc.modelo;

import com.google.gson.annotations.SerializedName;

public class Midia {
    @SerializedName("id")
    String idMidia;
    @SerializedName("id_tpmidia")
    int idTpMidia;
   // @SerializedName("id")
    //String TpMidia;
    @SerializedName("titulo")
    String titulo;
    @SerializedName("autor")
    String autor;
    @SerializedName("editora")
    String editora;
    @SerializedName("ano_publicacao")
    int anoPublicacao;
    @SerializedName("edicao")
    String edicao;
    @SerializedName("local_publicacao")
    String localPublicacao;
    @SerializedName("numero_paginas")
    int numPaginas;
    @SerializedName("isbn")
    long isbn;
    @SerializedName("duracao")
    String duracao;
    @SerializedName("estudio")
    String estudio;
    @SerializedName("roteirista")
    String roteirista;
    @SerializedName("disponibilidade")
    String disponibilidade;
    @SerializedName("sinopse")
    String sinopse;
    @SerializedName("fotoCapa")
    String fotoCapa; // no banco é salvo como varBinary, aqui será convertido para string com base64
    @SerializedName("trailer")
    String trailer;
    @SerializedName("genero")
    String genero;

    private boolean reservado;

   /* public Midia(int idMidia, int idTpMidia, String tpMidia, String titulo, String autor, String editora, int anoPublicacao, String edicao, String localPublicacao, int numPaginas, long isbn, String duracao, String estudio, String roteirista, String disponibilidade, String sinopse, String fotoCapa, String trailer, String genero) {
        this.idMidia = idMidia;
        this.idTpMidia = idTpMidia;
        this.TpMidia = tpMidia;
        this.titulo = titulo;
        this.autor = autor;
        this.editora = editora;
        this.anoPublicacao = anoPublicacao;
        this.edicao = edicao;
        this.localPublicacao = localPublicacao;
        this.numPaginas = numPaginas;
        this.isbn = isbn;
        this.duracao = duracao;
        this.estudio = estudio;
        this.roteirista = roteirista;
        this.disponibilidade = disponibilidade;
        this.sinopse = sinopse;
        this.fotoCapa = fotoCapa;
        this.trailer = trailer;
        this.genero = genero;
    }*/

    public boolean isReservado() { return reservado; }
    public void setReservado(boolean reservado) { this.reservado = reservado; }
    public String getIdMidia() {
        return idMidia;
    }
    public void setIdMidia(String idMidia) {
        this.idMidia = idMidia;
    }
    public int getIdTpMidia() {
        return idTpMidia;
    }
    public void setIdTpMidia(int idTpMidia) {
        this.idTpMidia = idTpMidia;
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
    public String getEditora() {
        return editora;
    }
    public void setEditora(String editora) {
        this.editora = editora;
    }
    public int getAnoPublicacao() {
        return anoPublicacao;
    }
    public void setAnoPublicacao(int anoPublicacao) {
        this.anoPublicacao = anoPublicacao;
    }
    public String getEdicao() {
        return edicao;
    }
    public void setEdicao(String edicao) {
        this.edicao = edicao;
    }
    public String getLocalPublicacao() {
        return localPublicacao;
    }
    public void setLocalPublicacao(String localPublicacao) {
        this.localPublicacao = localPublicacao;
    }
    public int getNumPaginas() {
        return numPaginas;
    }
    public void setNumPaginas(int numPaginas) {
        this.numPaginas = numPaginas;
    }
    public long getIsbn() {
        return isbn;
    }
    public void setIsbn(long isbn) {
        this.isbn = isbn;
    }
    public String getDuracao() {
        return duracao;
    }
    public void setDuracao(String duracao) {
        this.duracao = duracao;
    }
    public String getEstudio() {
        return estudio;
    }
    public void setEstudio(String estudio) {
        this.estudio = estudio;
    }
    public String getRoteirista() {
        return roteirista;
    }
    public void setRoteirista(String roteirista) {
        this.roteirista = roteirista;
    }
    public String getDisponibilidade() {
        return disponibilidade;
    }
    public void setDisponibilidade(String disponibilidade) {
        this.disponibilidade = disponibilidade;
    }
    public String getSinopse() {
        return sinopse;
    }
    public void setSinopse(String sinopse) {
        this.sinopse = sinopse;
    }
    public String getFotoCapa() {
        return fotoCapa;
    }
    public void setFotoCapa(String fotoCapa) {
        this.fotoCapa = fotoCapa;
    }
    public String getTrailer() {
        return trailer;
    }
    public void setTrailer(String trailer) {
        this.trailer = trailer;
    }
    public String getGenero() {
        return genero;
    }
    public void setGenero(String genero) {
        this.genero = genero;
    }
}
