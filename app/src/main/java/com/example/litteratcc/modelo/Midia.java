package com.example.litteratcc.modelo;

import com.google.gson.annotations.SerializedName;

public class Midia {
    @SerializedName("idMidia")
    private int idMidia;
    @SerializedName("idfuncionario")
    private int idFuncionario;
    @SerializedName("idtpmidia")
    private int idTpMidia;
    @SerializedName("titulo")
    private String titulo;
    @SerializedName("autor")
    private String autor;
    @SerializedName("sinopse")
    private String sinopse;
    @SerializedName("editora")
    private String editora;
    @SerializedName("anopublicacao")
    private String anoPublicacao;
    @SerializedName("edicao")
    private String edicao;
    @SerializedName("localpublicacao")
    private String localPublicacao;
    @SerializedName("npaginas")
    private Integer nPaginas;
    @SerializedName("isbn")
    private String isbn;
    @SerializedName("duracao")
    private String duracao;
    @SerializedName("estudio")
    private String estudio;
    @SerializedName("roteirista")
    private String roterista;

    @SerializedName("dispo")
    private String dispo;
    @SerializedName("genero")
    private String genero;
    @SerializedName("imagem")
    private String imagem;
    @SerializedName("contExemplares")
    private Integer contExemplares;
    @SerializedName("nomeTipo")
    private String nomeTipo;


    public Midia() {

    }
    // Getters e setters
    public int getIdMidia() { return idMidia; }
    public void setIdMidia(int idMidia) { this.idMidia = idMidia; }

    public int getIdFuncionario() { return idFuncionario; }
    public void setIdFuncionario(int idFuncionario) { this.idFuncionario = idFuncionario; }

    public int getIdTpMidia() { return idTpMidia; }
    public void setIdTpMidia(int idTpMidia) { this.idTpMidia = idTpMidia; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getAutor() { return autor; }
    public void setAutor(String autor) { this.autor = autor; }

    public String getSinopse() { return sinopse; }
    public void setSinopse(String sinopse) { this.sinopse = sinopse; }

    public String getEditora() { return editora; }
    public void setEditora(String editora) { this.editora = editora; }

    public String getAnoPublicacao() { return anoPublicacao; }
    public void setAnoPublicacao(String anoPublicacao) { this.anoPublicacao = anoPublicacao; }

    public String getEdicao() { return edicao; }
    public void setEdicao(String edicao) { this.edicao = edicao; }

    public String getLocalPublicacao() { return localPublicacao; }
    public void setLocalPublicacao(String localPublicacao) { this.localPublicacao = localPublicacao; }

    public Integer getNPaginas() { return nPaginas; }
    public void setNPaginas(Integer nPaginas) { this.nPaginas = nPaginas; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getDuracao() { return duracao; }
    public void setDuracao(String duracao) { this.duracao = duracao; }

    public String getEstudio() { return estudio; }
    public void setEstudio(String estudio) { this.estudio = estudio; }

    public String getRoterista() { return roterista; }
    public void setRoterista(String roterista) { this.roterista = roterista; }

    public String getDispo() { return dispo; }
    public void setDispo(String dispo) { this.dispo = dispo; }

    public String getGenero() { return genero; }
    public void setGenero(String genero) { this.genero = genero; }

    public String getImagem() { return imagem; }
    public void setImagem(String imagem) { this.imagem = imagem; }

    public Integer getContExemplares() { return contExemplares; }
    public void setContExemplares(Integer contExemplares) { this.contExemplares = contExemplares; }

    public String getNomeTipo() { return nomeTipo; }
    public void setNomeTipo(String nomeTipo) { this.nomeTipo = nomeTipo; }


}