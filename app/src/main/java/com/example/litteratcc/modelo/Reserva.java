package com.example.litteratcc.modelo;

public class Reserva {
    private String titulo;
    private String autor;
    private String prazoDevolucao;

    public Reserva(String titulo, String autor, String prazoDevolucao) {
        this.titulo = titulo;
        this.autor = autor;
        this.prazoDevolucao = prazoDevolucao;
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

    public String getPrazoDevolucao() {
        return prazoDevolucao;
    }

    public void setPrazoDevolucao(String prazoDevolucao) {
        this.prazoDevolucao = prazoDevolucao;
    }
}
