import React from 'react';
import './ModalInativarFuncionario.css'

interface Props {
  open: boolean;
  funcionario: any;
  onClose: () => void;
  onConfirm: () => void;
}



export default function ModalInativarFuncionario({ open, funcionario, onClose, onConfirm }: Props) {
  if (!open) return null;

  return (
    <div className="modal-inativar-overlay">
      <div className="modal-inativar-box">

        <h2>Inativar Funcionário</h2>

        <p>
          Tem certeza que deseja inativar<br />
          <b>{funcionario?.nome}</b>?
        </p>

        <div className="modal-inativar-actions">
          <button className="btn-cancelar" onClick={onClose}>Cancelar</button>
          <button className="btn-confirmar" onClick={onConfirm}>Inativar</button>
        </div>

      </div>
    </div>
  );
}
