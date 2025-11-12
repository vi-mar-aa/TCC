import React from "react";
import "./confirmarExclusao.css";

interface ConfirmarExclusaoProps {
  onConfirmar: () => void;
  onCancelar: () => void;
}

const ConfirmarExclusao: React.FC<ConfirmarExclusaoProps> = ({ onConfirmar, onCancelar }) => {
  return (
    <div className="overlay">
      <div className="popup">
        <h3>Tem certeza que deseja excluir?</h3>
        <p>Esta ação não poderá ser desfeita.</p>
        <div className="botoes">
          <button className="cancelar" onClick={onCancelar}>Cancelar</button>
          <button className="confirmar" onClick={onConfirmar}>Excluir</button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmarExclusao;
