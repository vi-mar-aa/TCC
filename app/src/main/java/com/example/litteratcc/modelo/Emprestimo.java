package com.example.litteratcc.modelo;

public class Emprestimo {
    private int idEmprestimo;
    private int idUser;
    private int idMidia;
    private int idReserva;
    private String dtEmprestimo;
    private String dtDevolucao;
    private int numRenovacoes;

    public Emprestimo(int numRenovacoes) {
        this.idEmprestimo = idEmprestimo;
        this.idUser = idUser;
        this.idMidia = idMidia;
        this.idReserva = idReserva;
        this.dtEmprestimo = dtEmprestimo;
        this.dtDevolucao = dtDevolucao;
        this.numRenovacoes = numRenovacoes;
    }
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
}
