import axios, { AxiosInstance } from "axios";

// URL base da sua API — porta corrigida
const BASE_URL = "https://localhost:7008/"; 

class ApiManager {
  private static instance: AxiosInstance | null = null;

  // Retorna a instância do Axios configurada
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

// ------------------ FUNÇÕES DE API ------------------

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

export async function listarFuncionarios(): Promise<Funcionario[]> {
  const api = ApiManager.getApiService();
  const response = await api.get<Funcionario[]>("/ListarFuncionarios");
  return response.data;
}

export interface Midia {
  idMidia: number;
  titulo: string;
  autor: string;
  anopublicacao: number;
  imagem: string | null;
}

export async function listarMidias(searchText: string = ""): Promise<Midia[]> {
  const api = ApiManager.getApiService();

  const body = {
    midia: {
      idMidia: 0,
      chaveIdentificadora: "string",
      codigoExemplar: 0,
      idfuncionario: 0,
      idtpmidia: 0,
      titulo: "string",
      autor: "string",
      sinopse: "string",
      editora: "string",
      anopublicacao: "string",
      edicao: "string",
      localpublicacao: "string",
      npaginas: 0,
      isbn: "string",
      duracao: "string",
      estudio: "string",
      roterista: "string",
      dispo: 0,
      genero: 0,
      contExemplares: 0,
      nomeTipo: "string",
      imagem: "string"
    },
    searchText: searchText
  };

  const response = await api.post<Midia[]>("/PesquisarAcervo", body);
  return response.data;
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

export async function listarMidiaEspecifica(idMidia: number): Promise<MidiaEspecifica[]> {
  const api = ApiManager.getApiService();

  const body = {
    idMidia,
    chaveIdentificadora: "string",
    codigoExemplar: 0,
    idfuncionario: 0,
    idtpmidia: 0,
    titulo: "string",
    autor: "string",
    sinopse: "string",
    editora: "string",
    anopublicacao: "string",
    edicao: "string",
    localpublicacao: "string",
    npaginas: 0,
    isbn: "string",
    duracao: "string",
    estudio: "string",
    roterista: "string",
    dispo: 0,
    genero: 0,
    contExemplares: 0,
    nomeTipo: "string",
    imagem: "string"
  };

  const response = await api.post<MidiaEspecifica[]>("/ListaMidiaEspecifica", body);
  return response.data;
}

export async function excluirMidia(idMidia: number): Promise<string> {
  try {
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
          chaveIdentificadora: "string",
          codigoExemplar: 0,
          idfuncionario: 0,
          idtpmidia: 0,
          titulo: "string",
          autor: "string",
          sinopse: "string",
          editora: "string",
          anopublicacao: "string",
          edicao: "string",
          localpublicacao: "string",
          npaginas: 0,
          isbn: "string",
          duracao: "string",
          estudio: "string",
          roterista: "string",
          dispo: 0,
          genero: 0,
          contExemplares: 0,
          nomeTipo: "string",
          imagem: "string"
        }
      }),
    });

    if (!response.ok) throw new Error("Erro ao excluir mídia");
    const result = await response.json();
    return result;
  } catch (error) {
    console.error(error);
    throw new Error("Erro ao excluir a mídia.");
  }
}

export default ApiManager;
