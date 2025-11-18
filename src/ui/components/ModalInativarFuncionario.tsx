import React, { useState } from 'react';
import './ModalInativarFuncionario.css'

interface Props {
  open: boolean;
  funcionario: any;
  onClose: () => void;
  onConfirm: () => void; // continua para atualizar a lista
}

export default function ModalInativarFuncionario({ open, funcionario, onClose, onConfirm }: Props) {
  const [loading, setLoading] = useState(false);

  if (!open) return null;

  const inativarFuncionario = async () => {
    if (!funcionario) return;
    setLoading(true);

    try {
      // Faz a requisição POST para alterar o funcionário
      const response = await fetch('https://localhost:7008/AlterarFuncionario', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          idFuncionario: funcionario.idFuncionario,
          idcargo: funcionario.idcargo,
          nome: funcionario.nome,
          cpf: funcionario.cpf,
          email: funcionario.email,
          senha: funcionario.senha || '',
          telefone: funcionario.telefone,
          statusconta: 'Inativo' // <-- corrigido para respeitar CHECK do banco
        })
      });

      if (!response.ok) {
        throw new Error('Erro ao inativar funcionário');
      }

      // Atualiza a lista
      onConfirm();
      onClose();
    } catch (error) {
      console.error(error);
      alert('Não foi possível inativar o funcionário.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-inativar-overlay">
      <div className="modal-inativar-box">

        <h2>Inativar Funcionário</h2>

        <p>
          Tem certeza que deseja inativar<br />
          <b>{funcionario?.nome}</b>?
        </p>

        <div className="modal-inativar-actions">
          <button className="btn-cancelar" onClick={onClose} disabled={loading}>
            Cancelar
          </button>
          <button className="btn-confirmar" onClick={inativarFuncionario} disabled={loading}>
            {loading ? 'Inativando...' : 'Inativar'}
          </button>
        </div>

      </div>
    </div>
  );
}
