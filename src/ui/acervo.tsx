import React, { useState, useEffect } from 'react';
import './acervo.css';
import Menu from './components/menu';
import { Search, ChevronDown } from 'lucide-react';
import BotaoMais from './components/botaoMais';
import { useNavigate } from 'react-router-dom';
import { listarMidias, Midia } from './ApiManager'; // importa função e tipo


function Acervo() {
  const [tab, setTab] = useState<'livros' | 'audiovisual'>('livros');
  const [generoAberto, setGeneroAberto] = useState(true);
  const [anoAberto, setAnoAberto] = useState(true);
  const [midias, setMidias] = useState<Midia[]>([]); // state para os dados
  const navigate = useNavigate();

  // Buscar dados ao carregar
  useEffect(() => {
    listarMidias().then(setMidias).catch((err) => console.error(err));
  }, []);

  return (
    <div className='conteinerAcervo'>
      <Menu />
      <div className='conteudoAcervo'>
        {/* Tabs */}
        <div style={{ display: 'flex', gap: '1vw', marginBottom: '2vw', justifyContent: 'center' }}>
          <button
            className={`menu-btn${tab === 'livros' ? ' active' : ''}`}
            onClick={() => setTab('livros')}
            type="button"
          >
            Livros
          </button>
          <button
            className={`menu-btn${tab === 'audiovisual' ? ' active' : ''}`}
            onClick={() => setTab('audiovisual')}
            type="button"
          >
            Audiovisual
          </button>
        </div>

        {/* Filtros */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1vw', width: '100%', maxWidth: 600, margin: '0 auto 2vw auto' }}>
          {/* Filtro Gênero Textual */}
          <div className="filtro-box">
            <div className='filtro-titulo' style={{ display: 'flex', alignItems: 'center' }}>
              <span style={{ fontWeight: 600, fontSize: '1.1vw' }}>Gênero Textual</span>
              <span
                style={{
                  marginLeft: 'auto',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  transition: 'transform 0.2s',
                  transform: generoAberto ? 'rotate(0deg)' : 'rotate(180deg)'
                }}
                onClick={() => setGeneroAberto((prev) => !prev)}
              >
                <ChevronDown size={20} />
              </span>
            </div>
            {generoAberto && (
              <div className="filtro-opcoes">
                {tab === 'livros' ? (
                  <>
                    <label><input type="checkbox" /> Artigos</label>
                    <label><input type="checkbox" /> Romance</label>
                    <label><input type="checkbox" /> Biografia</label>
                    <label><input type="checkbox" /> Manuais</label>
                    <label><input type="checkbox" /> Crônicas</label>
                    <label><input type="checkbox" /> Revistas</label>
                    <label><input type="checkbox" /> Didáticos</label>
                    <label><input type="checkbox" /> Poesia</label>
                    <label><input type="checkbox" /> Outros</label>
                  </>
                ) : (
                  <>
                    <label><input type="checkbox" /> Documentário</label>
                    <label><input type="checkbox" /> Filme</label>
                    <label><input type="checkbox" /> Série</label>
                    <label><input type="checkbox" /> Curta-metragem</label>
                    <label><input type="checkbox" /> Animação</label>
                    <label><input type="checkbox" /> Outros</label>
                  </>
                )}
              </div>
            )}
          </div>
          {/* Filtro Ano */}
          <div className="filtro-box">
            <div className='filtro-titulo' style={{ display: 'flex', alignItems: 'center' }}>
              <span style={{ fontWeight: 600, fontSize: '1.1vw' }}>Ano</span>
              <span
                style={{
                  marginLeft: 'auto',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  transition: 'transform 0.2s',
                  transform: anoAberto ? 'rotate(0deg)' : 'rotate(180deg)'
                }}
                onClick={() => setAnoAberto((prev) => !prev)}
              >
                <ChevronDown size={20} />
              </span>
            </div>
            {anoAberto && (
              <div className="filtro-opcoes" style={{ display: 'flex', flexWrap: 'wrap', gap: '1vw', marginTop: '1vw' }}>
                <label><input type="checkbox" /> 2024</label>
                <label><input type="checkbox" /> 2023</label>
                <label><input type="checkbox" /> 2022</label>
                <label><input type="checkbox" /> 2021</label>
                <label><input type="checkbox" /> 2020</label>
                <label><input type="checkbox" /> 2019</label>
                <label><input type="checkbox" /> 2018</label>
                <label><input type="checkbox" /> 2017</label>
                <label><input type="checkbox" /> Outros</label>
              </div>
            )}
          </div>
        </div>

        {/* Barra de busca */}
        <div style={{ width: '100%', maxWidth: 600, margin: '0 auto 2vw auto', display: 'flex', alignItems: 'center' }}>
          <input
            type="text"
            placeholder="Pesquisar..."
            style={{
              width: '100%',
              padding: '0.7vw 2.5vw 0.7vw 1vw',
              borderRadius: '2vw',
              border: '1px solid #bfc9d1',
              fontSize: '1vw'
            }}
          />
          <Search
            size={20}
            style={{ position: 'relative', right: '2.2vw', color: '#0A4489', cursor: 'pointer' }}
          />
        </div>

        {/* Cards de livros */}
        <div
        style={{
          width: '100%',
          maxWidth: 1100,
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
          gap: '2vw',
          margin: '0 auto'
        }}
      >
        {midias.map((m) => (
          <div
            key={m.idMidia}
            style={{
              background: 'var(--fundo-destaque)',
              borderRadius: '1vw',
              boxShadow: '0 2px 8px rgba(0,0,0,0.07)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              padding: '1vw',
              minWidth: 180,
              color: 'var(--texto)'
            }}
          >
            <img
              src={
                m.imagem
                  ? `data:image/jpeg;base64,${m.imagem}` // base64 da API
                  : 'https://via.placeholder.com/180x180?text=Sem+Imagem' // fallback
              }
              alt={m.titulo}
              style={{
                width: '100%',
                height: '180px',
                objectFit: 'cover',
                borderRadius: '0.7vw'
              }}
            />
            <div style={{ marginTop: '1vw', textAlign: 'center' }}>
              <div style={{ fontWeight: 600, fontSize: '1vw' }}>
                {m.titulo}, {m.anopublicacao}
              </div>
              <div style={{ fontSize: '0.9vw', color: '#888' }}>{m.autor}</div>
              <div
                style={{
                  fontSize: '0.9vw',
                  color: 'var(--azul-escuro)',
                  marginTop: '0.5vw',
                  cursor: 'pointer'
                }}
                onClick={() => navigate(`/infoAcervo/${m.idMidia}`)} // pode passar id
              >
                + Informações
              </div>
            </div>
          </div>
        ))}
      </div>
            
      </div>
      <BotaoMais title="Adicionar" />
    </div>
  );
}

export default Acervo;