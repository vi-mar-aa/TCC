import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { listarMidiaEspecifica, MidiaEspecifica } from "./ApiManager";
import './infoAcervo.css';

const InfoAcervo: React.FC = () => {
  const { idMidia } = useParams<{ idMidia: string }>(); // pega o id da URL
  const [midia, setMidia] = useState<MidiaEspecifica | null>(null);
  const [loading, setLoading] = useState(true);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    if (!idMidia) return;

    const carregarMidia = async () => {
      try {
        const data = await listarMidiaEspecifica(Number(idMidia));
        if (data.length > 0) {
          setMidia(data[0]);
        } else {
          setErro("Nenhum resultado encontrado para este ID.");
        }
      } catch (error) {
        setErro("Erro ao buscar dados da mídia.");
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    carregarMidia();
  }, [idMidia]);

  if (loading) return <p>Carregando informações...</p>;
  if (erro) return <p>{erro}</p>;
  if (!midia) return <p>Nenhuma mídia encontrada.</p>;

  return (
   <div className="info-acervo-container">
      <div className="info-acervo-top">
        <img
          className="info-acervo-cover"
          src={midia.imagem}
          alt={midia.imagem}
        />
        <div className="info-acervo-geral">
          <div>
            <h2>Informações gerais</h2>
            <div className="info-acervo-list">
              <div><b>Título:</b> {midia.titulo}</div>
              <div><b>Autor:</b> {midia.autor} </div>
              <div><b>Ano de lançamento:</b> {midia.anopublicacao}</div>
              <div><b>Editora:</b> {midia.editora}</div>
              <div><b>ISBN:</b> {midia.isbn}</div>
              <div><b>Gênero:</b> {midia.genero}</div>
              <div><b>Edição:</b> {midia.edicao}</div>
            </div>
          </div>
          <div className="QRcode">

          </div>


        </div>
        <div className="info-acervo-status">
          <span className="info-acervo-status-num">2/30</span>
          <span>exemplares<br/>emprestados</span>
        </div>
      </div>
      <div className="info-acervo-bottom">
        <h3>Sinopse:</h3>
        <p className="texto">{midia.sinopse}</p>
        <div> </div>
      </div>
    </div>
  );
};

export default InfoAcervo;
