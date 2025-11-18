import React, { useState, useEffect, useRef, useCallback } from 'react';
import './acervo.css';
import Menu from './components/menu';
import { Search, Image as ImageIcon } from 'lucide-react';
import BotaoMais from './components/botaoMais';
import { useNavigate } from 'react-router-dom';
import { listarMidias, Midia } from './ApiManager';

// 🔹 Card mídia
const CardMidia: React.FC<{ midia: Midia }> = ({ midia }) => {
  const navigate = useNavigate();
  const [imagemValida, setImagemValida] = useState(
    midia.imagem ? midia.imagem.startsWith("/midia") || midia.imagem.startsWith("data:image") : false
  );

  const imagemSrc = midia.imagem?.startsWith("/midia") ? `https://localhost:7008${midia.imagem}` : midia.imagem;

  return (
    <div
      style={{
        background: 'var(--fundo-destaque)',
        borderRadius: '1vw',
        boxShadow: '0 2px 8px rgba(0,0,0,0.07)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '1vw',
        width: 180,
        color: 'var(--texto)',
        minHeight: '280px'
      }}
    >
      {imagemValida ? (
        <img
          src={imagemSrc}
          alt={midia.titulo}
          style={{
            width: '100%',
            height: '180px',
            objectFit: 'cover',
            borderRadius: '0.7vw'
          }}
          onError={() => setImagemValida(false)}
        />
      ) : (
        <div
          style={{
            width: '100%',
            height: '180px',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            color: '#888',
            border: '1px solid #ccc',
            borderRadius: '0.7vw'
          }}
        >
          <ImageIcon size={48} />
          <span style={{ marginTop: '0.5vw', fontSize: '0.9vw', textAlign: 'center' }}>
            Imagem não encontrada
          </span>
        </div>
      )}

      <div style={{ marginTop: '1vw', textAlign: 'center' }}>
        <div style={{ fontWeight: 600, fontSize: '1vw' }}>
          {midia.titulo}, {midia.anopublicacao || "Outros"}
        </div>
        <div style={{ fontSize: '0.9vw', color: '#888' }}>{midia.autor}</div>

        <div
          style={{
            fontSize: '0.9vw',
            color: 'var(--azul-escuro)',
            marginTop: '0.5vw',
            cursor: 'pointer'
          }}
          onClick={() => navigate(`/infoAcervo/${midia.idMidia}`)}
        >
          + Informações
        </div>
      </div>
    </div>
  );
};

// -------------------------------------------------------
// 🔹 Página principal com infinite scroll
// -------------------------------------------------------

function Acervo() {
  const [midias, setMidias] = useState<Midia[]>([]);
  const [busca, setBusca] = useState('');
  const [todasMidias, setTodasMidias] = useState<Midia[]>([]);
  const [page, setPage] = useState(1);

  const ITEMS_PER_PAGE = 40;

  const loaderRef = useRef<HTMLDivElement | null>(null);

  // 🔹 Carregar mídias da API
  const carregarMidias = async (texto: string = "") => {
    try {
      const dados = await listarMidias(texto);
      setTodasMidias(dados);
      setMidias(dados.slice(0, ITEMS_PER_PAGE));
      setPage(1);
    } catch (err) {
      console.error("Erro ao listar mídias:", err);
    }
  };

  // 🔹 Ao iniciar
  useEffect(() => {
    carregarMidias();
  }, []);

  // 🔹 Filtrar pela busca (mas ainda com paginação)
  const midiasFiltradas = todasMidias.filter((m) => {
    const termo = busca.toLowerCase();
    return (
      m.titulo?.toLowerCase().includes(termo) ||
      m.autor?.toLowerCase().includes(termo) ||
      m.genero?.toLowerCase().includes(termo) ||
      String(m.anopublicacao).includes(termo)
    );
  });

  // 🔹 Carregar mais (scroll)
  const loadMore = useCallback(() => {
    const nextPage = page + 1;
    const start = (nextPage - 1) * ITEMS_PER_PAGE;
    const end = nextPage * ITEMS_PER_PAGE;

    const novos = midiasFiltradas.slice(start, end);

    if (novos.length > 0) {
      setMidias((prev) => [...prev, ...novos]);
      setPage(nextPage);
    }
  }, [page, midiasFiltradas]);

  // 🔹 Observer para scroll infinito
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          loadMore();
        }
      },
      { threshold: 1 }
    );

    if (loaderRef.current) observer.observe(loaderRef.current);
    return () => observer.disconnect();
  }, [loadMore]);

  return (
    <div className='conteinerAcervo'>
      <Menu />

      <div className='conteudoAcervo'>
        
        {/* Barra de pesquisa */}
        <div style={{ width: '100%', maxWidth: 600, margin: '0 auto 2vw auto', display: 'flex', alignItems: 'center' }}>
          <input
            type="text"
            placeholder="Pesquisar por título, autor, gênero ou ano..."
            value={busca}
            onChange={(e) => {
              setBusca(e.target.value);
              carregarMidias(e.target.value);
            }}
            style={{
              width: '100%',
              padding: '0.7vw 2.5vw 0.7vw 1vw',
              borderRadius: '2vw',
              border: '1px solid #bfc9d1',
              fontSize: '1vw',
              color: 'var(--texto)'
            }}
          />
          <Search
            size={20}
            style={{ position: 'relative', right: '2.2vw', color: '#0A4489', cursor: 'pointer' }}
            onClick={() => carregarMidias(busca)}
          />
        </div>

        {/* Cards */}
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
            <CardMidia key={m.idMidia} midia={m} />
          ))}
        </div>

        {/* Loader invisível para scroll */}
        <div ref={loaderRef} style={{ height: 50 }}></div>

      </div>

      <BotaoMais title="Adicionar" />
    </div>
  );
}

export default Acervo;
