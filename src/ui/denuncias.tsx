import React, { useState, useEffect, useRef } from 'react';
import './denuncias.css';
import Menu from './components/menu';
import { User } from 'lucide-react';

interface Mensagem {
  idMensagem: number;
  idCliente: number;
  idPai: number | null;
  titulo: string | null;
  conteudo: string | null;
  dataPostagem: string;
  visibilidade: boolean;
  curtidas: number;
}

interface Cliente {
  idCliente: number;
  nome: string;
  user: string;
  cpf: string | null;
  email: string | null;
  senha: string | null;
  telefone: string | null;
  status_conta: string | null;
  imagemPerfil: string | null;
}

interface Funcionario {
  idFuncionario: number;
  idcargo: number;
  nome: string | null;
  cpf: string | null;
  email: string | null;
  senha: string | null;
  telefone: string | null;
  statusconta: string | null;
}

interface Denuncia {
  mensagem: Mensagem;
  cLiente: Cliente;
  denuncia: {
    idDenuncia: number;
    idFuncionario: number;
    idMensagem: number;
    idCliente: number;
    dataDenuncia: string;
    motivo: string;
    status: string;
    acao: string | null;
  };
  funcionario: Funcionario;
}

function Denuncias() {
  const [denuncias, setDenuncias] = useState<Denuncia[]>([]);
  const [menuAberto, setMenuAberto] = useState<number | null>(null);

  // Ref do menu
  const menuRef = useRef<HTMLDivElement | null>(null);

  // FECHAR menu ao clicar fora
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setMenuAberto(null);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    const fetchDenuncias = async () => {
      try {
        const res = await fetch('https://localhost:7008/ListarDenuncias');
        const data = await res.json();
        setDenuncias(data);
      } catch (error) {
        console.error('Erro ao carregar denúncias', error);
      }
    };
    fetchDenuncias();
  }, []);

  const deletarPost = async (d: Denuncia) => {
    try {
      await fetch('https://localhost:7008/InativarPost', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          mensagem: d.mensagem,
          cliente: d.cLiente,
          qtdComentarios: 0,
          filtro: 0,
        }),
      });
      alert('Post deletado!');
      setDenuncias(prev => prev.filter(dd => dd.denuncia.idDenuncia !== d.denuncia.idDenuncia));
      setMenuAberto(null);
    } catch (error) {
      console.error(error);
      alert('Erro ao deletar post.');
    }
  };

  const suspenderUsuario = async (cliente: Cliente, denunciaId: number) => {
    try {
      await fetch('https://localhost:7008/SuspenderCliente', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(cliente),
      });
      alert(`Usuário ${cliente.nome} suspenso!`);
      setDenuncias(prev => prev.filter(d => d.denuncia.idDenuncia !== denunciaId));
      setMenuAberto(null);
    } catch (error) {
      console.error(error);
      alert('Erro ao suspender usuário.');
    }
  };

  return (
    <div className="conteinerDenuncias">
      <Menu />
      <div className="conteudoDenuncias">
        <h2 className="denuncias-titulo">Denúncias</h2>
        <div className="denuncias-box">
          <table className="denuncias-tabela">
            <thead>
              <tr>
                <th>Autor da denúncia</th>
                <th>Motivo</th>
                <th>Post Denunciado</th>
              </tr>
            </thead>
            <tbody>
              {denuncias.map((d, i) => (
                <tr key={d.denuncia.idDenuncia}>
                  <td>
                    <div className="denuncias-user">
                      <User size={22} style={{ marginRight: 8 }} />
                      {d.cLiente.nome}
                    </div>
                  </td>
                  <td className="denuncias-motivo">{d.denuncia.motivo}</td>
                  <td className="denuncias-post" style={{ position: "relative" }}>

                    <span>{d.mensagem.conteudo || 'Conteúdo não disponível'}</span>
                    <button
                      className="denuncias-vermais"
                      onClick={() => setMenuAberto(menuAberto === i ? null : i)}
                    >
                      ...
                    </button>

                    {menuAberto === i && (
                      <div className="denuncias-menu-options" ref={menuRef}>
                        <button onClick={() => deletarPost(d)}>Deletar Post</button>
                        <button onClick={() => suspenderUsuario(d.cLiente, d.denuncia.idDenuncia)}>
                          Suspender Usuário
                        </button>
                      </div>
                    )}

                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default Denuncias;
