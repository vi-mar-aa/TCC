import React, { useEffect, useState } from "react";
import Menu from "./components/menu";
import { Search } from "lucide-react";
import BotaoMais from "./components/botaoMais";
import { listarEmprestimos } from "./ApiManager";
import "./emprestimos.css";

interface Midia {
  isbn: string | null;
  titulo: string;
  chaveIdentificadora: string;
}

interface Cliente {
  user: string;
}

interface EmprestimoInfo {
  midia: Midia;
  cliente: Cliente;
  emprestimo: {
    dataEmprestimo: string;
    dataDevolucao: string;
    status: string;
  };
}

function Emprestimos() {
  const [emprestimos, setEmprestimos] = useState<EmprestimoInfo[]>([]);
  const [busca, setBusca] = useState("");

  useEffect(() => {
    async function carregar() {
      try {
        const dados = await listarEmprestimos();
        setEmprestimos(dados);
      } catch (err) {
        console.error("Erro ao buscar empréstimos:", err);
      }
    }
    carregar();
  }, []);

  const handleBuscaChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setBusca(event.target.value);
  };

  const filtrados = emprestimos.filter((e) => {
    const termo = busca.toLowerCase();
    return (
      (e.midia.titulo?.toLowerCase().includes(termo) ?? false) ||
      (e.cliente.user?.toLowerCase().includes(termo) ?? false) ||
      (e.midia.isbn?.toLowerCase().includes(termo) ?? false)
    );
  });

  return (
    <div className="conteinerEmprestimos">
      <Menu />
      <div className="conteudoEmprestimos">
        <h2 className="emprestimos-titulo">Empréstimos</h2>

        <div className="busca-emprestimo">
          <input
            type="text"
            placeholder="Pesquisar por ISBN, título ou usuário..."
            className="busca-emprestimo-input"
            value={busca}
            onChange={handleBuscaChange}
          />
          <Search size={20} className="busca-emprestimo-icon" />
        </div>

        <div className="tabela-emprestimo-container">
          <table className="tabela-emprestimo">
            <thead>
              <tr>
                <th>ISBN</th>
                <th>Título</th>
                <th>Status</th>
                <th>Usuário</th>
                <th>Data de empréstimo</th>
                <th>Data de devolução</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtrados.map((e, i) => (
                <tr key={i}>
                  <td>{e.midia.isbn ?? "N/A"}</td>
                  <td>{e.midia.titulo}</td>
                  <td className={e.emprestimo.status === 'pendente' ? 'status-emprestado' : ''}>{e.emprestimo.status}</td>
                  <td>{e.cliente.user}</td>
                  <td>{new Date(e.emprestimo.dataEmprestimo).toLocaleDateString()}</td>
                  <td>{new Date(e.emprestimo.dataDevolucao).toLocaleDateString()}</td>
                  <td></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      <BotaoMais title="Adicionar empréstimo" />
    </div>
  );
}

export default Emprestimos;