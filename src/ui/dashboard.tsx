import React from 'react';
import './dashboard.css';
import Menu from './components/menu';
import BotaoMais from './components/botaoMais'; // Adicione esta linha

function Dashboard() {
  return (
    <div className='conteinerDashboard'>
      <Menu />
      <div className='conteudoDashboard'>
        <div className="dashboard-flex-wrap">
          {/* Linha 1: duas colunas */}
          <div className="linha1" style={{ display: 'flex', gap: '2vw', width: '100%' }}>
            {/* Coluna da esquerda */}
            <div className="dashboard-col" style={{ flex: 1, minWidth: 320 }}>
              {/* Gráfico de Empréstimos */}
              <div className="dashboard-card">
                <div className="dashboard-card-header">
                  <span>Empréstimos</span>
                  <span className="dashboard-link">→</span>
                  <select className="dashboard-select">
                    <option>6 meses</option>
                  </select>
                </div>
                <div className="dashboard-bar-chart">
                  <div className="bar bar1"></div>
                  <div className="bar bar2"></div>
                  <div className="bar bar3"></div>
                  <div className="bar bar4"></div>
                  <div className="bar bar5"></div>
                  <div className="bar bar6"></div>
                  <div className="bar-labels">
                    <span>jan</span><span>fev</span><span>mar</span><span>abr</span><span>mai</span><span>jun</span>
                  </div>
                </div>
              </div>
              {/* Gráfico de Reservas */}
              <div className="dashboard-card dashboard-card-selected">
                <div className="dashboard-card-header">
                  <span>Reservas</span>
                  <span className="dashboard-link">→</span>
                  <select className="dashboard-select">
                    <option>6 meses</option>
                  </select>
                </div>
                <div className="dashboard-bar-chart">
                  <div className="bar bar1"></div>
                  <div className="bar bar2"></div>
                  <div className="bar bar3"></div>
                  <div className="bar bar4"></div>
                  <div className="bar bar5"></div>
                  <div className="bar bar6"></div>
                  <div className="bar-labels">
                    <span>jan</span><span>fev</span><span>mar</span><span>abr</span><span>mai</span><span>jun</span>
                  </div>
                </div>
              </div>
            </div>
            {/* Coluna da direita */}
            <div className="dashboard-col" style={{ flex: 1, minWidth: 320 }}>
              {/* Gráfico de Pizza */}
              <div className="dashboard-card">
                <div className="dashboard-card-header">
                  <span>Relação empréstimos x atrasos</span>
                </div>
                <div className="dashboard-pie-chart">
                  <svg width="110" height="110" viewBox="0 0 32 32">
                    <circle r="16" cx="16" cy="16" fill="#e9f2fb" />
                    <path d="M16 16 L16 0 A16 16 0 1 1 2.7 24.6 Z" fill="#0A4489" />
                  </svg>
                  <div className="pie-label pie-label-1">62 %</div>
                  <div className="pie-label pie-label-2">38 %</div>
                  <div className="pie-legend">
                    <div><span className="legend-dot legend-dot-atraso"></span>Empréstimos em atraso</div>
                    <div><span className="legend-dot legend-dot-dia"></span>Empréstimos em dia</div>
                  </div>
                </div>
              </div>
              {/* Eventos próximos */}
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
          {/* Linha 2: Livros mais indicados ocupando toda a largura */}
          <div className="linha2" style={{ width: '100%', marginTop: '2vw' }}>
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
                    <th>Autor</th>
                    <th>Quantidade</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>1°</td><td>As Vozes do Vento</td><td>Helena Costa</td><td>34</td></tr>
                  <tr><td>2°</td><td>O Guardião das Estações</td><td>Rafael M. Tavares</td><td>21</td></tr>
                  <tr><td>3°</td><td>Entre Linhas e Silêncios</td><td>Clara Antunes</td><td>13</td></tr>
                  <tr><td>4°</td><td>Fragmentos da Neblina</td><td>Diego Lins</td><td>5</td></tr>
                  <tr><td>5°</td><td>A Cidade que Nunca Dorme</td><td>Bianca Soares</td><td>2</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      <BotaoMais /> {/* Substitua o botão antigo por este componente */}
    </div>
  );
}

export default Dashboard;