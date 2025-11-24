package com.example.litteratcc.request;

import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.Emprestimo;
import com.example.litteratcc.modelo.Funcionario;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.modelo.Reserva;
import com.google.gson.annotations.SerializedName;

public class ReservaRequest {
    private Reserva reserva;
    private Cliente cliente;
    private Midia midia;
    private Funcionario funcionario;
    private Emprestimo emprestimo;
    @SerializedName("chaveIdentificadora")
    private String chaveIdentificadora;
    @SerializedName("tempoRestante")
    private Integer tempoRestante;


    public ReservaRequest(Reserva reserva, Cliente cliente, Midia midia, Funcionario funcionario, Emprestimo emprestimo, String chaveIdentificadora, Integer tempoRestante) {
        this.reserva = reserva;
        this.cliente = cliente;
        this.midia = midia;
        this.funcionario = funcionario;
        this.emprestimo = emprestimo;
        this.chaveIdentificadora = chaveIdentificadora;
        this.tempoRestante = tempoRestante;
    }

    public Reserva getReserva() { return reserva; }
    public Cliente getCliente() { return cliente; }
    public Midia getMidia() { return midia; }
    public Funcionario getFuncionario() { return funcionario; }
    public Emprestimo getEmprestimo() { return emprestimo; }
    public String getChaveIdentificadora() { return chaveIdentificadora; }
    public Integer getTempoRestante() { return tempoRestante; }

}
