import axios, { AxiosInstance } from "axios";

// URL base da sua API
const BASE_URL = "http://localhost:5107/"; 


class ApiManager {
  private static instance: AxiosInstance | null = null;

  // Método que retorna a instância do Axios configurada
  public static getApiService(): AxiosInstance {
    if (!this.instance) {
      this.instance = axios.create({
        baseURL: BASE_URL,
        headers: {
          "Content-Type": "application/json",
        },
      });

      // Exemplo de interceptor de requisição
      this.instance.interceptors.request.use(
        (config) => {
          // Aqui você pode injetar tokens de autenticação
          const token = localStorage.getItem("token");
          if (token) {
            config.headers.Authorization = `Bearer ${token}`;
          }
          return config;
        },
        (error) => Promise.reject(error)
      );

      // Exemplo de interceptor de resposta
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


export interface Funcionario {
  idFuncionario: number;  // ← agora corresponde ao JSON
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
  imagem: string | null; // base64 pode ser string ou null
}

export async function listarMidias(): Promise<Midia[]> {
  const api = ApiManager.getApiService();
  const response = await api.get<Midia[]>("/ListarMidias"); // endpoint da sua API
  return response.data;
}




export default ApiManager;