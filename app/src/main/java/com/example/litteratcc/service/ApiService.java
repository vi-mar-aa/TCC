package com.example.litteratcc.service;
import com.example.litteratcc.modelo.CadastroRequest;
import com.example.litteratcc.modelo.Cliente;
import com.example.litteratcc.modelo.ListaDesejos;
import com.example.litteratcc.modelo.LoginRequest;
import com.example.litteratcc.modelo.MessageResponse;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.request.EmailRequest;
import com.example.litteratcc.request.EmprestimoRequest;
import com.example.litteratcc.request.FavoritoRequest;
import com.example.litteratcc.request.FiltroAcervoRequest;
import com.example.litteratcc.request.GeneroRequest;
import com.example.litteratcc.request.MidiaRequest;
import com.example.litteratcc.request.RenovacaoRequest;
import com.example.litteratcc.request.RequestPesquisaAcervo;
import com.example.litteratcc.request.ReservaRequest;

import java.util.List;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.HTTP;
import retrofit2.http.POST;
import retrofit2.http.Path;


public interface ApiService {

    //ROTAS DE CLIENTE
    @POST("LoginCliente")
    Call<String> loginCliente(@Body LoginRequest request);
    @POST("CadastrarCliente")
    Call<String> cadastrarCliente(@Body CadastroRequest cadastro);
    @POST("BuscarLeitorPorEmail")
    Call<Cliente> getClienteByEmail(@Body EmailRequest email);
    @GET("cliente/{id}/imagem")
    Call<ResponseBody> getImagemCliente(@Path("id") int id);

    //TESTE DE CONEXÃO
    @GET("Joana")
    Call<MessageResponse> getMensagem();

    //ROTAS DE PERFIL
    @POST("/AlterarTodosDadosCliente")//nn precisa preencher tudo pra mudar, no banco senha nn fica vazia
    Call<String> alterarInfosClienteTeste(@Body Cliente novasInfos);
    @POST("InativarContaCliente")
    Call<String> inativarConta(@Body Cliente cliente);

    //ROTAS DA MAIN
    @GET("ListarPopulares")
    Call<List<Midia>> getMidiasPop();
    @POST("ListarMidiasPorGenero")
    Call<List<Midia>> listarMidiasPorGenero(@Body GeneroRequest genero);
    @POST("ListaMidiaEspecifica")
    Call<List<Midia>> getMidiaById(@Body MidiaRequest idMidia);
    @POST("ListarMidiasSimilares")
    Call<List<Midia>> getMidiasSimilares(@Body MidiaRequest idMidia);
    @POST("AdicionarDesejosCliente")
    Call<Boolean> favoritarMidia(@Body FavoritoRequest favoritoRequest);

    //ROTAS DO LISTA DE DESEJOS
    @POST("ListarDesejosCliente")
    Call<List<ListaDesejos>> listarDesejosCliente(@Body Cliente cliente);
    @HTTP(method = "DELETE", path = "DeletarDesejosCliente", hasBody = true)
    Call<ResponseBody> deletarDesejoCliente(@Body FavoritoRequest request);

    //ROTAS DO ACERVO
    @POST("PesquisarAcervo")
    Call<List<Midia>> pesquisarAcervo(@Body RequestPesquisaAcervo pesquisa);
    @POST("FiltroAcervo")
    Call<List<Midia>> filtrarAcervo(@Body FiltroAcervoRequest filtro);

    //ROTAS DE RESERVAS
    @POST("/ListarReservasCliente")
    Call<List<ReservaRequest>> listarReservasCliente(@Body Cliente cliente);
    @POST("AdicionarReserva")
    Call<Boolean> reservarMidia(@Body ReservaRequest reservaRequest);

    //ROTAS DE EMPRÉSTIMO
    @POST("RenovarEmprestimo")
    Call<String> renovarEmprestimo(@Body RenovacaoRequest request);
    @POST("ListarEmprestimosCliente")
    Call<List<EmprestimoRequest>> listarEmprestimosCliente(@Body Cliente cliente);
    @POST("ListarHistoricoEmprestimosCLiente")
    Call<List<EmprestimoRequest>> listarHistoricoEmprestimosCliente(@Body Cliente cliente);

}
