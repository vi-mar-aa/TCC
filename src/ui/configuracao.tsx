import React, { useState, useEffect } from 'react';
import './configuracao.css';
import Menu from './components/menu';
import { User, MoreVertical, File } from 'lucide-react';
import { listarFuncionarios, Funcionario, configurarParametros } from './ApiManager';
import AdicionarFuncionario from './components/AdicionarFuncionarios';
import ModalInativarFuncionario from './components/ModalInativarFuncionario';

function Configuracao() {
  const [abaAtiva, setAbaAtiva] = useState<'funcionarios' | 'preferencias'>('funcionarios');

  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([]);
  const [showModalAdd, setShowModalAdd] = useState(false);

  // NOVOS ESTADOS
  const [funcionarioSelecionado, setFuncionarioSelecionado] = useState<Funcionario | null>(null);
  const [showModalInativar, setShowModalInativar] = useState(false);

  // Valores numéricos agora são livres
  const [multa, setMulta] = useState('2.00');
  const [prazo, setPrazo] = useState('14');
  const [qtdEmprestimos, setQtdEmprestimos] = useState('3');

  useEffect(() => {
    carregarFuncionarios();
  }, []);

  function carregarFuncionarios() {
    listarFuncionarios()
      .then(setFuncionarios)
      .catch(console.error);
  }

  async function salvarPreferencias() {
    try {
      const multaConvertida = parseFloat(multa) || 0;
      const prazoConvertido = parseInt(prazo) || 0;
      const emprestimosConvertido = parseInt(qtdEmprestimos) || 0;

      const idParametros = 1;

      await configurarParametros(idParametros, multaConvertida, prazoConvertido, emprestimosConvertido);

      alert('Parâmetros salvos com sucesso!');
    } catch (error) {
      console.error(error);
      alert('Erro ao salvar parâmetros.');
    }
  }

  // Botão flutuante restaurado
  const FabButton = () => (
    <button
      onClick={() => setShowModalAdd(true)}
      style={{
        position: 'fixed',
        right: '3vw',
        bottom: '3vw',
        width: '4vw',
        height: '4vw',
        borderRadius: '50%',
        background: '#0A4489',
        color: 'white',
        fontSize: '3vw',
        border: 'none',
        cursor: 'pointer',
        zIndex: 9999,
        boxShadow: '0 2px 12px rgba(10,68,137,0.3)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        transition: '0.2s'
      }}
      onMouseEnter={(e) => (e.currentTarget.style.transform = 'scale(1.08)')}
      onMouseLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
      aria-label="Adicionar funcionário"
      title="Adicionar funcionário"
    >
      +
    </button>
  );

  return (
    <div className="conteinerConfiguracao">
      <Menu />
      <div className="conteudoConfiguracao">

        {/* Abas */}
        <div className="configuracao-tabs">
          <button
            className={abaAtiva === 'funcionarios' ? 'active' : ''}
            onClick={() => setAbaAtiva('funcionarios')}
          >
            Funcionários Cadastrados
          </button>
          <button
            className={abaAtiva === 'preferencias' ? 'active' : ''}
            onClick={() => setAbaAtiva('preferencias')}
          >
            Preferências
          </button>
        </div>

        {/* FUNCIONÁRIOS */}
        {abaAtiva === 'funcionarios' && (
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
                    <div className={f.statusconta !== "ativo" ? "funcionario-inativo" : ""}>
                      Nome: {f.nome}
                    </div>
                  </div>


                {/* BOTÃO MAIS */}
                <button
                  className="configuracao-funcionario-mais"
                  onClick={() => {
                    setFuncionarioSelecionado(f);
                    setShowModalInativar(true);
                  }}
                >
                  <MoreVertical size={22} />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* PREFERÊNCIAS */}
        {abaAtiva === 'preferencias' && (
          <div className="configuracao-preferencias">

            <div className="configuracao-preferencias-campo">
              <label>Multa por dia de atraso (R$)</label>
              <input
                type="number"
                step="0.01"
                min="0"
                value={multa}
                onChange={(e) => setMulta(e.target.value)}
                placeholder="Ex: 2.00"
              />
            </div>

            <div className="configuracao-preferencias-campo">
              <label>Prazo de devolução (dias)</label>
              <input
                type="number"
                min="1"
                value={prazo}
                onChange={(e) => setPrazo(e.target.value)}
                placeholder="Ex: 14"
              />
            </div>

            <div className="configuracao-preferencias-campo">
              <label>Quantidade de empréstimos por leitor</label>
              <input
                type="number"
                min="1"
                value={qtdEmprestimos}
                onChange={(e) => setQtdEmprestimos(e.target.value)}
                placeholder="Ex: 3"
              />
            </div>

            <div className="configuracao-botoes">
              <button className="configuracao-btn-salvar" onClick={salvarPreferencias}>
                <File size={20} />
                Salvar
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Botão flutuante */}
      <FabButton />

      {/* MODAL: Adicionar Funcionário */}
      <AdicionarFuncionario
        open={showModalAdd}
        onClose={() => setShowModalAdd(false)}
        onSuccess={carregarFuncionarios}
      />

      {/* MODAL: Inativar Funcionário */}
      <ModalInativarFuncionario
        open={showModalInativar}
        funcionario={funcionarioSelecionado}
        onClose={() => setShowModalInativar(false)}
        onConfirm={() => {
          console.log("Inativando:", funcionarioSelecionado?.idFuncionario);
          setShowModalInativar(false);
          carregarFuncionarios();
        }}
      />

    </div>
  );
}

export default Configuracao;
