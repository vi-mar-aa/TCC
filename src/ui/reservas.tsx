import React from 'react';
import './reservas.css';
import Menu from './components/menu';
import { Search } from 'lucide-react';

const reservasData = [
  { codigo: '978-3-16-148410-0/1', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'larissamendes' },
  { codigo: '978-3-16-148410-0/2', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'joaopedrosa_07' },
  { codigo: '978-3-16-148410-0/3', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'camila.ribeiro' },
  { codigo: '978-3-16-148410-0/4', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'leo_fer' },
  { codigo: '978-3-16-148410-0/5', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'nathsilva23' },
  { codigo: '978-3-16-148410-0/6', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'gustavogmoura' },
  { codigo: '978-3-16-148410-0/7', titulo: 'As Sombras de Veridian', tempo: '23 horas', usuario: 'vivi.martins', faded: true },
];

function Reservas() {
  return (
    <div className='conteinerReservas'>
      <Menu />
      <div className='conteudoReservas'>
        <h2 className="reservas-titulo">Reservas</h2>

        {/* Barra de busca */}
        <div className="busca-reserva">
          <input type="text" placeholder="Pesquisar..." />
          <Search size={20} />
        </div>

        {/* Tabela de reservas */}
        <div className="tabela-reserva-container">
          <table className="tabela-reserva">
            <thead>
              <tr>
                <th>Código</th>
                <th>Título</th>
                <th>Tempo restante</th>
                <th>Usuário</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {reservasData.map((r, i) => (
                <tr key={i} className={r.faded ? 'faded' : ''}>
                  <td>{r.codigo}</td>
                  <td>{r.titulo}</td>
                  <td>{r.tempo}</td>
                  <td>{r.usuario}</td>
                  <td>...</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="expandir">
            <span>Expandir</span> <span className="expandir-mais">+</span>
          </div>
        </div>

        {/* Gráfico de barras fake */}
        <div className="grafico-reserva-container">
          <div className="grafico-header">
            <span>2024</span>
            <span className="chevron">&#9660;</span>
          </div>
          <div className="grafico-reserva">
            {/* Barras fake */}
            <div className="barra barra1"></div>
            <div className="barra barra2"></div>
            <div className="barra barra3"></div>
            <div className="barra barra4"></div>
            <div className="barra barra5"></div>
            <div className="barra barra6"></div>
            <div className="barra barra7"></div>
            <div className="barra barra8"></div>
            <div className="barra barra9"></div>
            <div className="barra barra10"></div>
            <div className="barra barra11"></div>
            <div className="barra barra12"></div>
             <div className="barra barra1"></div>
            <div className="barra barra2"></div>
            <div className="barra barra3"></div>
            <div className="barra barra4"></div>
            <div className="barra barra5"></div>
            <div className="barra barra6"></div>
            <div className="barra barra7"></div>
            <div className="barra barra8"></div>
            <div className="barra barra9"></div>
            <div className="barra barra10"></div>
            <div className="barra barra11"></div>
            <div className="barra barra12"></div>
             <div className="barra barra1"></div>
            <div className="barra barra2"></div>
            <div className="barra barra3"></div>
            <div className="barra barra4"></div>
            <div className="barra barra5"></div>
            <div className="barra barra6"></div>
            <div className="barra barra7"></div>
            <div className="barra barra8"></div>
            <div className="barra barra9"></div>
            <div className="barra barra10"></div>
            <div className="barra barra11"></div>
            <div className="barra barra12"></div>
            <div className="grafico-labels">
              <span>jan</span><span>fev</span><span>mar</span><span>abr</span><span>mai</span><span>jun</span>
              <span>jul</span><span>ago</span><span>set</span><span>out</span><span>nov</span><span>dez</span>
            </div>
          </div>
        </div>

        {/* Botão Gerar Relatório */}
        <div className="relatorio-btn-wrap">
          <button className="relatorio-btn">
            <span role="img" aria-label="relatório">📊</span> Gerar Relatório
          </button>
        </div>
      </div>
    </div>
  );
}

export default Reservas;