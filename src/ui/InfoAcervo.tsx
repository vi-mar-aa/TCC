import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom"; // <-- ADICIONE useNavigate AQUI
import { listarMidiaEspecifica, MidiaEspecifica } from "./ApiManager";
import { QRCodeCanvas } from "qrcode.react";
import { CornerDownLeft } from "lucide-react";
import "./infoAcervo.css";

const InfoAcervo: React.FC = () => {
  const { idMidia } = useParams<{ idMidia: string }>(); 
  const navigate = useNavigate(); // <-- E CRIE AQUI
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
        <div>
          <button onClick={() => navigate("/acervo")}>
            <CornerDownLeft />
          </button>
        </div>

        <img
          className="info-acervo-cover"
          src={midia.imagem}
          alt={midia.titulo}
        />

        <div className="info-acervo-geral">
          <div>
            <h2>Informações gerais</h2>
            <div className="info-acervo-list">
              <div><b>Título:</b> {midia.titulo}</div>
              <div><b>Autor:</b> {midia.autor}</div>
              <div><b>Ano de lançamento:</b> {midia.anopublicacao}</div>
              <div><b>Editora:</b> {midia.editora}</div>
              <div><b>ISBN:</b> {midia.isbn}</div>
              <div><b>Gênero:</b> {midia.genero}</div>
              <div><b>Edição:</b> {midia.edicao}</div>
            </div>
          </div>

          <div className="QRcode">
            {midia?.idMidia && (
              <QRCodeCanvas
                value={`${midia.idMidia}`}
                size={128}
                bgColor="#ffffff"
                fgColor="#000000"
                level="H"
                includeMargin={true}
              />
            )}
          </div>
        </div>

        <div className="info-acervo-status">
          <span className="info-acervo-status-num">{midia.contExemplares}</span>
          <span>exemplares<br />disponíveis</span>
        </div>
      </div>

      <div className="info-acervo-bottom">
        <h3>Sinopse:</h3>
        <p className="texto">{midia.sinopse}</p>
      </div>
    </div>
  );
};

export default InfoAcervo;
