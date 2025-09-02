package com.example.litteratcc.service;
import com.example.litteratcc.modelo.CadastroRequest;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.ListaDeDesejos;
import com.example.litteratcc.modelo.LoginRequest;
import com.example.litteratcc.modelo.MessageResponse;
import com.example.litteratcc.modelo.Midia;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.PATCH;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;


public interface ApiService {

    //LOGIN
    @POST("LoginCliente")
    Call<String> loginCliente(@Body LoginRequest login);
    //CADASTRO

    @POST("CadastrarCliente")
    Call<String> cadastrarCliente(@Body CadastroRequest cadastro);

    //TESTE DE CONEXÃO
    @GET("Joana")
    Call<MessageResponse> getMensagem();

    //PERFIL
    @PATCH("AlterarSenha")
    Call<Cliente> alteraSenha(@Path("id") int id, @Body Cliente cliente);

    //RESERVA
    @GET("Reservas")
    Call<List<Midia>> getReservas();

    @POST("Reservas")
    Call<Midia> reservarMidia(@Body Midia midia);

    //FAVORITAR
    @POST("ListaDesejo")
    Call<Midia> favoritarMidia(@Body Midia midia);// @Body é o objeto que será enviado no corpo da requisição

    @POST("ListaDesejo")
    Call<ListaDeDesejos> getFavoritado(@Path("id") int idMidia);
    @GET("ListaDesejo")
    Call<List<Midia>> getFavoritos();

    //EXCLUIR DA LISTA DE FAVORITOS
    @DELETE("ListaDesejo/{id}")
    Call<Void> deleteFavorito(@Path("id") int idMidia);


    //PAGINA SÓ COM LIVROS ESPECÍFICOS & MIDIAS CARROSSEL
    @GET("Midia")
    Call<List<Midia>> getMidiaCarrossel(
            @Query("genero") String genero
    );

    //CARROSSEL COM OS LIVROS POPULARES


    //CLICK NA MÍDIA
    @POST("Midia")
    Call<Midia> clickMidia(
            @Query("idTpMidia") int idTpMidia,
            @Query("idMidia") int idMidia,
            @Body Midia midia
    );
    //RESERVAR

    //RESERVAR
    @GET("Midia")
    Call<List<Midia>> getMidiaById(@Query("id") int idMidia);


    //HISTÓRICO DE RESERVAS

    //RENOVAÇÃO

    //TITULOS SIMILARES

    //ATRASO

    //HISTÓRICO DE EMPRÉSTIMOS

    //ACERVO

    //MAIN







}
