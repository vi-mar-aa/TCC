import axios, { AxiosInstance } from "axios";

// URL base da sua API
const BASE_URL = "https://localhost:7008/";

class ApiManager {
  private static instance: AxiosInstance | null = null;

  public static getApiService(): AxiosInstance {
    if (!this.instance) {
      this.instance = axios.create({
        baseURL: BASE_URL,
        headers: {
          "Content-Type": "application/json",
        },
      });

      // Interceptor de requisição
      this.instance.interceptors.request.use(
        (config) => {
          const token = localStorage.getItem("token");
          if (token) {
            config.headers.Authorization = `Bearer ${token}`;
          }
          return config;
        },
        (error) => Promise.reject(error)
      );

      // Interceptor de resposta
      this.instance.interceptors.response.use(
        (response) => response,
        (error) => {
          console.error("Erro na API:", error);
          return Promise.reject(error);
        }
      );
    }
    return this.instance;
  }
}

// -------------------------------------------------------
// MODELOS
// -------------------------------------------------------

export interface Funcionario {
  idFuncionario: number;
  idcargo: number;
  nome: string;
  cpf: string;
  email: string;
  senha: string | null;
  telefone: string;
  statusconta: string;
}

export interface Midia {
  idMidia: number;
  titulo: string;
  autor: string;
  anopublicacao: number;
  imagem: string | null;
  genero: string;
}

export interface MidiaEspecifica {
  idMidia: number;
  chaveIdentificadora: string;
  codigoExemplar: number;
  idfuncionario: number;
  idtpmidia: number;
  titulo: string;
  autor: string;
  sinopse: string;
  editora: string;
  anopublicacao: string;
  edicao: string;
  localpublicacao: string;
  npaginas: number;
  isbn: string;
  duracao: string;
  estudio: string;
  roterista: string;
  dispo: number;
  genero: number;
  contExemplares: number;
  nomeTipo: string;
  imagem: string;
}

// -------------------------------------------------------
// FUNCIONÁRIOS
// -------------------------------------------------------

export async function listarFuncionarios(): Promise<Funcionario[]> {
  const api = ApiManager.getApiService();
  const response = await api.get<Funcionario[]>("/ListarFuncionarios");
  return response.data;
}

export async function cadastrarAdm(funcionario: Funcionario) {
  const api = ApiManager.getApiService();
  const response = await api.post("/CadastrarAdm", funcionario);
  return response.data;
}

// -------------------------------------------------------
// MÍDIAS
// -------------------------------------------------------

export async function listarMidias(searchText: string = ""): Promise<Midia[]> {
  const api = ApiManager.getApiService();

  const body = {
    searchText,
  };

  const response = await api.post<Midia[]>("/PesquisarAcervo", body);
  return response.data;
}

export async function listarMidiaEspecifica(idMidia: number): Promise<MidiaEspecifica[]> {
  const api = ApiManager.getApiService();

  const response = await api.post<MidiaEspecifica[]>("/ListaMidiaEspecifica", { idMidia });
  return response.data;
}

export async function excluirMidia(idMidia: number): Promise<string> {
  const response = await fetch("https://localhost:7008/ExcluirMidia", {
    method: "DELETE",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      funcionario: {
        idFuncionario: 0,
        idcargo: 0,
        nome: "string",
        cpf: "string",
        email: "string",
        senha: "string",
        telefone: "string",
        statusconta: "string"
      },
      midia: {
        idMidia,
      }
    }),
  });

  if (!response.ok) throw new Error("Erro ao excluir mídia");

  return response.json();
}

export async function configurarParametros(
  idParametros: number,
  multaDias: number,
  prazoDevolucao: number,
  limiteEmprestimos: number
) {
  const response = await fetch("https://localhost:7008/ConfigurarParametros", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      idParametros,
      multaDias,
      prazoDevolucao,
      limiteEmpretismos: limiteEmprestimos
    })
  });

  if (!response.ok) throw new Error("Erro ao configurar parâmetros");

  return response.json();
}

export async function listarIndicacoes() {
  const api = ApiManager.getApiService();
  const response = await api.get("/ListarIndicacoes");
  return response.data;
}



export default ApiManager;
