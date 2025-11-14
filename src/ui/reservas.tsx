import React, { useState, useEffect } from 'react';
import './reservas.css';
import Menu from './components/menu';
import { Search, ChevronDown } from 'lucide-react';
import ApiManager from './ApiManager';

export interface Reserva {
  reserva: {
    idReserva: number;
    idCliente: number;
    idMidia: number;
    dataReserva: string;
    dataLimite: string;
    statusReserva: string | null;
  };
  midia: {
    titulo: string;
    chaveIdentificadora: string;
    imagem: string | null;
    dispo: string | null;
  };
  cliente: {
    user: string;
    imagemPerfil: string | null;
  };
  tempoRestante: string;
}

function Reservas() {
  const [reservas, setReservas] = useState<Reserva[]>([]);
  const [searchText, setSearchText] = useState('');
  const [anoSelecionado, setAnoSelecionado] = useState<number>(new Date().getFullYear());
  const [dropdownAberto, setDropdownAberto] = useState(false);
  const [anosDisponiveis, setAnosDisponiveis] = useState<number[]>([]);

  useEffect(() => {
    async function carregarReservas() {
      try {
        const api = ApiManager.getApiService();
        const response = await api.get<Reserva[]>('/ListarReservas');
        setReservas(response.data);

        // Extrai os anos únicos das reservas
        const anos = Array.from(new Set(response.data.map(r => new Date(r.reserva.dataReserva).getFullYear())));
        anos.sort((a, b) => b - a);
        setAnosDisponiveis(anos);
        if (anos.length) setAnoSelecionado(anos[0]);
      } catch (error) {
        console.error('Erro ao carregar reservas:', error);
      }
    }
    carregarReservas();
  }, []);

  const reservasFiltradas = reservas.filter(r =>
    r.midia.titulo?.toLowerCase().includes(searchText.toLowerCase()) ||
    r.cliente.user.toLowerCase().includes(searchText.toLowerCase()) ||
    r.midia.chaveIdentificadora?.toLowerCase().includes(searchText.toLowerCase())
  );

  const reservasDoAno = reservas.filter(r => {
    const anoReserva = new Date(r.reserva.dataReserva).getFullYear();
    return anoReserva === anoSelecionado;
  });

  const reservasPorMes = Array(12).fill(0);
  reservasDoAno.forEach(r => {
    const mes = new Date(r.reserva.dataReserva).getMonth();
    reservasPorMes[mes]++;
  });

  return (
    <div className='conteinerReservas'>
      <Menu />
      <div className='conteudoReservas'>
        <h2 className="reservas-titulo">Reservas</h2>

        {/* Barra de busca */}
        <div className="busca-reserva">
          <input
            type="text"
            placeholder="Pesquisar..."
            value={searchText}
            onChange={e => setSearchText(e.target.value)}
          />
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
              {reservasFiltradas.map((r, i) => (
                <tr key={i} className={r.tempoRestante?.startsWith('-') ? 'faded' : ''}>
                  <td>{r.midia.chaveIdentificadora}</td>
                  <td>{r.midia.titulo}</td>
                  <td>{r.tempoRestante}</td>
                  <td>
                    <div className="usuario-reserva">
                      {r.cliente.user}
                    </div>
                  </td>
                  <td></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Gráfico de reservas */}
        <div className="grafico-reserva-container">
          <div className="grafico-header">
            <button className="egrafico-ano-btn" onClick={() => setDropdownAberto(!dropdownAberto)}>
              {anoSelecionado} <ChevronDown size={18} />
            </button>
            {dropdownAberto && (
              <div className="egrafico-dropdown">
                {anosDisponiveis.map(ano => (
                  <div key={ano} className="egrafico-ano-opcao" onClick={() => { setAnoSelecionado(ano); setDropdownAberto(false); }}>
                    {ano}
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="grafico-reserva">
            {reservasPorMes.map((qtd, i) => (
              <div
                key={i}
                className="barra"
                style={{ height: `${qtd * 3 + 2}vw` }}
                data-tooltip={`${qtd} reserva${qtd !== 1 ? 's' : ''}`}
              />
            ))}
            <div className="grafico-labels">
              <span>jan</span><span>fev</span><span>mar</span><span>abr</span>
              <span>mai</span><span>jun</span><span>jul</span><span>ago</span>
              <span>set</span><span>out</span><span>nov</span><span>dez</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Reservas;
