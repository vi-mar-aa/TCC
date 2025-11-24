package com.example.litteratcc.service;

public class LoginResponse {
    private String resposta;
    private int id_cliente;

    // getters
    public String getResposta() { return resposta; }//retorno da API
    public int getIdCliente() { return id_cliente; }// o id que eu vou usar no favoritar, reservar, empréstimo, etc
}

