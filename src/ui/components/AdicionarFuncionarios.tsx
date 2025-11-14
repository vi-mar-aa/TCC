import React, { useState } from "react";
import { X, Save } from "lucide-react";
import './AdicionarFuncionarios.css'

interface Props {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void; // para recarregar lista após cadastrar
}

const AdicionarFuncionario: React.FC<Props> = ({ open, onClose, onSuccess }) => {
  const [nome, setNome] = useState("");
  const [cpf, setCpf] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [telefone, setTelefone] = useState("");
  const [loading, setLoading] = useState(false);

  if (!open) return null;

  async function cadastrar() {
    setLoading(true);

    const data = {
      idFuncionario: 0,
      idcargo: 0,
      nome,
      cpf,
      email,
      senha,
      telefone,
      statusconta: "ativo",
    };

    try {
      const response = await fetch("https://localhost:7008/CadastrarAdm", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      });

      if (response.ok) {
        alert("Funcionário cadastrado com sucesso!");
        onSuccess();
        onClose();
      } else {
        alert("Erro ao cadastrar funcionário.");
      }
    } catch (err) {
      console.error(err);
      alert("Erro de conexão com a API.");
    }

    setLoading(false);
  }

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Adicionar Funcionário</h2>
          <button className="close-btn" onClick={onClose}>
            <X size={22} />
          </button>
        </div>

        <div className="modal-body">
          <input placeholder="Nome" value={nome} onChange={(e) => setNome(e.target.value)} />
          <input placeholder="CPF" value={cpf} onChange={(e) => setCpf(e.target.value)} />
          <input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input placeholder="Senha" value={senha} onChange={(e) => setSenha(e.target.value)} />
          <input placeholder="Telefone" value={telefone} onChange={(e) => setTelefone(e.target.value)} />
        </div>

        <div className="modal-footer">
          <button disabled={loading} className="salvar-btn" onClick={cadastrar}>
            <Save size={20} /> {loading ? "Salvando..." : "Salvar"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default AdicionarFuncionario;
