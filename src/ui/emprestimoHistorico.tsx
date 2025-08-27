import React from 'react';
import './empretimoHistorico.css';
import Menu from './components/menu';
import { Search } from 'lucide-react';

const historico = [
  { codigo: '978-3-16-148410-0/1', titulo: 'As Sombras de Veridian', usuario: 'larissamendes', emprestimo: '12/05/25', devolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/2', titulo: 'As Sombras de Veridian', usuario: 'joaopedrosa_07', emprestimo: '12/05/25', devolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/3', titulo: 'As Sombras de Veridian', usuario: 'camila.ribeiro', emprestimo: '12/05/25', devolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/4', titulo: 'As Sombras de Veridian', usuario: 'leo_fer', emprestimo: '12/05/25', devolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/5', titulo: 'As Sombras de Veridian', usuario: 'nathsilva23', emprestimo: '12/05/25', devolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/6', titulo: 'As Sombras de Veridian', usuario: 'gustavogmoura', emprestimo: '12/05/25', devolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/7', titulo: 'As Sombras de Veridian', usuario: 'vivi.martins', emprestimo: '12/05/25', devolucao: '12/05/25' },
];

function EmprestimoHistorico() {
  return (
    <div className="conteinerEmprestimoHistorico">
      <Menu />
      <div className="conteudoEmprestimoHistorico">
        <div className="emprestimoHistorico-titulo">Empréstimos - histórico</div>
        <div className="emprestimoHistorico-busca">
          <input type="text" placeholder="Pesquisar..." />
          <Search size={20} />
        </div>
        <div className="emprestimoHistorico-tabela-container">
          <table className="emprestimoHistorico-tabela">
            <thead>
              <tr>
                <th>Código</th>
                <th>Título</th>
                <th>Usuário</th>
                <th>Data de empréstimo</th>
                <th>Data de devolução</th>
              </tr>
            </thead>
            <tbody>
              {historico.map((item, i) => (
                <tr key={i}>
                  <td>{item.codigo}</td>
                  <td>{item.titulo}</td>
                  <td>{item.usuario}</td>
                  <td>{item.emprestimo}</td>
                  <td>{item.devolucao}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default EmprestimoHistorico;