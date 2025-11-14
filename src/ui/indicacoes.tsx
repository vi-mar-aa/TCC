import React, { useState, useEffect } from "react";
import Menu from "./components/menu";
import { User, FileBarChart2 } from "lucide-react";
import { listarIndicacoes } from "./ApiManager";
import'./indicacoes.css'

interface Cliente {
  idCliente: number;
  nome: string | null;
  user: string;
  imagemPerfil: string | null;
}

interface Indicacao {
  cliente: Cliente;
  texto: string; // texto da indicação, usado também como título do livro aqui
}

interface LivroMaisIndicado {
  nome: string;
  qtd: number;
}

function Indicacoes() {
  const [indicacoes, setIndicacoes] = useState<Indicacao[]>([]);
  const [livrosMaisIndicados, setLivrosMaisIndicados] = useState<LivroMaisIndicado[]>([]);

  useEffect(() => {
    async function carregarIndicacoes() {
      try {
        const dados = await listarIndicacoes();
        setIndicacoes(dados);

        // gerar ranking de livros mais indicados
        const contagem: { [key: string]: number } = {};
        dados.forEach((ind) => {
          const titulo = ind.texto; // aqui você pode substituir por ind.livro se tiver
          contagem[titulo] = (contagem[titulo] || 0) + 1;
        });

        const ranking = Object.entries(contagem)
          .map(([nome, qtd]) => ({ nome, qtd }))
          .sort((a, b) => b.qtd - a.qtd)
          .slice(0, 5); // top 5 livros
        setLivrosMaisIndicados(ranking);
      } catch (error) {
        console.error("Erro ao carregar indicações:", error);
      }
    }

    carregarIndicacoes();
  }, []);

  return (
    <div className="conteinerIndicacoes">
      <Menu />
      <div className="conteudoIndicacoes">
        <h2 className="indicacoes-titulo">Indicações</h2>

        {/* Lista de indicações */}
        <div className="indicacoes-box">
          <table className="indicacoes-tabela">
            <thead>
              <tr>
                <th>Usuário</th>
                <th>Indicação</th>
              </tr>
            </thead>
            <tbody>
              {indicacoes.map((ind, i) => (
                <tr key={i}>
                  <td>
                    <div className="indicacoes-user">
                      {ind.cliente.imagemPerfil ? (
                        <img
                          src={`data:image/jpeg;base64,${ind.cliente.imagemPerfil}`}
                          alt={ind.cliente.user}
                          style={{
                            width: 28,
                            height: 28,
                            borderRadius: "50%",
                            marginRight: 8,
                            objectFit: "cover",
                          }}
                        />
                      ) : (
                        <User size={22} style={{ marginRight: 8 }} />
                      )}
                      {ind.cliente.user}
                    </div>
                  </td>
                  <td>{ind.texto}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Livros mais indicados */}
        <div className="indicacoes-livros-box">
          <span className="indicacoes-livros-titulo">Livros mais indicados:</span>
          <table className="indicacoes-livros-tabela">
            <thead>
              <tr>
                <th>Posição</th>
                <th>Nome</th>
                <th>Quantidade</th>
              </tr>
            </thead>
            <tbody>
              {livrosMaisIndicados.map((livro, i) => (
                <tr key={i}>
                  <td>{i + 1}°</td>
                  <td>{livro.nome}</td>
                  <td>{livro.qtd}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Botão Gerar Relatório */}
        <div className="indicacoes-relatorio-btn-wrap">
          <button className="indicacoes-relatorio-btn">
            <FileBarChart2 size={22} style={{ marginRight: 8 }} />
            Gerar Relatório
          </button>
        </div>
      </div>
    </div>
  );
}

export default Indicacoes;
