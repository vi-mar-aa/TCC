import React, { useState } from 'react';
import './catalogacao.css';
import { Tag, X, Save, Image } from 'lucide-react'; // Importa os ícones

interface CatalogacaoProps {
  open: boolean;
  onClose: () => void;
}

const Catalogacao: React.FC<CatalogacaoProps> = ({ open, onClose }) => {
  if (!open) return null;

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
              <span className="textosInput">Tipo de catalogação:</span>
              <select>
                <option>Livro</option>
                <option>Revista</option>
                <option>Outro</option>
              </select>
            </label>
            <label>
              <span className="textosInput">Título:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">Autor:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">Ano de lançamento:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">Editora:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">ISBN:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">Gênero:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">Edição:</span>
              <input type="text" />
            </label>
            <label>
              <span className="textosInput">Quantidade de Exemplares:</span>
              <input type="number" min={1} />
            </label>
          </div>
          <div className="catalogacao-form-col catalogacao-form-col-direita">
            <div className="catalogacao-capa-upload">
              <div className="catalogacao-capa-placeholder">
                <Image size={48} color="#bfc9d1" />
              </div>
              <a className="catalogacao-upload-link" href="#">Upload de Capa</a>
            </div>
            <label>Sinopse:</label>
            <textarea className="catalogacao-sinopse" rows={7} />
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
            <button className="catalogacao-salvar">
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