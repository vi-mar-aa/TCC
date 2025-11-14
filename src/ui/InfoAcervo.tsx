import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { listarMidiaEspecifica, MidiaEspecifica, excluirMidia } from "./ApiManager";
import { QRCodeCanvas } from "qrcode.react";
import { CornerDownLeft, Trash } from "lucide-react";
import ConfirmarExclusao from "./components/ConfirmarExclusao";
import "./infoAcervo.css";

const InfoAcervo: React.FC = () => {
  const { idMidia } = useParams<{ idMidia: string }>();
  const navigate = useNavigate();
  const [midia, setMidia] = useState<MidiaEspecifica | null>(null);
  const [loading, setLoading] = useState(true);
  const [erro, setErro] = useState<string | null>(null);
  const [mostrarPopup, setMostrarPopup] = useState(false);

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

  const handleExcluir = async () => {
    if (!midia) return;
    try {
      const resultado = await excluirMidia(midia.idMidia);
      alert(resultado); // Mostra "Midia excluída com sucesso."
      setMostrarPopup(false);
      navigate("/acervo");
    } catch (error) {
      alert("Erro ao excluir a mídia.");
      console.error(error);
    }
  };

  if (loading) return <p>Carregando informações...</p>;
  if (erro) return <p>{erro}</p>;
  if (!midia) return <p>Nenhuma mídia encontrada.</p>;

  // 🔧 Corrigido: detecção automática do tipo de imagem
  let imagemSrc = "https://via.placeholder.com/300x400?text=Sem+Imagem";
  if (midia.imagem) {
    if (midia.imagem.startsWith("data:image")) {
      imagemSrc = midia.imagem;
    } else if (midia.imagem.startsWith("/midia")) {
      imagemSrc = `https://localhost:7008${midia.imagem}`;
    } else {
      imagemSrc = `data:image/jpeg;base64,${midia.imagem}`;
    }
  }

  return (
    <div className="info-acervo-container">
      <button className="voltar" onClick={() => navigate("/acervo")}>
            <CornerDownLeft />
      </button>

      <div className="info-acervo-top">
        <div>
          
        </div>

        <img
          className="info-acervo-cover"
          src={imagemSrc}
          alt={midia.titulo}
          onError={(e) => {
            (e.target as HTMLImageElement).src =
              "https://via.placeholder.com/300x400?text=Erro+Imagem";
          }}
        />

        <div className="info-acervo-geral">
          <div>
            <h2>Informações gerais</h2>
            <div style={{ display: "flex" }}>
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
          </div>

          <div className="div-direita">
            <div className="lixo">
              <button onClick={() => setMostrarPopup(true)}>
                <Trash />
              </button>
            </div>

            <div>
              {midia?.idMidia && (
                <QRCodeCanvas
                  value={`${midia.idMidia}`}
                  size={200}
                  bgColor="#ffffff"
                  fgColor="#000000"
                  level="H"
                  includeMargin={true}
                />
              )}
            </div>
          </div>
        </div>

        <div className="info-acervo-status">
          <span className="info-acervo-status-num">{midia.contExemplares}</span>
          <span>
            exemplares
            <br />
            disponíveis
          </span>
        </div>
      </div>

      <div className="info-acervo-bottom">
        <h3>Sinopse:</h3>
        <p className="texto">{midia.sinopse}</p>
      </div>

      {mostrarPopup && (
        <ConfirmarExclusao
          onConfirmar={handleExcluir}
          onCancelar={() => setMostrarPopup(false)}
        />
      )}
    </div>
  );
};

export default InfoAcervo;
