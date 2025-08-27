import React, { useState } from 'react';
import './eventos.css';
import Menu from './components/menu';
import { MoreVertical } from 'lucide-react';
import BotaoMais from './components/botaoMais';

const eventosAndamento = [
  {
    titulo: 'Sessão de RPG de Mesa – "Mistérios de Eldoria"',
    local: 'Biblioteca Littera – Sala Multiuso 2',
    horario: 'Das 14h às 18h',
    data: '18 de maio de 2025',
  },
  {
    titulo: 'Sessão de RPG de Mesa – "Mistérios de Eldoria"',
    local: 'Biblioteca Littera – Sala Multiuso 2',
    horario: 'Das 14h às 18h',
    data: '18 de maio de 2025',
  },
];

const eventosHistorico = [
  {
    titulo: 'Sessão de RPG de Mesa – "Mistérios de Eldoria"',
    local: 'Biblioteca Littera – Sala Multiuso 2',
    horario: 'Das 14h às 18h',
    data: '18 de maio de 2025',
  },
];

function Eventos() {
  const [tab, setTab] = useState<'andamento' | 'historico'>('andamento');

  const eventos = tab === 'andamento' ? eventosAndamento : eventosHistorico;

  return (
    <div className="conteinerEventos">
      <Menu />
      <div className="conteudoEventos">
        <h2 className="eventos-titulo">Eventos</h2>

        {/* Tabs */}
        <div className="eventos-tabs">
          <button
            className={tab === 'andamento' ? 'active' : ''}
            onClick={() => setTab('andamento')}
          >
            Em andamento
          </button>
          <button
            className={tab === 'historico' ? 'active' : ''}
            onClick={() => setTab('historico')}
          >
            Histórico
          </button>
        </div>

        {/* Lista de eventos */}
        <div className="eventos-lista">
          {eventos.map((evento, i) => (
            <div className="eventos-card" key={i}>
              <div className="eventos-card-info">
                <div><b>Evento:</b> {evento.titulo}</div>
                <div><b>Local:</b> {evento.local}</div>
                <div><b>Horário:</b> {evento.horario}</div>
                <div><b>Data:</b> {evento.data}</div>
              </div>
              <div className="eventos-card-actions">
                <MoreVertical size={24} />
              </div>
            </div>
          ))}
        </div>

        {/* Botão flutuante de adicionar */}
        <BotaoMais title="Adicionar evento" />
      </div>
    </div>
  );
}

export default Eventos;