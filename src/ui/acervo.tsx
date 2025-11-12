import React, { useState, useEffect } from 'react';
import './acervo.css';
import Menu from './components/menu';
import { Search } from 'lucide-react';
import BotaoMais from './components/botaoMais';
import { useNavigate } from 'react-router-dom';
import { listarMidias, Midia } from './ApiManager';

function Acervo() {
  const [tab, setTab] = useState<'livros' | 'audiovisual'>('livros');
  const [midias, setMidias] = useState<Midia[]>([]);
  const [busca, setBusca] = useState('');
  const [imagemFallback, setImagemFallback] = useState<string>("https://via.placeholder.com/180x180?text=Sem+Imagem");
  const navigate = useNavigate();

  // 🔹 Carregar mídias da API
  const carregarMidias = async (textoPesquisa: string = "") => {
    try {
      const dados = await listarMidias(textoPesquisa);
      setMidias(dados);

      // 🔹 Encontrar a primeira imagem válida para usar como fallback
      let primeiraImagemValida = "https://via.placeholder.com/180x180?text=Sem+Imagem";

      for (const m of dados) {
        if (m.imagem) {
          if (m.imagem.startsWith("data:image")) {
            primeiraImagemValida = m.imagem;
            break;
          } else if (m.imagem.startsWith("/midia")) {
            primeiraImagemValida = `https://localhost:7008${m.imagem}`;
            break;
          } else {
            primeiraImagemValida = `data:image/jpeg;base64,${m.imagem}`;
            break;
          }
        }
      }

      setImagemFallback(primeiraImagemValida);

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
          {midiasFiltradas.map((m) => {
            // Seleciona imagem: própria da mídia ou fallback
            let imagemSrc = imagemFallback;
            if (m.imagem) {
              if (m.imagem.startsWith("data:image")) imagemSrc = m.imagem;
              else if (m.imagem.startsWith("/midia")) imagemSrc = `https://localhost:7008${m.imagem}`;
              else imagemSrc = `data:image/jpeg;base64,${m.imagem}`;
            }

            return (
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
                  width: 180,
                  color: 'var(--texto)'
                }}
              >
                <img
                  src={imagemSrc}
                  alt={m.titulo}
                  style={{
                    width: '100%',
                    height: '180px',
                    objectFit: 'cover',
                    borderRadius: '0.7vw'
                  }}
                  onError={(e) => {
                    (e.target as HTMLImageElement).src = imagemFallback;
                  }}
                />
                <div style={{ marginTop: '1vw', textAlign: 'center' }}>
                  <div style={{ fontWeight: 600, fontSize: '1vw' }}>
                    {m.titulo}, {m.anopublicacao || "Outros"}
                  </div>
                  <div style={{ fontSize: '0.9vw', color: '#888' }}>{m.autor}</div>
                  <div
                    style={{
                      fontSize: '0.9vw',
                      color: 'var(--azul-escuro)',
                      marginTop: '0.5vw',
                      cursor: 'pointer'
                    }}
                    onClick={() => navigate(`/infoAcervo/${m.idMidia}`)}
                  >
                    + Informações
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <BotaoMais title="Adicionar" />
    </div>
  );
}

export default Acervo;
