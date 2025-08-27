import React, { useState } from 'react';
import './emprestimoGrafico.css';
import Menu from './components/menu';
import { Search, FileBarChart2, ChevronDown } from 'lucide-react';

const pieData = [
  { label: 'Em dia', value: 62, color: '#0A4489' },
  { label: 'Em atraso', value: 38, color: '#b7d3f7' }
];

const barData = [
  18, 34, 52, 41, 44, 7, 39, 61, 43, 47, 8, 36
];
const barColors = [
  '#b7d3f7', '#7bb3e3', '#4e8fd6', '#0A4489', '#223e6a', '#b7d3f7',
  '#7bb3e3', '#4e8fd6', '#0A4489', '#223e6a', '#b7d3f7', '#7bb3e3'
];
const meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

function EmprestimoGrafico() {
  const [ano, setAno] = useState(2024);
  const [busca, setBusca] = useState('');

  return (
    <div className="conteinerEmprestimos">
      <Menu />
      <div className="conteudoEmprestimos">
        <h2 className="egrafico-titulo">
          Empréstimos - Gráficos
        </h2>

        {/* Barra de busca */}
        <div className="busca-emprestimo">
          <input
            type="text"
            placeholder="Pesquisar..."
            value={busca}
            onChange={e => setBusca(e.target.value)}
          />
          <Search size={20} />
        </div>

        {/* Gráfico de pizza */}
        <div className="egrafico-card egrafico-pizza">
          <div className="egrafico-card-titulo">
            Relação empréstimos x atrasos
          </div>
          <div className="egrafico-pizza-area">
            {/* SVG Pie Chart */}
            <svg width="160" height="160" viewBox="0 0 40 40">
              <circle r="16" cx="20" cy="20" fill="#fff" />
              <circle
                r="16"
                cx="20"
                cy="20"
                fill="transparent"
                stroke="#0A4489"
                strokeWidth="8"
                strokeDasharray={`${62 * 100 / 100} ${38 * 100 / 100}`}
                strokeDashoffset="0"
                transform="rotate(-90 20 20)"
              />
              <circle
                r="16"
                cx="20"
                cy="20"
                fill="transparent"
                stroke="#b7d3f7"
                strokeWidth="8"
                strokeDasharray={`${38 * 100 / 100} ${62 * 100 / 100}`}
                strokeDashoffset={`-${62 * 100 / 100}`}
                transform="rotate(-90 20 20)"
              />
              {/* Porcentagens */}
              <text x="12" y="22" fontSize="4" fill="#fff" fontWeight="bold">62 %</text>
              <text x="26" y="16" fontSize="4" fill="#0A4489" fontWeight="bold">38 %</text>
            </svg>
            {/* Legenda */}
            <div className="egrafico-legenda">
              <div className="egrafico-legenda-item">
                <span className="egrafico-legenda-cor egrafico-legenda-atraso" />
                Empréstimos em atraso
              </div>
              <div className="egrafico-legenda-item">
                <span className="egrafico-legenda-cor egrafico-legenda-dia" />
                Empréstimos em dia
              </div>
            </div>
          </div>
        </div>

        {/* Gráfico de barras */}
        <div className="egrafico-card egrafico-barra">
          <div className="egrafico-barra-header">
            <span className="egrafico-card-titulo">
              Empréstimos realizados
            </span>
            <button className="egrafico-ano-btn">
              {ano} <ChevronDown size={18} style={{ marginLeft: 4 }} />
            </button>
          </div>
          {/* SVG Bar Chart */}
          <svg width="100%" height="180" viewBox="0 0 480 140" style={{ maxWidth: 800 }}>
            {barData.map((val, i) => (
              <g key={i}>
                <rect
                  x={i * 40 + 20}
                  y={140 - val * 1.1}
                  width={24}
                  height={val * 1.1}
                  rx={6}
                  fill={barColors[i]}
                />
                <text
                  x={i * 40 + 32}
                  y={140 - 4}
                  textAnchor="middle"
                  fontSize="13"
                  fill="#7a7a7a"
                >
                  {meses[i]}
                </text>
              </g>
            ))}
            {/* Eixo Y */}
            <line x1="10" y1="140" x2="470" y2="140" stroke="#bbb" strokeWidth="1" />
            {/* Eixo X */}
            <line x1="20" y1="20" x2="20" y2="140" stroke="#bbb" strokeWidth="1" />
          </svg>
        </div>

        {/* Botão Gerar Relatório */}
        <div className="egrafico-relatorio-area">
          <button className="egrafico-relatorio-btn">
            <FileBarChart2 size={22} style={{ marginRight: 8 }} />
            Gerar Relatório
          </button>
        </div>
      </div>
    </div>
  );
}

export default EmprestimoGrafico;