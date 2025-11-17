import React, { useState, useEffect, useRef } from "react";
import "./eventos.css";
import Menu from "./components/menu";
import { MoreVertical } from "lucide-react";
import AdicionarEvento from "./components/AdicionarEventos"; // ⬅ novo modal

interface Evento {
  idEvento: number;
  titulo: string;
  dataInicio: string;
  dataFim: string;
  localEvento: string;
  statusEvento?: string;
  idFuncionario?: number;
}

interface EventoResponse {
  evento: Evento;
}

function formatarData(dataISO: string) {
  if (!dataISO) return "";
  const d = new Date(dataISO);
  if (isNaN(d.getTime())) return "";
  return d.toLocaleDateString("pt-BR");
}

function formatarHorario(dataInicio: string, dataFim: string) {
  const ini = new Date(dataInicio);
  const fim = new Date(dataFim);
  if (isNaN(ini.getTime()) || isNaN(fim.getTime())) return "";
  return `${ini.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })} às ${fim.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })}`;
}

function Eventos() {
  const [tab, setTab] = useState<"andamento" | "historico">("andamento");
  const [eventosAndamento, setEventosAndamento] = useState<EventoResponse[]>([]);
  const [eventosHistorico, setEventosHistorico] = useState<EventoResponse[]>([]);
  const [menuOpenFor, setMenuOpenFor] = useState<number | null>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  const [modalAdicionarOpen, setModalAdicionarOpen] = useState(false);

  const eventos = tab === "andamento" ? eventosAndamento : eventosHistorico;

  useEffect(() => {
    carregarEventos();
    carregarHistorico();
  }, []);

  const carregarEventos = async () => {
    try {
      const res = await fetch("https://localhost:7008/ListarEventos");
      const data = await res.json();
      setEventosAndamento(data);
    } catch (e) {
      console.error("Erro ao carregar eventos:", e);
    }
  };

  const carregarHistorico = async () => {
    try {
      const res = await fetch("https://localhost:7008/ListarEventosHistorico");
      const data = await res.json();
      setEventosHistorico(data);
    } catch (e) {
      console.error("Erro ao carregar histórico:", e);
    }
  };

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setMenuOpenFor(null);
      }
    }
    document.addEventListener("click", handleClickOutside);
    return () => document.removeEventListener("click", handleClickOutside);
  }, []);

  // EXCLUIR EVENTO
  const excluirEvento = async (evento: Evento) => {
    try {
      const funcionarioStr = localStorage.getItem("funcionario");
      if (!funcionarioStr) {
        alert("Nenhum funcionário logado.");
        return;
      }

      const funcionario = JSON.parse(funcionarioStr);

      const payload = {
        evento,
        funcionario,
        dataInicio: evento.dataInicio,
        dataFim: evento.dataFim,
        horario: "",
      };

      await fetch("https://localhost:7008/InativarEvento", {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (tab === "andamento") {
        setEventosAndamento((prev) =>
          prev.filter((e) => e.evento.idEvento !== evento.idEvento)
        );
      } else {
        setEventosHistorico((prev) =>
          prev.filter((e) => e.evento.idEvento !== evento.idEvento)
        );
      }

      alert("Evento excluído!");
      setMenuOpenFor(null);

    } catch (error) {
      console.error("Erro:", error);
      alert("Erro ao excluir evento.");
    }
  };

  return (
    <div className="conteinerEventos">
      <Menu />

      <div className="conteudoEventos">
        <h2 className="eventos-titulo">Eventos</h2>

        <div className="eventos-tabs">
          <button className={tab === "andamento" ? "active" : ""} onClick={() => setTab("andamento")}>
            Em andamento
          </button>

          <button className={tab === "historico" ? "active" : ""} onClick={() => setTab("historico")}>
            Histórico
          </button>
        </div>

        <div className="eventos-lista">
          {eventos.length === 0 ? (
            <p className="eventos-vazio">Nenhum evento encontrado.</p>
          ) : (
            eventos.map((e, i) => {
              const item = e.evento;
              return (
                <div className="eventos-card" key={i}>
                  <div className="eventos-card-info">
                    <div><b>Evento:</b> {item.titulo}</div>
                    <div><b>Local:</b> {item.localEvento}</div>
                    <div><b>Horário:</b> {formatarHorario(item.dataInicio, item.dataFim)}</div>
                    <div><b>Data:</b> {formatarData(item.dataInicio)}</div>
                  </div>

                  <div className="eventos-card-actions">
                    <MoreVertical
                      size={26}
                      className="eventos-menu-btn"
                      onClick={(e) => {
                        e.stopPropagation();
                        setMenuOpenFor(item.idEvento);
                      }}
                    />

                    {menuOpenFor === item.idEvento && (
                      <div className="eventos-menu" ref={menuRef}>
                        <button className="eventos-menu-item excluir" onClick={() => excluirEvento(item)}>
                          Excluir evento
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              );
            })
          )}
        </div>

        {/* NOVO BOTÃO FIXO */}
        <button
          className="evento-add-btn"
          onClick={() => setModalAdicionarOpen(true)}
        >
          +
        </button>

        {/* MODAL DE ADICIONAR EVENTO */}
        <AdicionarEvento
          open={modalAdicionarOpen}
          onClose={() => setModalAdicionarOpen(false)}
          atualizarLista={carregarEventos}
        />
      </div>
    </div>
  );
}

export default Eventos;
