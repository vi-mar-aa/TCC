import React, { useState, useEffect } from 'react';
import './postagens.css';
import Menu from './components/menu';
import { Search, User, Heart, MessageCircle, MoreVertical } from 'lucide-react';
import ApiManager from './ApiManager';

interface Postagem {
  mensagem: {
    idMensagem: number;
    titulo: string;
    conteudo: string;
    dataPostagem: string;
    curtidas: number;
    visibilidade: boolean;
  };
  cliente: {
    idCliente: number;
    nome: string;
    user: string;
    imagemPerfil: string | null;
  };
  qtdComentarios: number;
  filtro: number;
}

function Forum() {
  const [posts, setPosts] = useState<Postagem[]>([]);
  const [postsFiltrados, setPostsFiltrados] = useState<Postagem[]>([]);
  const [busca, setBusca] = useState('');
  const [tab, setTab] = useState<'populares' | 'recentes' | 'antigos'>('populares');
  const [menuAberto, setMenuAberto] = useState<number | null>(null);

  // ------------------- CARREGAR POSTS -------------------
  useEffect(() => {
    async function carregarPosts() {
      try {
        const api = ApiManager.getApiService();
        const response = await api.post<Postagem[]>('/ListarTodosPosts', {
          filtro: 0
        });

        setPosts(response.data);
        setPostsFiltrados(response.data);
      } catch (err) {
        console.error('Erro ao carregar posts:', err);
      }
    }

    carregarPosts();
  }, []);

  // ------------------- FECHAR MENU AO CLICAR FORA -------------------
  useEffect(() => {
    function fecharMenu(event: any) {
      if (!event.target.closest('.forum-card-more')) {
        setMenuAberto(null);
      }
    }

    document.addEventListener('click', fecharMenu);
    return () => document.removeEventListener('click', fecharMenu);
  }, []);

  // ------------------- BUSCA -------------------
  useEffect(() => {
    const filtrados = posts.filter((p) =>
      p.mensagem.titulo.toLowerCase().includes(busca.toLowerCase()) ||
      p.mensagem.conteudo.toLowerCase().includes(busca.toLowerCase()) ||
      p.cliente.user.toLowerCase().includes(busca.toLowerCase())
    );
    setPostsFiltrados(filtrados);
  }, [busca, posts]);

  // ------------------- ORDENAR POSTS -------------------
  function ordenarPosts(tipo: 'populares' | 'recentes' | 'antigos') {
    setTab(tipo);

    let ordenado = [...posts];

    if (tipo === 'populares') {
      ordenado.sort((a, b) => b.mensagem.curtidas - a.mensagem.curtidas);
    } else if (tipo === 'recentes') {
      ordenado.sort(
        (a, b) =>
          new Date(b.mensagem.dataPostagem).getTime() -
          new Date(a.mensagem.dataPostagem).getTime()
      );
    } else if (tipo === 'antigos') {
      ordenado.sort(
        (a, b) =>
          new Date(a.mensagem.dataPostagem).getTime() -
          new Date(b.mensagem.dataPostagem).getTime()
      );
    }

    setPostsFiltrados(ordenado);
  }

  // ------------------- FORMATAR DATA -------------------
  const formatarData = (dataISO: string) => {
    const d = new Date(dataISO);
    return d.toLocaleDateString('pt-BR');
  };

  // ------------------- INATIVAR POST -------------------
  async function inativarPost(post: Postagem) {
    try {
      const api = ApiManager.getApiService();
      await api.post('/InativarPost', post);

      setPosts((prev) =>
        prev.filter((p) => p.mensagem.idMensagem !== post.mensagem.idMensagem)
      );
      setPostsFiltrados((prev) =>
        prev.filter((p) => p.mensagem.idMensagem !== post.mensagem.idMensagem)
      );

      setMenuAberto(null);
      alert('Post inativado com sucesso!');
    } catch (error) {
      console.error('Erro ao inativar post:', error);
      alert('Erro ao inativar post.');
    }
  }

  return (
    <div className="conteinerForum">
      <Menu />
      <div className="conteudoForum">

        {/* Barra de busca */}
        <div className="forum-busca">
          <input
            type="text"
            placeholder="Pesquisar..."
            value={busca}
            onChange={(e) => setBusca(e.target.value)}
          />
          <Search size={20} />
        </div>

        {/* Tabs */}
        <div className="forum-tabs">
          <button
            className={tab === 'populares' ? 'active' : ''}
            onClick={() => ordenarPosts('populares')}
          >
            Populares
          </button>
          <button
            className={tab === 'recentes' ? 'active' : ''}
            onClick={() => ordenarPosts('recentes')}
          >
            Mais Recentes
          </button>
          <button
            className={tab === 'antigos' ? 'active' : ''}
            onClick={() => ordenarPosts('antigos')}
          >
            Mais Antigos
          </button>
        </div>

        {/* Lista de posts */}
        <div className="forum-posts">
          {postsFiltrados.map((post, i) => (
            <div className="forum-card" key={i}>
              <div className="forum-card-header">
                <div className="forum-card-user">

                  {post.cliente.imagemPerfil ? (
                    <img
                      src={`data:image/jpeg;base64,${post.cliente.imagemPerfil}`}
                      alt={post.cliente.user}
                      className="forum-card-user-img"
                    />
                  ) : (
                    <User size={22} className="forum-card-user-icon" />
                  )}

                  <span>{post.cliente.user}</span>
                </div>

                <span className="forum-card-date">
                  {formatarData(post.mensagem.dataPostagem)}
                </span>
              </div>

              <div className="forum-card-title">{post.mensagem.titulo}</div>
              <div className="forum-card-text">{post.mensagem.conteudo}</div>

              <div className="forum-card-footer">
                <div className="forum-card-actions">
                  <span className="forum-like">
                    <Heart size={18} style={{ marginRight: 4 }} /> {post.mensagem.curtidas}
                  </span>
                  <span className="forum-comment">
                    <MessageCircle size={18} style={{ marginRight: 4 }} /> {post.qtdComentarios}
                  </span>
                </div>

                {/* MENU DOS 3 PONTINHOS */}
                <div className="forum-card-more">
                  <MoreVertical
                    size={20}
                    style={{ cursor: 'pointer' }}
                    onClick={() => setMenuAberto(menuAberto === i ? null : i)}
                  />

                  {menuAberto === i && (
                    <div className="forum-more-menu">
                      <button onClick={() => inativarPost(post)}>Inativar post</button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}

          {postsFiltrados.length === 0 && (
            <div className="forum-vazio">Nenhum post encontrado.</div>
          )}
        </div>
      </div>
    </div>
  );
}

export default Forum;
