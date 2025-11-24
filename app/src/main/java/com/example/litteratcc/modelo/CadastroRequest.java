package com.example.litteratcc.modelo;

import com.google.gson.annotations.SerializedName;

public class CadastroRequest {
    @SerializedName("nome")
    private String nome;
    @SerializedName("user")
    private String user;
    @SerializedName("cpf")
    private String cpf; // igual à API
    @SerializedName("email")
    private String email;
    @SerializedName("senha")
    private String senha;
    @SerializedName("telefone")
    private String telefone;
    @SerializedName("status_conta")
    private String status_conta;
    @SerializedName("imagem_perfil")
    private String imagem_perfil;//no cadastro é null

    public CadastroRequest(String nome,String user, String cpf, String email, String senha, String telefone, String status_conta) {
        this.nome = nome;
        this.user = user;
        this.cpf = cpf;
        this.email = email;
        this.senha = senha;
        this.telefone = telefone;
        this.status_conta = status_conta;
    }


    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }
    public String getCpf() {
        return cpf;
    }
    public void setCpf(String cpf) {
        this.cpf = cpf;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getSenha() {
        return senha;
    }
    public void setSenha(String senha) {
        this.senha = senha;
    }
    public String getTelefone() {
        return telefone;
    }
    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }
    public String getStatusConta() {
        return status_conta;
    }
    public void setStatusConta(String status_conta) {
        this.status_conta = status_conta;
    }
    public String getUser() {
        return user;
    }
    public void setUser(String user) {
        this.user = user;
    }
    public String getImagemPerfil() {
        return imagem_perfil;
    }

}

