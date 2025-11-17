import React, { useState, useEffect } from 'react';
import './acervo.css';
import Menu from './components/menu';
import { Search, Image as ImageIcon } from 'lucide-react';
import BotaoMais from './components/botaoMais';
import { useNavigate } from 'react-router-dom';
import { listarMidias, Midia } from './ApiManager';

// 🔹 Componente CardMídia
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

function Acervo() {
  const [tab, setTab] = useState<'livros' | 'audiovisual'>('livros');
  const [midias, setMidias] = useState<Midia[]>([]);
  const [busca, setBusca] = useState('');

  // 🔹 Carregar mídias da API
  const carregarMidias = async (textoPesquisa: string = "") => {
    try {
      const dados = await listarMidias(textoPesquisa);
      setMidias(dados);
    } catch (err) {
      console.error("Erro ao listar mídias:", err);
    }
  };

  // 🔹 Carregar ao iniciar
  useEffect(() => {
    carregarMidias();
  }, []);

  // 🔹 Filtrar e ordenar mídias de acordo com busca
  const termo = busca.toLowerCase();

  const midiasFiltradas = midias
    .filter((m) => {
      const titulo = m.titulo?.toLowerCase() || "";
      const autor = m.autor?.toLowerCase() || "";
      const genero = m.genero?.toLowerCase() || "";
      const ano = m.anopublicacao ? String(m.anopublicacao) : "";

      return (
        titulo.includes(termo) ||
        autor.includes(termo) ||
        genero.includes(termo) ||
        ano.includes(termo)
      );
    })
    .sort((a, b) => {
      const getPrioridade = (m: Midia) => {
        const titulo = m.titulo?.toLowerCase() || "";
        const autor = m.autor?.toLowerCase() || "";
        const genero = m.genero?.toLowerCase() || "";
        const ano = m.anopublicacao ? String(m.anopublicacao) : "";

        if (titulo.includes(termo)) return 4;
        if (autor.includes(termo)) return 3;
        if (genero.includes(termo)) return 2;
        if (ano.includes(termo)) return 1;
        return 0;
      };

      return getPrioridade(b) - getPrioridade(a);
    });

  // 🔹 Pesquisa (Enter)
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') carregarMidias(busca);
  };

  return (
    <div className='conteinerAcervo'>
      <Menu />

      <div className='conteudoAcervo'>
        {/* Tabs */}
        <div style={{ display: 'flex', gap: '1vw', marginBottom: '2vw', justifyContent: 'center' }}>
        </div>

        {/* Barra de pesquisa */}
        <div style={{ width: '100%', maxWidth: 600, margin: '0 auto 2vw auto', display: 'flex', alignItems: 'center' }}>
          <input
            type="text"
            placeholder="Pesquisar por título, autor, gênero ou ano..."
            value={busca}
            onChange={(e) => setBusca(e.target.value)}
            onKeyDown={handleKeyDown}
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
          {midiasFiltradas.map((m) => (
            <CardMidia key={m.idMidia} midia={m} />
          ))}
        </div>
      </div>

      <BotaoMais title="Adicionar" />
    </div>
  );
}

export default Acervo;
