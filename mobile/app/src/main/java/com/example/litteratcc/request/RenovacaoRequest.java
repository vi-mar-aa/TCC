package com.example.litteratcc.request;

import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Funcionario;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.modelo.Emprestimo;

public class RenovacaoRequest {
    private Midia midia;
    private Cliente cliente;
    private Emprestimo emprestimo;
    private Funcionario funcionario;
    private int diasAtraso;
    private double valorMulta;
    private int statusRenovacao;
    private String novaData;

    public RenovacaoRequest(Midia midia, Cliente cliente, Emprestimo emprestimo, Funcionario funcionario,
                            int diasAtraso, double valorMulta, int statusRenovacao, String novaData) {
        this.midia = midia;
        this.cliente = cliente;
        this.emprestimo = emprestimo;
        this.funcionario = funcionario;
        this.diasAtraso = diasAtraso;
        this.valorMulta = valorMulta;
        this.statusRenovacao = statusRenovacao;
        this.novaData = novaData;
    }

    // Getters e setters
    public Midia getMidia() { return midia; }
    public void setMidia(Midia midia) { this.midia = midia; }

    public Cliente getCliente() { return cliente; }
    public void setCliente(Cliente cliente) { this.cliente = cliente; }

    public Emprestimo getEmprestimo() { return emprestimo; }
    public void setEmprestimo(Emprestimo emprestimo) { this.emprestimo = emprestimo; }

    public Funcionario getFuncionario() { return funcionario; }
    public void setFuncionario(Funcionario funcionario) { this.funcionario = funcionario; }

    public int getDiasAtraso() { return diasAtraso; }
    public void setDiasAtraso(int diasAtraso) { this.diasAtraso = diasAtraso; }

    public double getValorMulta() { return valorMulta; }
    public void setValorMulta(double valorMulta) { this.valorMulta = valorMulta; }

    public int getStatusRenovacao() { return statusRenovacao; }
    public void setStatusRenovacao(int statusRenovacao) { this.statusRenovacao = statusRenovacao; }

    public String getNovaData() { return novaData; }
    public void setNovaData(String novaData) { this.novaData = novaData; }
}