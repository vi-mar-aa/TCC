import React from 'react';
import './indicacoes.css';
import Menu from './components/menu';
import { User, FileBarChart2 } from 'lucide-react';

const indicacoes = [
  {
    usuario: 'Vitória',
    texto: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Si tincidunt sapien, eget volutpat sapien lacus id justo.',
    faded: false,
  },
  {
    usuario: 'Vitória',
    texto: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Si tincidunt sapien, eget volutpat sapien lacus id justo.',
    faded: false,
  },
  {
    usuario: 'Vitória',
    texto: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Si tincidunt sapien, eget volutpat sapien lacus id justo.',
    faded: true,
  },
];

const livrosMaisIndicados = [
  { pos: '1°', nome: 'As Vozes do Vento', autor: 'Helena Costa', qtd: 34 },
  { pos: '2°', nome: 'O Guardião das Estações', autor: 'Rafael M. Tavares', qtd: 21 },
  { pos: '3°', nome: 'Entre Linhas e Silêncios', autor: 'Clara Antunes', qtd: 13 },
  { pos: '4°', nome: 'Fragmentos da Neblina', autor: 'Diego Lins', qtd: 5 },
  { pos: '5°', nome: 'A Cidade que Nunca Dorme', autor: 'Bianca Soares', qtd: 2 },
];

function Indicacoes() {
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
                <tr key={i} className={ind.faded ? 'faded' : ''}>
                  <td>
                    <div className="indicacoes-user">
                      <User size={22} style={{ marginRight: 8 }} />
                      {ind.usuario}
                    </div>
                  </td>
                  <td>{ind.texto}</td>
                </tr>
              ))}
              <tr>
                <td colSpan={2} className="indicacoes-expandir">
                  <span>Expandir</span> <span className="indicacoes-mais">+</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        {/* Livros mais indicados */}
        <div className="indicacoes-livros-box">
          <span className="indicacoes-livros-titulo">Livros mais indicados:</span>
          <table className="indicacoes-livros-tabela">
            <thead>
              <tr>
                <th></th>
                <th>Nome</th>
                <th>Autor</th>
                <th>Quantidade</th>
              </tr>
            </thead>
            <tbody>
              {livrosMaisIndicados.map((livro, i) => (
                <tr key={i}>
                  <td>{livro.pos}</td>
                  <td>{livro.nome}</td>
                  <td>{livro.autor}</td>
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