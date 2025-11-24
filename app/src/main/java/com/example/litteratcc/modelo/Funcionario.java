package com.example.litteratcc.modelo;

public class Funcionario {
    private String idCargo;
    private String nome;
    private String cpf;
    private String email;
    private String senha;
    private String telefone;
    private String statusConta;

    /*public Funcionario(String idCargo, String nome, String cpf, String email, String senha, String telefone, String statusConta) {
        this.idCargo = idCargo;
        this.nome = nome;
        this.cpf = cpf;
        this.email = email;
        this.senha = senha;
        this.telefone = telefone;
        this.statusConta = statusConta;
    }*/
    public String getIdCargo() {
        return idCargo;
    }
    public void setIdCargo(String idCargo) {
        this.idCargo = idCargo;
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
        return statusConta;
    }
    public void setStatusConta(String statusConta) {
        this.statusConta = statusConta;
    }

}
