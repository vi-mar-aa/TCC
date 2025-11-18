import React, { useState, useEffect } from "react";
import "./novoEmprestimo.css";
import { X, ArrowRightLeft } from "lucide-react";

interface NovoEmprestimoProps {
  open: boolean;
  onClose: () => void;
}

const NovoEmprestimo: React.FC<NovoEmprestimoProps> = ({ open, onClose }) => {
  const [username, setUsername] = useState("");
  const [codigoLivro, setCodigoLivro] = useState("");
  const [tituloLivro, setTituloLivro] = useState("");

  const [leitor, setLeitor] = useState<any | null>(null);
  const [livro, setLivro] = useState<any | null>(null);

  const [todasMidias, setTodasMidias] = useState<any[]>([]);
  const [sugestoesTitulo, setSugestoesTitulo] = useState<any[]>([]);
  const [sugestoesUsuarios, setSugestoesUsuarios] = useState<any[]>([]);

  // Carregar mídias
  useEffect(() => {
    async function fetchMidias() {
      try {
        const res = await fetch("https://localhost:7008/ListarMidias");
        const data = await res.json();
        setTodasMidias(Array.isArray(data) ? data : []);
      } catch (err) {
        console.error("Erro ao carregar mídias:", err);
        setTodasMidias([]);
      }
    }
    fetchMidias();
  }, []);

  // Buscar leitor pelo username
  async function buscarLeitorPorUsername(usernameToSearch?: string) {
    const text = usernameToSearch ?? username;
    if (!text.trim()) return;

    const body = {
      midia: {},
      searchText: text,
    };

    try {
      const res = await fetch("https://localhost:7008/BuscarLeitorPorUsername", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

      const data = await res.json();

      if (Array.isArray(data)) setLeitor(data[0] || null);
      else setLeitor(null);
    } catch (err) {
      console.error("Erro buscarLeitorPorUsername:", err);
      setLeitor(null);
    }
  }

  // Autocomplete usuários
  async function atualizarSugestoesUsuario(texto: string) {
    setUsername(texto);

    if (!texto.trim()) {
      setSugestoesUsuarios([]);
      return;
    }

    const body = { midia: {}, searchText: texto };

    try {
      const res = await fetch("https://localhost:7008/BuscarLeitorPorUsername", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

      const data = await res.json();
      setSugestoesUsuarios(Array.isArray(data) ? data.slice(0, 6) : []);
    } catch (err) {
      console.error("Erro autocomplete usuário:", err);
      setSugestoesUsuarios([]);
    }
  }

  function selecionarUsuario(u: any) {
    setUsername(u.user);
    setLeitor(u);
    setSugestoesUsuarios([]);
  }

  // Buscar livro pelo código
  async function buscarLivroPorCodigo() {
    if (!codigoLivro.trim()) return;

    const encontrado = todasMidias.find(
      (m) => String(m.chaveIdentificadora) === String(codigoLivro)
    );

    setLivro(encontrado || null);
  }

  // Autocomplete título
  function atualizarSugestoesTitulo(texto: string) {
    setTituloLivro(texto);

    if (!texto.trim()) return setSugestoesTitulo([]);

    const filtrados = todasMidias.filter((m) =>
      (m.titulo ?? "").toLowerCase().includes(texto.toLowerCase())
    );

    setSugestoesTitulo(filtrados.slice(0, 6));
  }

  function selecionarLivro(m: any) {
    setLivro(m);
    setCodigoLivro(m.chaveIdentificadora);
    setTituloLivro(m.titulo);
    setSugestoesTitulo([]);
  }

  if (!open) return null;

  return (
    <div className="novoEmprestimo-modal-overlay">
      <div className="novoEmprestimo-modal">
        <button className="novoEmprestimo-fechar" onClick={onClose}>
          <X size={28} />
        </button>

        <h2 className="novoEmprestimo-titulo">Novo Empréstimo</h2>

        <div className="novoEmprestimo-form-wrap">
          {/* COLUNA LIVRO */}
          <div className="novoEmprestimo-col">
            <div className="novoEmprestimo-label-grande">Livro:</div>

            <label>
              <span className="novoEmprestimo-label">Código:</span>
              <input
                type="text"
                value={codigoLivro}
                onChange={(e) => setCodigoLivro(e.target.value)}
                onBlur={buscarLivroPorCodigo}
                placeholder="Digite o código..."
              />
            </label>

            <label style={{ position: "relative" }}>
              <span className="novoEmprestimo-label">Título:</span>
              <input
                type="text"
                value={tituloLivro}
                onChange={(e) => atualizarSugestoesTitulo(e.target.value)}
                placeholder="Digite o título..."
                autoComplete="off"
              />

              {sugestoesTitulo.length > 0 && (
                <ul className="novoEmprestimo-sugestoes">
                  {sugestoesTitulo.map((m) => (
                    <li
                      key={m.idMidia}
                      onMouseDown={(ev) => ev.preventDefault()}
                      onClick={() => selecionarLivro(m)}
                      className="novoEmprestimo-sugestao-item"
                    >
                      {m.titulo}
                    </li>
                  ))}
                </ul>
              )}
            </label>

            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Autor:</span>
              <span>{livro ? livro.autor : "---"}</span>
            </div>
          </div>

          {/* COLUNA LEITOR */}
          <div className="novoEmprestimo-col">
            <div className="novoEmprestimo-label-grande">Leitor:</div>

            <label style={{ position: "relative" }}>
              <span className="novoEmprestimo-label">Usuário:</span>
              <input
                type="text"
                value={username}
                onChange={(e) => atualizarSugestoesUsuario(e.target.value)}
                onBlur={() => setTimeout(() => setSugestoesUsuarios([]), 150)}
                placeholder="Digite o username..."
                autoComplete="off"
              />

              {sugestoesUsuarios.length > 0 && (
                <ul className="novoEmprestimo-sugestoes">
                  {sugestoesUsuarios.map((u: any) => (
                    <li
                      key={u.idCliente}
                      onMouseDown={(ev) => ev.preventDefault()}
                      onClick={() => selecionarUsuario(u)}
                      className="novoEmprestimo-sugestao-item"
                    >
                      {u.user} — {u.nome}
                    </li>
                  ))}
                </ul>
              )}
            </label>

            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Nome:</span>
              <span>{leitor ? leitor.nome : "---"}</span>
            </div>

            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">Telefone:</span>
              <span>{leitor ? leitor.telefone : "---"}</span>
            </div>

            <div className="novoEmprestimo-info">
              <span className="novoEmprestimo-label">CPF:</span>
              <span>{leitor ? leitor.cpf ?? "Não informado" : "---"}</span>
            </div>
          </div>
        </div>

        <div className="novoEmprestimo-btns">
          <button className="novoEmprestimo-cancelar" onClick={onClose}>
            <X size={20} />
            <span className="novoEmprestimo-btn-bar" />
            Cancelar
          </button>

         <button
  className="novoEmprestimo-emprestar"
  onClick={async () => {
    if (!leitor || !livro) {
      alert("Selecione um leitor e um livro antes de emprestar.");
      return;
    }

    const agora = new Date();
    const dataDevolucao = new Date();
    dataDevolucao.setDate(agora.getDate() + 7); // 7 dias de empréstimo

    const body = {
      midia: livro,
      cliente: leitor,
      emprestimo: {
        idEmprestimo: 0,
        idCliente: leitor.idCliente,
        idMidia: livro.idMidia,
        idReserva: 0,
        idFuncionario: 20, // ← AJUSTE SE NECESSÁRIO
        dataEmprestimo: agora.toISOString(),
        dataDevolucao: dataDevolucao.toISOString(),
        limiteRenovacoes: 3,
        status: 0,
      },
      funcionario: {
        idFuncionario: 20,
        idcargo: 1,
        nome: "Daniel Minoru",
        cpf: "441.341.412-41",
        email: "dminoru13@gmail.com",
        senha: null,
        telefone: "(12) 41241-4142",
        statusconta: "ativo",
      },
      diasAtraso: 0,
      valorMulta: 0,
      statusRenovacao: 0,
      novaData: dataDevolucao.toISOString(),
    };

    try {
      const res = await fetch("https://localhost:7008/CriarEmprestimo", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

      const resposta = await res.json();

      alert("Empréstimo criado com sucesso!");
      console.log("Resposta API:", resposta);

      onClose(); // fecha o modal
    } catch (err) {
      console.error("Erro ao criar empréstimo:", err);
      alert("Erro ao criar empréstimo!");
    }
  }}
>
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
