import React from 'react';
import './novoEmprestimo.css';
import { X, ArrowRightLeft, ChevronDown } from 'lucide-react';

interface NovoEmprestimoProps {
  open: boolean;
  onClose: () => void;
}

const NovoEmprestimo: React.FC<NovoEmprestimoProps> = ({ open, onClose }) => {
  if (!open) return null;

  return (
    <div className="novoEmprestimo-modal-overlay">
      <div className="novoEmprestimo-modal">
        <button className="novoEmprestimo-fechar" onClick={onClose}>
          <X size={28} />
        </button>
        <h2 className="novoEmprestimo-titulo">Novo Empréstimo</h2>
        <div className="novoEmprestimo-form-wrap">
          <div className="novoEmprestimo-col">
            <div className="novoEmprestimo-label-grande">Livro:</div>
            <label>
              <span className="novoEmprestimo-label">Código:</span>
              <input type="text" value="978-3-16-148410-0/5" readOnly />
            </label>
            <label>
              <span className="novoEmprestimo-label">Status:</span>
              <div className="novoEmprestimo-status-wrap">
                <span className="novoEmprestimo-status-livre">Livre</span>
                <ChevronDown size={18} className="novoEmprestimo-status-icon" />
              </div>
            </label>
            <label>
              <span className="novoEmprestimo-label">Data de devolução:</span>
              <input type="text" value="12/05/25" readOnly />
            </label>
            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Título:</span>
              <span>The Dragon Republic</span>
            </div>
            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Autor:</span>
              <span>R.F. Kuang</span>
            </div>
          </div>
          <div className="novoEmprestimo-col">
            <div className="novoEmprestimo-label-grande">Leitor:</div>
            <label>
              <span className="novoEmprestimo-label">Usuário:</span>
              <input type="text" value="anabferreira" readOnly />
            </label>
            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Nome:</span>
              <span>Ana Beatriz Ferreira</span>
            </div>
            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Telefone:</span>
              <span>(11) 98452-7361</span>
            </div>
            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Endereço:</span>
              <span>Rua das Acácias, 125 – Bairro Jardim Florido</span>
            </div>
            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">CPF:</span>
              <span>123.456.789-00</span>
            </div>
            <a className="novoEmprestimo-link" href="#">Visualizar histórico</a>
          </div>
        </div>
        <div className="novoEmprestimo-btns">
          <button className="novoEmprestimo-cancelar" onClick={onClose}>
            <X size={20} />
            <span className="novoEmprestimo-btn-bar" />
            Cancelar
          </button>
          <button className="novoEmprestimo-emprestar">
            <ArrowRightLeft size={20} />
            <span className="novoEmprestimo-btn-bar" />
            Emprestar
          </button>
        </div>
      </div>
    </div>
  );
};

export default NovoEmprestimo;