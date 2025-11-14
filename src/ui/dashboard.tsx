import React, { useState, useEffect } from "react";
import Menu from "./components/menu";
import BotaoMais from "./components/botaoMais";
import ApiManager, { listarIndicacoes } from "./ApiManager";
import "./dashboard.css";

interface Emprestimo {
  emprestimo: { dataEmprestimo: string };
  diasAtraso: number;
}

interface Reserva {
  reserva: { dataReserva: string };
  midia: { titulo: string };
}

interface LivroMaisIndicado {
  nome: string;
  qtd: number;
}

function Dashboard() {
  const [anoEmprestimos, setAnoEmprestimos] = useState<number>(new Date().getFullYear());
  const [anoReservas, setAnoReservas] = useState<number>(new Date().getFullYear());
  const [emprestimos, setEmprestimos] = useState<Emprestimo[]>([]);
  const [reservas, setReservas] = useState<Reserva[]>([]);
  const [livrosMaisIndicados, setLivrosMaisIndicados] = useState<LivroMaisIndicado[]>([]);

  // Tooltip gráfico circular
  const [tooltip, setTooltip] = useState<{ x: number; y: number; text: string } | null>(null);
  const handleMouseMove = (e: React.MouseEvent<SVGCircleElement>, text: string) => {
    setTooltip({ x: e.clientX, y: e.clientY - 20, text });
  };
  const handleMouseLeave = () => setTooltip(null);

  // ------------------- LOAD EMPRESTIMOS -------------------
  useEffect(() => {
    async function carregarEmprestimos() {
      try {
        const resp = await fetch("https://localhost:7008/ListarEmprestimos");
        const dados = await resp.json();
        setEmprestimos(dados);
      } catch (err) {
        console.error("Erro ao carregar empréstimos:", err);
      }
    }
    carregarEmprestimos();
  }, []);

  // ------------------- LOAD RESERVAS -------------------
  useEffect(() => {
    async function carregarReservas() {
      try {
        const api = ApiManager.getApiService();
        const response = await api.get<Reserva[]>("/ListarReservas");
        setReservas(response.data);
      } catch (err) {
        console.error("Erro ao carregar reservas:", err);
      }
    }
    carregarReservas();
  }, []);

  // ------------------- LOAD LIVROS MAIS INDICADOS -------------------
  useEffect(() => {
    async function carregarIndicacoes() {
      try {
        const dados: any[] = await listarIndicacoes();
        const contagem: { [key: string]: number } = {};
        dados.forEach((item) => {
          const titulo = item.indicacao.textoIndicacao;
          contagem[titulo] = (contagem[titulo] || 0) + 1;
        });
        const ranking = Object.entries(contagem)
          .map(([nome, qtd]) => ({ nome, qtd }))
          .sort((a, b) => b.qtd - a.qtd)
          .slice(0, 5);
        setLivrosMaisIndicados(ranking);
      } catch (err) {
        console.error("Erro ao carregar indicações:", err);
      }
    }
    carregarIndicacoes();
  }, []);

  // ------------------- GRAFICO DE BARRAS -------------------
  const meses = ["jan","fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez"];
  const getBarData = (dados: any[], ano: number, key: string) => {
    const barData = Array(12).fill(0);
    dados.forEach(item => {
      const data = key === "emprestimo"
        ? new Date(item.emprestimo.dataEmprestimo)
        : new Date(item.reserva.dataReserva);

      if (data.getFullYear() === ano) barData[data.getMonth()]++;
    });
    return barData;
  };

  const barEmprestimos = getBarData(emprestimos, anoEmprestimos, "emprestimo");
  const barReservas = getBarData(reservas, anoReservas, "reserva");
  const maxVal = Math.max(...barEmprestimos, ...barReservas, 1);

  // ------------------- GRAFICO CIRCULAR -------------------
  const emAtraso = emprestimos.filter(e => e.diasAtraso > 0).length;
  const emDia = emprestimos.filter(e => e.diasAtraso === 0).length;
  const total = emDia + emAtraso || 1;

  const radius = 26;
  const circumference = 2 * Math.PI * radius;
  const emDiaStroke = (emDia / total) * circumference;
  const emAtrasoStroke = (emAtraso / total) * circumference;

  return (
    <div className="conteinerDashboard">
      <Menu />
      <div className="conteudoDashboard">
        <div className="dashboard-flex-wrap">

          {/* COLUNA ESQUERDA */}
          <div className="dashboard-col">
            {/* Empréstimos */}
            <div className="dashboard-card">
              <div className="dashboard-card-header">
                <span>Empréstimos</span>
                <span className="dashboard-link">→</span>
                <select className="dashboard-select" onChange={e => setAnoEmprestimos(Number(e.target.value))}>
                  {[2025,2024,2023].map(a => <option key={a}>{a}</option>)}
                </select>
              </div>
              <div className="grafico-reserva">
                {barEmprestimos.map((val, i) => (
                  <div
                    key={i}
                    className="barra"
                    style={{ height: `${(val / maxVal) * 2 + 1}vw` }}
                    data-tooltip={`${val} empréstimo${val!==1?'s':''}`}
                  />
                ))}
                <div className="grafico-labels">{meses.map(m => <span key={m}>{m}</span>)}</div>
              </div>
            </div>

            {/* Reservas */}
            <div className="dashboard-card dashboard-card-selected">
              <div className="dashboard-card-header">
                <span>Reservas</span>
                <span className="dashboard-link">→</span>
                <select className="dashboard-select" onChange={e => setAnoReservas(Number(e.target.value))}>
                  {[2025,2024,2023].map(a => <option key={a}>{a}</option>)}
                </select>
              </div>
              <div className="grafico-reserva">
                {barReservas.map((val, i) => (
                  <div
                    key={i}
                    className="barra"
                    style={{ height: `${(val / maxVal) * 2 +1}vw` }}
                    data-tooltip={`${val} reserva${val!==1?'s':''}`}
                  />
                ))}
                <div className="grafico-labels">{meses.map(m => <span key={m}>{m}</span>)}</div>
              </div>
            </div>
          </div>

          {/* COLUNA DIREITA */}
          <div className="dashboard-col">

            {/* Gráfico Circular (CORRIGIDO) */}
            <div className="dashboard-card">
              <div className="dashboard-card-header">
                <span>Relação empréstimos x atrasos</span>
              </div>

              <div
                className="dashboard-pie-chart"
                style={{
                  width: '12vw',
                  height: '12vw',
                  maxWidth: '200px',
                  maxHeight: '200px',
                  minWidth: '120px',
                  minHeight: '120px',
                  position: 'relative',
                  margin: '0 auto'
                }}
              >
                <svg
                  viewBox="0 0 64 64"
                  style={{
                    width: '100%',
                    height: '100%',
                    position: 'absolute',
                    top: 0,
                    left: 0,
                  }}
                >
                  <circle r="26" cx="32" cy="32" fill="#e9f2fb" />

                  {emDia > 0 && (
                    <circle
                      r="26"
                      cx="32"
                      cy="32"
                      fill="transparent"
                      stroke="#0A4489"
                      strokeWidth="6"
                      strokeDasharray={`${emDiaStroke} ${circumference - emDiaStroke}`}
                      transform="rotate(-90 32 32)"
                      onMouseMove={(e) => handleMouseMove(e, `${emDia} em dia`)}
                      onMouseLeave={handleMouseLeave}
                      style={{ cursor: 'pointer' }}
                    />
                  )}

                  {emAtraso > 0 && (
                    <circle
                      r="26"
                      cx="32"
                      cy="32"
                      fill="transparent"
                      stroke="#b7d3f7"
                      strokeWidth="6"
                      strokeDasharray={`${emAtrasoStroke} ${circumference - emAtrasoStroke}`}
                      strokeDashoffset={`-${emDiaStroke}`}
                      transform="rotate(-90 32 32)"
                      onMouseMove={(e) => handleMouseMove(e, `${emAtraso} em atraso`)}
                      onMouseLeave={handleMouseLeave}
                      style={{ cursor: 'pointer' }}
                    />
                  )}
                </svg>

                <div
                  style={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    fontSize: '0.9vw',
                    fontWeight: 600,
                    color: '#0A4489',
                    whiteSpace: 'nowrap'
                  }}
                >
                  {total} empréstimos
                </div>
              </div>
            </div>

            {/* Eventos */}
            <div className="dashboard-card">
              <div className="dashboard-card-header">
                <span>Eventos próximos</span>
                <span className="dashboard-link">→</span>
              </div>
              <div className="dashboard-events">
                <div className="event">
                  <div className="event-date">15/04/25</div>
                  <div className="event-desc">Sessão de RPG de Mesa - "Mistérios de Eldoria"</div>
                </div>
                <div className="event">
                  <div className="event-date">19/04/25</div>
                  <div className="event-desc">Debate Literário – "A Literatura e as Transformações Sociais"</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Livros mais indicados */}
        <div className="linha2" style={{ width: '85%', marginTop: '2vw' }}>
          <div className="dashboard-card dashboard-table-card">
            <div className="dashboard-card-header">
              <span>Livros mais indicados:</span>
              <span className="dashboard-link">→</span>
            </div>
            <table className="dashboard-table">
              <thead>
                <tr>
                  <th>°</th>
                  <th>Nome</th>
                  <th>Quantidade</th>
                </tr>
              </thead>
              <tbody>
                {livrosMaisIndicados.map((livro, i) => (
                  <tr key={i}>
                    <td>{i+1}°</td>
                    <td>{livro.nome}</td>
                    <td>{livro.qtd}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <BotaoMais />

      {/* Tooltip */}
      {tooltip && (
        <div style={{
          position: 'fixed',
          left: tooltip.x,
          top: tooltip.y,
          background: '#0A4489',
          color: '#fff',
          padding: '4px 8px',
          borderRadius: '4px',
          fontSize: '0.75rem',
          pointerEvents: 'none',
          whiteSpace: 'nowrap',
          zIndex: 1000
        }}>
          {tooltip.text}
        </div>
      )}
    </div>
  );
}

export default Dashboard;
