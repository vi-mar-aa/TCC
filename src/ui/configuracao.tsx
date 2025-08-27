import React, { useState } from 'react';
import './configuracao.css';
import Menu from './components/menu';
import { User, MoreVertical, File, X, Save } from 'lucide-react';
import BotaoMais from './components/botaoMais';

const funcionarios = [
  {
    email: 'Vitoria@gmail.com',
    telefone: '11 96459000',
    nome: 'Vitória Tavares',
    usuario: 'Vitória Tavares',
    turno: 'Manhã',
  },
  {
    email: 'Vitoria@gmail.com',
    telefone: '11 96459000',
    nome: 'Vitória Tavares',
    usuario: 'Vitória1',
    turno: 'Manhã',
  },
];

function Configuracao() {
  const [tab, setTab] = useState<'geral' | 'funcionarios' | 'preferencias'>('geral');
  const [multa, setMulta] = useState('R$ 2,00');
  const [prazo, setPrazo] = useState('14');
  const [qtdEmprestimos, setQtdEmprestimos] = useState('3');

  return (
    <div className="conteinerConfiguracao">
      <Menu />
      <div className="conteudoConfiguracao">
        <div className="configuracao-tabs">
          <button className={tab === 'geral' ? 'active' : ''} onClick={() => setTab('geral')}>Informações Gerais</button>
          <button className={tab === 'funcionarios' ? 'active' : ''} onClick={() => setTab('funcionarios')}>Funcionários Cadastrados</button>
          <button className={tab === 'preferencias' ? 'active' : ''} onClick={() => setTab('preferencias')}>Preferências</button>
        </div>

        {tab === 'geral' && (
          <div className="configuracao-geral">
            <div className="configuracao-geral-colunas">
              <div>
                <span className="configuracao-geral-titulo">Dados Biblioteca</span>
                <input placeholder="Email" />
                <input placeholder="Usuário" />
                <input placeholder="Email" />
                <input placeholder="Usuário" />
              </div>
              <div>
                <input placeholder="Senha anterior" />
                <input placeholder="Nova senha" />
                <input placeholder="Senha anterior" />
                <input placeholder="Nova senha" />
              </div>
            </div>
            <div className="configuracao-geral-colunas">
              <div>
                <span className="configuracao-geral-titulo">Dados Proprietário</span>
                <input placeholder="Email" />
                <input placeholder="Usuário" />
                <input placeholder="Email" />
                <input placeholder="Usuário" />
              </div>
              <div>
                <input placeholder="Senha anterior" />
                <input placeholder="Nova senha" />
                <input placeholder="Senha anterior" />
                <input placeholder="Nova senha" />
              </div>
            </div>
            <div className="configuracao-botoes">
              <button className="configuracao-btn-cancelar"><X size={20} />Cancelar</button>
              <button className="configuracao-btn-salvar"><File size={20} />Salvar</button>
            </div>
          </div>
        )}

        {tab === 'funcionarios' && (
          <div className="configuracao-funcionarios">
            {funcionarios.map((f, i) => (
              <div className="configuracao-funcionario-card" key={i}>
                <div className="configuracao-funcionario-user">
                  <User size={28} />
                  <div>
                    <div>Email: {f.email}</div>
                    <div>Telefone: {f.telefone}</div>
                  </div>
                </div>
                <div className="configuracao-funcionario-info">
                  <div>Nome: {f.nome}<br />Turno: {f.turno}</div>
                  <div>Usuário: {f.usuario}</div>
                </div>
                <button className="configuracao-funcionario-mais"><MoreVertical size={22} /></button>
              </div>
            ))}
            <BotaoMais title="Adicionar funcionário" />
          </div>
        )}

        {tab === 'preferencias' && (
          <div className="configuracao-preferencias">
            <div className="configuracao-preferencias-campo">
              <label>Multa, valor cobrado por dia de atraso</label>
              <select value={multa} onChange={e => setMulta(e.target.value)}>
                <option>R$ 2,00</option>
                <option>R$ 1,00</option>
                <option>R$ 0,50</option>
              </select>
            </div>
            <div className="configuracao-preferencias-campo">
              <label>Prazo de devolução, em dias</label>
              <select value={prazo} onChange={e => setPrazo(e.target.value)}>
                <option>14</option>
                <option>7</option>
                <option>21</option>
              </select>
            </div>
            <div className="configuracao-preferencias-campo">
              <label>Quantidade de empréstimos por leitor</label>
              <select value={qtdEmprestimos} onChange={e => setQtdEmprestimos(e.target.value)}>
                <option>3</option>
                <option>2</option>
                <option>5</option>
              </select>
            </div>
            <div className="configuracao-botoes">
              <button className="configuracao-btn-cancelar"><X size={20} />Cancelar</button>
              <button className="configuracao-btn-salvar"><File size={20} />Salvar</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Configuracao;