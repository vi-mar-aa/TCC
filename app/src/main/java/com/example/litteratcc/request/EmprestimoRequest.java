package com.example.litteratcc.request;

import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.Funcionario;
import com.example.litteratcc.modelo.Midia;
import com.google.gson.annotations.SerializedName;

import java.util.Date;

public class EmprestimoRequest {
    private Emprestimo emprestimo;
    private Cliente cliente;
    private Midia midia;
    private Funcionario funcionario;
    @SerializedName("diasAtraso")

    private int diasAtraso;
    @SerializedName("valorMulta")
    private int valorMulta;
    @SerializedName("statusRenovacao")
    private int statusRenovacao;
    @SerializedName("novaData")
    private String novaData;


    public EmprestimoRequest(Midia midia, Cliente cliente, Emprestimo emprestimo, Funcionario funcionario,
                            int diasAtraso, int valorMulta, int statusRenovacao, String novaData) {
        this.emprestimo = emprestimo;
        this.cliente = cliente;
        this.midia = midia;
        this.funcionario = funcionario;
        this.diasAtraso = diasAtraso;
        this.valorMulta = valorMulta;
        this.statusRenovacao = statusRenovacao;
        this.novaData = novaData;

    }

    public Emprestimo getEmprestimo() { return emprestimo; }
    public Cliente getCliente() { return cliente; }
    public Midia getMidia() { return midia; }
    public Funcionario getFuncionario() { return funcionario; }
    public int getDiasAtraso() { return diasAtraso; }
    public int getValorMulta() { return valorMulta; }
    public int getStatusRenovacao() { return statusRenovacao; }
    public String getNovaData() { return novaData;

}}


