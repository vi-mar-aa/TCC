import React, { useState } from "react";
import "./catalogacao.css";
import { Tag, X, Save, Image, Upload } from "lucide-react";
import ApiManager from "../ApiManager"; // ajuste o caminho se precisar

interface CatalogacaoProps {
  open: boolean;
  onClose: () => void;
}

const Catalogacao: React.FC<CatalogacaoProps> = ({ open, onClose }) => {
  if (!open) return null;

  // Estado do formulário
  const [formData, setFormData] = useState({
    titulo: "",
    npaginas: "",
    autor: "",
    anopublicacao: "",
    editora: "",
    isbn: "",
    edicao: "",
    local: "",
    sinopse: "",
    imagem: "",
  });

  // Handler para inputs
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // Upload de imagem (transforma em base64)
  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onloadend = () => {
      if (reader.result) {
        setFormData((prev) => ({
          ...prev,
          imagem: reader.result.toString(),
        }));
      }
    };
    reader.readAsDataURL(file);
  };

  // Chamada API
  const handleSave = async () => {
    try {
      const api = ApiManager.getApiService();

      // Recupera funcionario logado do localStorage
      const funcionarioStr = localStorage.getItem("funcionario");
      if (!funcionarioStr) {
        alert("Nenhum funcionário logado.");
        return;
      }
      const funcionario = JSON.parse(funcionarioStr);

      const payload = {
        "funcionario": {
          "idFuncionario": 0,
          "idcargo": 0,
          "nome": "string",
          "cpf": "string",
          "email": "maria.vitoria@email.com",
          "senha": "string",
          "telefone": "string",
          "statusconta": "string"
        },
        "midia": {
          "idMidia": 0,
          "codigoExemplar": 0,
          "idfuncionario": funcionario.idFuncionario,
          "idtpmidia": 0,
          "titulo": formData.titulo,
          "autor": formData.autor,
          "sinopse": formData.sinopse,
          "editora": formData.editora,
          "anopublicacao": formData.anopublicacao || 0,
          "edicao": formData.edicao,
          "localpublicacao": formData.local,
          "npaginas": formData.npaginas,
          "isbn": formData.isbn,
          "duracao": "",
          "estudio": "",
          "roterista": "",
          "dispo": 0,
          "genero": 0,
          "contExemplares": 0,
          "nomeTipo": "Livro",
          "imagem": formData.imagem,
        },

        

      };

      console.log(payload)

      await api.post("/AdicionarLivro", payload);
      alert("Livro adicionado com sucesso!");
      onClose();
    } catch (error) {
      console.error("Erro ao salvar:", error);
      alert("Erro ao salvar o livro.");
    }
  };

  return (
    <div className="catalogacao-modal-overlay">
      <div className="catalogacao-modal">
        <button className="catalogacao-fechar" onClick={onClose}>
          <X size={28} />
        </button>
        <h2 className="catalogacao-titulo">Catalogação</h2>
        <div className="catalogacao-form-wrap">
          <div className="catalogacao-form-col">
            <label>
              <span className="textosInput">Título:</span>
              <input
                type="text"
                name="titulo"
                value={formData.titulo}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">Numero de paginas:</span>
              <input
                type="text"
                name="npaginas"
                value={formData.npaginas}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">Autor:</span>
              <input
                type="text"
                name="autor"
                value={formData.autor}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">Ano de lançamento:</span>
              <input
                type="text"
                name="anopublicacao"
                value={formData.anopublicacao}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">Editora:</span>
              <input
                type="text"
                name="editora"
                value={formData.editora}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">ISBN:</span>
              <input
                type="text"
                name="isbn"
                value={formData.isbn}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">Edição:</span>
              <input
                type="text"
                name="edicao"
                value={formData.edicao}
                onChange={handleChange}
              />
            </label>
            <label>
              <span className="textosInput">Local de publicação:</span>
              <input
                type="text"
                name="local"
                value={formData.local}
                onChange={handleChange}
              />
            </label>
          </div>

          {/* Coluna da direita */}
          <div className="catalogacao-form-col catalogacao-form-col-direita">
            <div className="catalogacao-capa-upload">
              <div className="catalogacao-capa-placeholder">
                {formData.imagem ? (
                  <img
                    src={formData.imagem}
                    alt="Preview"
                    style={{
                      width: "120px",
                      height: "160px",
                      borderRadius: "8px",
                      objectFit: "cover",
                    }}
                  />
                ) : (
                  <Image size={48} color="#bfc9d1" />
                )}
              </div>

              {/* Botão estilizado para upload */}
              <label className="catalogacao-upload-btn">
                <Upload size={18} />
                <span>Escolher capa</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageUpload}
                  style={{ display: "none" }}
                />
              </label>
            </div>
            <label>Sinopse:</label>
            <textarea
              className="catalogacao-sinopse"
              rows={7}
              name="sinopse"
              value={formData.sinopse}
              onChange={handleChange}
            />
          </div>
        </div>

        <div className="catalogacao-btns">
          <button className="catalogacao-etiqueta">
            <Tag size={18} />
            <span className="catalogacao-btn-bar" />
            Gerar etiqueta PDF
          </button>
          <div className="catalogacao-btns-row">
            <button className="catalogacao-cancelar" onClick={onClose}>
              <X size={18} />
              <span className="catalogacao-btn-bar" />
              Cancelar
            </button>
            <button className="catalogacao-salvar" onClick={handleSave}>
              <Save size={18} />
              <span className="catalogacao-btn-bar" />
              Salvar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Catalogacao;
