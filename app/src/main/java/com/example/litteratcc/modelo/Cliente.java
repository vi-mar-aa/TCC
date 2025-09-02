package com.example.litteratcc.modelo;

import com.google.gson.annotations.SerializedName;

public class Cliente {
    @SerializedName("id")
    private int idCliente;
    @SerializedName("nome")
    private String nome;
    @SerializedName("cpf")
    private int cpf;
    @SerializedName("email")
    private String email;
    @SerializedName("telefone")
    private String telefone;
    @SerializedName("senha")
    private String senha;
    @SerializedName("status_conta")
    private String statusConta;
    @SerializedName("fotoPerfil")
    private String fotoPerfil;

  /*  public Cliente(String idCliente, String fotoPerfil, String nome, String email, String senha){
        this.idCliente = idCliente;
        this.fotoPerfil = fotoPerfil;
        this.nome = nome;
        this.email = email;
        this.senha = senha;
    }*/
    public int getIdCliente() {
        return idCliente;
    }
    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }
    public String getNome() {
        return nome;
    }
    public void setNome(String nome) {
        this.nome = nome;
    }
    public int getCpf() {
        return cpf;
    }
    public void setCpf(int cpf) {
        this.cpf = cpf;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getTelefone() {
        return telefone;
    }
    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }
    public String getSenha() {
        return senha;
    }
    public void setSenha(String senha) {
        this.senha = senha;
    }
    public String getStatusConta() {
        return statusConta;
    }
    public void setStatusConta(String statusConta) {
        this.statusConta = statusConta;
    }
    public String getFotoPerfil() {
        return fotoPerfil;
    }
    public void setFotoPerfil(String fotoPerfil) {
        this.fotoPerfil = fotoPerfil;
    }


}