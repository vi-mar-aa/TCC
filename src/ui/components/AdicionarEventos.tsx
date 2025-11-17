import React, { useState } from "react";
import "./AdicionarEventos.css";
import { X, Save } from "lucide-react";

interface Props {
  open: boolean;
  onClose: () => void;
  atualizarLista: () => void;
}

const AdicionarEvento: React.FC<Props> = ({ open, onClose, atualizarLista }) => {
  if (!open) return null;

  const [titulo, setTitulo] = useState("");
  const [localEvento, setLocalEvento] = useState("");
  const [dataInicio, setDataInicio] = useState("");
  const [dataFim, setDataFim] = useState("");

  // NOVOS CAMPOS – Opção A (dois inputs separados)
  const [horaInicio, setHoraInicio] = useState("");
  const [horaFim, setHoraFim] = useState("");

  // Monta o formato HH:mm/HH:mm
  const montarHorario = () => {
    if (!horaInicio || !horaFim) return "";
    return `${horaInicio}/${horaFim}`;
  };

  const salvar = async () => {
    try {
      const funcionarioStr = localStorage.getItem("funcionario");
      if (!funcionarioStr) return alert("Nenhum funcionário logado!");

      const funcionario = JSON.parse(funcionarioStr);

      const payload = {
        evento: {
          idEvento: 0,
          titulo,
          dataInicio,
          dataFim,
          localEvento,
          statusEvento: "Ativo",
          idFuncionario: funcionario.idFuncionario
        },

        funcionario,
        dataInicio,
        dataFim,
        horario: montarHorario() // <<< HORÁRIO ENVIADO NO FORMATO: 19:00/21:00
      };

      console.log("ENVIADO PARA API:", payload);

      await fetch("https://localhost:7008/AdicionarEvento", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });

      alert("Evento adicionado!");
      atualizarLista();
      onClose();

    } catch (err) {
      console.error(err);
      alert("Erro ao adicionar evento.");
    }
  };

  return (
    <div className="evento-modal-overlay">
      <div className="evento-modal">
        <button className="evento-fechar" onClick={onClose}>
          <X size={26} />
        </button>

        <h2 className="evento-titulo">Adicionar Evento</h2>

        <label>
          <span>Título</span>
          <input
            value={titulo}
            onChange={(e) => setTitulo(e.target.value)}
            type="text"
          />
        </label>

        <label>
          <span>Local</span>
          <input
            value={localEvento}
            onChange={(e) => setLocalEvento(e.target.value)}
            type="text"
          />
        </label>

        <label>
  <span>Data Início</span>
  <input
    type="date"
    value={dataInicio}
    onChange={(e) => setDataInicio(e.target.value)}
  />
</label>

<label>
  <span>Data Fim</span>
  <input
    type="date"
    value={dataFim}
    onChange={(e) => setDataFim(e.target.value)}
  />
</label>


        {/* NOVO BLOCO - Inputs de horário */}
        <div className="evento-horarios">
          <label>
            <span>Horário Início</span>
            <input
              type="time"
              value={horaInicio}
              onChange={(e) => setHoraInicio(e.target.value)}
            />
          </label>

          <label>
            <span>Horário Fim</span>
            <input
              type="time"
              value={horaFim}
              onChange={(e) => setHoraFim(e.target.value)}
            />
          </label>
        </div>

        <button className="evento-salvar" onClick={salvar}>
          <Save size={18} />
          Salvar
        </button>
      </div>
    </div>
  );
};

export default AdicionarEvento;
