import React, { useState } from 'react';
import './emprestimos.css';
import Menu from './components/menu';
import { Search } from 'lucide-react';
import BotaoMais from './components/botaoMais';

const emprestimosData = [
  { codigo: '978-3-16-148410-0/1', titulo: 'As Sombras de Veridian', status: 'Renovado', usuario: 'larissamendes', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/2', titulo: 'As Sombras de Veridian', status: 'Emprestado', usuario: 'joaopedrosa_07', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/3', titulo: 'As Sombras de Veridian', status: 'Atrasado', usuario: 'camila.ribeiro', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/4', titulo: 'As Sombras de Veridian', status: 'Renovado', usuario: 'leo_fer', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/5', titulo: 'As Sombras de Veridian', status: 'Emprestado', usuario: 'nathsilva23', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/6', titulo: 'As Sombras de Veridian', status: 'Atrasado', usuario: 'gustavogmoura', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
  { codigo: '978-3-16-148410-0/7', titulo: 'As Sombras de Veridian', status: 'Renovado', usuario: 'vivi.martins', dataEmprestimo: '12/05/25', dataDevolucao: '12/05/25' },
];

function Emprestimos() {
  const [filtro, setFiltro] = useState<'Todos' | 'Atrasado' | 'Renovado'>('Todos');

  const emprestimosFiltrados = emprestimosData.filter(e => {
    if (filtro === 'Todos') return true;
    if (filtro === 'Atrasado') return e.status === 'Atrasado';
    if (filtro === 'Renovado') return e.status === 'Renovado';
    return true;
  });

  return (
    <div className='conteinerEmprestimos'>
      <Menu />
      <div className='conteudoEmprestimos'>
        <h2 className="emprestimos-titulo">Empréstimos - atuais</h2>
        {/* Barra de busca */}
        <div className="busca-emprestimo">
          <input
            type="text"
            placeholder="Pesquisar..."
            className="busca-emprestimo-input"
          />
          <Search size={20} className="busca-emprestimo-icon" />
        </div>

        {/* Filtros */}
        <div className="filtros-emprestimo">
          <button
            className={filtro === 'Todos' ? 'active' : ''}
            onClick={() => setFiltro('Todos')}
          >
            Todos
          </button>
          <button
            className={filtro === 'Atrasado' ? 'active' : ''}
            onClick={() => setFiltro('Atrasado')}
          >
            Em atraso
          </button>
          <button
            className={filtro === 'Renovado' ? 'active' : ''}
            onClick={() => setFiltro('Renovado')}
          >
            Renovados
          </button>
        </div>

        {/* Tabela */}
        <div className="tabela-emprestimo-container">
          <table className="tabela-emprestimo">
            <thead>
              <tr>
                <th>Código</th>
                <th>Título</th>
                <th>Status</th>
                <th>Usuário</th>
                <th>Data de empréstimo</th>
                <th>Data de devolução</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {emprestimosFiltrados.map((e, i) => (
                <tr key={i}>
                  <td>{e.codigo}</td>
                  <td>{e.titulo}</td>
                  <td
                    className={
                      e.status === 'Atrasado'
                        ? 'status-atrasado'
                        : e.status === 'Renovado'
                          ? 'status-renovado'
                          : 'status-emprestado'
                    }
                  >
                    {e.status}
                  </td>
                  <td>{e.usuario}</td>
                  <td>{e.dataEmprestimo}</td>
                  <td>{e.dataDevolucao}</td>
                  <td>...</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      {/* Botão flutuante de adicionar */}
      <BotaoMais title="Adicionar empréstimo" />
    </div>
  );
}

export default Emprestimos;