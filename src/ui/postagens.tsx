import React, { useState } from 'react';
import './postagens.css';
import Menu from './components/menu';
import { Search, User, Heart, MessageCircle, MoreVertical } from 'lucide-react';

const posts = [
  {
    usuario: 'Vitória',
    data: '19/03/2025',
    titulo: 'Mais alguém gosta de R.F Kuang?',
    texto: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut libero at odio tincidunt venenatis. Donec euismod, felis ut fermentum facilisis, justo nisi tincidunt sapien, eget volutpat sapien lacus id justo. Ver mais',
    likes: 579,
    comentarios: 60,
  },
  {
    usuario: 'Vitória',
    data: '19/03/2025',
    titulo: 'Mais alguém gosta de R.F Kuang?',
    texto: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut libero at odio tincidunt venenatis. Donec euismod, felis ut fermentum facilisis, justo nisi tincidunt sapien, eget volutpat sapien lacus id justo. Ver mais',
    likes: 579,
    comentarios: 60,
  },
  {
    usuario: 'Vitória',
    data: '19/03/2025',
    titulo: 'Mais alguém gosta de R.F Kuang?',
    texto: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut libero at odio tincidunt venenatis. Donec euismod, felis ut fermentum facilisis, justo nisi tincidunt sapien, eget volutpat sapien lacus id justo. Ver mais',
    likes: 579,
    comentarios: 60,
  },
];

function Forum() {
  const [tab, setTab] = useState<'populares' | 'recentes' | 'antigos'>('populares');

  return (
    <div className="conteinerForum">
      <Menu />
      <div className="conteudoForum">
        {/* Barra de busca */}
        <div className="forum-busca">
          <input type="text" placeholder="Pesquisar..." />
          <Search size={20} />
        </div>

        {/* Tabs */}
        <div className="forum-tabs">
          <button
            className={tab === 'populares' ? 'active' : ''}
            onClick={() => setTab('populares')}
          >
            Populares
          </button>
          <button
            className={tab === 'recentes' ? 'active' : ''}
            onClick={() => setTab('recentes')}
          >
            Mais Recentes
          </button>
          <button
            className={tab === 'antigos' ? 'active' : ''}
            onClick={() => setTab('antigos')}
          >
            Mais Antigos
          </button>
        </div>

        {/* Lista de posts */}
        <div className="forum-posts">
          {posts.map((post, i) => (
            <div className="forum-card" key={i}>
              <div className="forum-card-header">
                <div className="forum-card-user">
                  <User size={22} style={{ marginRight: 8 }} />
                  <span>{post.usuario}</span>
                </div>
                <span className="forum-card-date">{post.data}</span>
              </div>
              <div className="forum-card-title">{post.titulo}</div>
              <div className="forum-card-text">{post.texto}</div>
              <div className="forum-card-footer">
                <div className="forum-card-actions">
                  <span className="forum-like">
                    <Heart size={18} style={{ marginRight: 4 }} /> {post.likes}
                  </span>
                  <span className="forum-comment">
                    <MessageCircle size={18} style={{ marginRight: 4 }} /> {post.comentarios}
                  </span>
                </div>
                <MoreVertical size={20} className="forum-card-more" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Forum;