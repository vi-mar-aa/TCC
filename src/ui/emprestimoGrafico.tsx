import React, { useEffect, useState } from "react";
import "./emprestimoGrafico.css";
import Menu from "./components/menu";
import { Search, FileBarChart2, ChevronDown } from "lucide-react";

function EmprestimoGrafico() {
  const [busca, setBusca] = useState("");
  const [emprestimos, setEmprestimos] = useState<any[]>([]);
  const [ano, setAno] = useState(2025);

  useEffect(() => {
    async function carregar() {
      try {
        const resp = await fetch("https://localhost:7008/ListarEmprestimos");
        const dados = await resp.json();
        setEmprestimos(dados);
      } catch (err) {
        console.error("Erro ao carregar dados:", err);
      }
    }
    carregar();
  }, []);

  // ----------------------------
  // GRÁFICO DE PIZZA
  // ----------------------------
  const emAtraso = emprestimos.filter(e => e.diasAtraso > 0).length;
  const emDia = emprestimos.filter(e => e.diasAtraso === 0).length;

  const total = emDia + emAtraso;

  // ----------------------------
  // GRÁFICO DE BARRAS POR MÊS
  // ----------------------------
  const meses = ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"];
  const barData = new Array(12).fill(0);

  emprestimos.forEach(e => {
    const data = new Date(e.emprestimo.dataEmprestimo);
    if (data.getFullYear() === ano) {
      const mes = data.getMonth();
      barData[mes]++;
    }
  });

  const barColors = [
    "#b7d3f7", "#7bb3e3", "#4e8fd6", "#0A4489", "#223e6a",
    "#b7d3f7", "#7bb3e3", "#4e8fd6", "#0A4489", "#223e6a", "#b7d3f7", "#7bb3e3"
  ];

  return (
    <div className="conteinerEmprestimos">
      <Menu />

      <div className="conteudoEmprestimos">
        <h2 className="emprestimos-titulo">Empréstimos - Gráficos</h2>


        {/* Gráfico de Pizza */}
        <div className="egrafico-card egrafico-pizza">
          <div className="egrafico-card-titulo">Relação empréstimos x atrasos</div>

          <div className="egrafico-pizza-area">
            <svg width="350" height="350" viewBox="0 0 40 40">
              <circle r="16" cx="20" cy="20" fill="#fff" />

              {/* Em dia */}
              <circle
                r="16"
                cx="20"
                cy="20"
                fill="transparent"
                stroke="#0A4489"
                strokeWidth="8"
                strokeDasharray={`${(emDia / total) * 100} ${100}`}
                transform="rotate(-90 20 20)"
              />

              {/* Em atraso */}
              <circle
                r="16"
                cx="20"
                cy="20"
                fill="transparent"
                stroke="#b7d3f7"
                strokeWidth="8"
                strokeDasharray={`${(emAtraso / total) * 100} ${100}`}
                strokeDashoffset={`-${(emDia / total) * 100}`}
                transform="rotate(-90 20 20)"
              />

              <text x="12" y="22" fontSize="4" fill="#000" fontWeight="bold">
                {emDia} em dia
              </text>
              <text x="12" y="28" fontSize="4" fill="#000" fontWeight="bold">
                {emAtraso} atrasos
              </text>
            </svg>

            <div className="egrafico-legenda">
              <div className="egrafico-legenda-item">
                <span className="egrafico-legenda-cor egrafico-legenda-atraso" />
                Em atraso
              </div>
              <div className="egrafico-legenda-item">
                <span className="egrafico-legenda-cor egrafico-legenda-dia" />
                Em dia
              </div>
            </div>
          </div>
        </div>

        {/* Gráfico de Barras */}
        <div className="egrafico-card egrafico-barra">
          <div className="egrafico-barra-header">
            <span className="egrafico-card-titulo">Empréstimos realizados</span>
            <button className="egrafico-ano-btn">
              {ano} <ChevronDown size={18} />
            </button>
          </div>

          <svg width="80%" height="500" viewBox="0 0 480 160">
          {/* Eixo Y com valores */}
          {[0, 5, 10, 15, 20].map((tick) => (
            <g key={tick}>
              <text x={18} y={140 - tick * 6} fontSize="12" fill="#7a7a7a" textAnchor="end">
                {tick}
              </text>
              <line x1={20} y1={140 - tick * 6} x2={480} y2={140 - tick * 6} stroke="#eee" strokeWidth="1" />
            </g>
          ))}

          {barData.map((val, i) => (
            <g key={i}>
              <rect
                x={i * 40 + 20}
                y={140 - val * 6}
                width={24}
                height={val * 6}
                rx={6}
                fill={barColors[i]}
              />
              <text
                x={i * 40 + 32}
                y={158}
                textAnchor="middle"
                fontSize="12"
                fill="#7a7a7a"
              >
                {meses[i]}
              </text>
            </g>
          ))}

          <line x1="10" y1="140" x2="580" y2="140" stroke="#bbb" strokeWidth="1" />
          <line x1="20" y1="20" x2="20" y2="140" stroke="#bbb" strokeWidth="1" />
        </svg>

        </div>

        {/* Botão Relatório */}
        <div className="egrafico-relatorio-area">
        </div>
      </div>
    </div>
  );
}

export default EmprestimoGrafico;
