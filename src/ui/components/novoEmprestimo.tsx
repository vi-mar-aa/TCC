import React, { useState, useEffect } from "react";
import "./novoEmprestimo.css";
import { X, ArrowRightLeft, ChevronDown } from "lucide-react";

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

  // sugestões de usuário
  const [sugestoesUsuarios, setSugestoesUsuarios] = useState<any[]>([]);

  // HISTÓRICO
  const [historicoOpen, setHistoricoOpen] = useState(false);
  const [historico, setHistorico] = useState<any[]>([]);
  const [historicoCarregando, setHistoricoCarregando] = useState(false);
  const [historicoErro, setHistoricoErro] = useState<string | null>(null);

  // Carregar todas as mídias (para autocomplete de título)
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

  // ==============================
  // BUSCAR LEITOR (quando digitar e/ou blur)
  // ==============================
  async function buscarLeitorPorUsername(usernameToSearch?: string) {
    const text = usernameToSearch !== undefined ? usernameToSearch : username;
    if (!text || !text.trim()) return;

    const body = {
      midia: {
        idMidia: 0,
        chaveIdentificadora: "string",
        codigoExemplar: 0,
        idfuncionario: 0,
        idtpmidia: 0,
        titulo: "string",
        autor: "string",
        sinopse: "string",
        editora: "string",
        anopublicacao: "string",
        edicao: "string",
        localpublicacao: "string",
        npaginas: 0,
        isbn: "string",
        duracao: "string",
        estudio: "string",
        roterista: "string",
        dispo: 0,
        genero: 0,
        contExemplares: 0,
        nomeTipo: "string",
        imagem: "string",
      },
      searchText: text,
    };

    try {
      const res = await fetch("https://localhost:7008/BuscarLeitorPorUsername", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await res.json();
      // Caso o endpoint retorne uma lista, pega o primeiro como busca por blur
      if (Array.isArray(data)) {
        setLeitor(data[0] || null);
      } else if (data) {
        // ou se retornar diretamente um objeto
        setLeitor(data);
      } else {
        setLeitor(null);
      }
    } catch (err) {
      console.error("Erro buscarLeitorPorUsername:", err);
      setLeitor(null);
    }
  }

  // ==============================
  // AUTOCOMPLETE DO USUÁRIO (enquanto digita)
  // ==============================
  async function atualizarSugestoesUsuario(texto: string) {
    setUsername(texto);

    if (!texto.trim()) {
      setSugestoesUsuarios([]);
      return;
    }

    const body = {
      midia: {}, // o backend parece ignorar isso para a busca de usuário
      searchText: texto,
    };

    try {
      const res = await fetch("https://localhost:7008/BuscarLeitorPorUsername", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await res.json();
      if (Array.isArray(data)) {
        setSugestoesUsuarios(data.slice(0, 6));
      } else {
        // se retornar objeto único, transforma em array
        setSugestoesUsuarios(data ? [data] : []);
      }
    } catch (err) {
      console.error("Erro atualizarSugestoesUsuario:", err);
      setSugestoesUsuarios([]);
    }
  }

  function selecionarUsuario(u: any) {
    // usa os campos prováveis; adapte caso sua API use nomes diferentes
    setUsername(u.user ?? u.username ?? u.userName ?? u.nome ?? "");
    setLeitor(u);
    setSugestoesUsuarios([]);
  }

  // ==============================
  // BUSCAR LIVRO PELO CÓDIGO
  // ==============================
  async function buscarLivroPorCodigo() {
    if (!codigoLivro.trim()) return;

    const livroEncontrado = todasMidias.find(
      (m: any) => String(m.chaveIdentificadora) === String(codigoLivro)
    );

    setLivro(livroEncontrado || null);
  }

  // ==============================
  // AUTOCOMPLETE DO TÍTULO
  // ==============================
  function atualizarSugestoesTitulo(titulo: string) {
    setTituloLivro(titulo);

    if (!titulo.trim()) {
      setSugestoesTitulo([]);
      return;
    }

    const filtrados = todasMidias.filter((m) =>
      String(m.titulo ?? "").toLowerCase().includes(titulo.toLowerCase())
    );

    setSugestoesTitulo(filtrados.slice(0, 6));
  }

  function selecionarLivro(m: any) {
    setLivro(m);
    setTituloLivro(m.titulo);
    setCodigoLivro(m.chaveIdentificadora);
    setSugestoesTitulo([]);
  }

  // ==============================
  // ABRIR HISTÓRICO (POST para o endpoint)
  // ==============================
  async function abrirHistorico() {
    if (!leitor) return;
    setHistoricoCarregando(true);
    setHistoricoErro(null);

    // monta o body conforme o schema que você passou
    const body = {
      idCliente: leitor.idCliente ?? leitor.id ?? 0,
      nome: leitor.nome ?? leitor.Nome ?? "",
      user: leitor.user ?? leitor.username ?? leitor.userName ?? "",
      cpf: leitor.cpf ?? "",
      email: leitor.email ?? "",
      senha: leitor.senha ?? "",
      telefone: leitor.telefone ?? "",
      status_conta: leitor.status_conta ?? leitor.statusConta ?? "",
      imagemPerfil: leitor.imagemPerfil ?? leitor.imagem ?? "",
    };

    try {
      const res = await fetch(
        "https://localhost:7008/ListarHistoricoEmprestimosCLiente",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body),
        }
      );

      const data = await res.json();
      // espera um array com histórico; caso contrário adapta
      setHistorico(Array.isArray(data) ? data : data ? [data] : []);
      setHistoricoOpen(true);
    } catch (err) {
      console.error("Erro ao carregar histórico:", err);
      setHistorico([]);
      setHistoricoErro("Erro ao carregar histórico. Veja o console.");
      setHistoricoOpen(true);
    } finally {
      setHistoricoCarregando(false);
    }
  }

  function fecharHistorico() {
    setHistoricoOpen(false);
    setHistorico([]);
    setHistoricoErro(null);
  }

  if (!open) return null;

  return (
    <>
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

              {/* Código */}
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

              {/* Título com autocomplete */}
              <label style={{ position: "relative" }}>
                <span className="novoEmprestimo-label">Título:</span>
                <input
                  type="text"
                  value={tituloLivro}
                  onChange={(e) => atualizarSugestoesTitulo(e.target.value)}
                  placeholder="Digite o título do livro..."
                  autoComplete="off"
                />

                {sugestoesTitulo.length > 0 && (
                  <ul className="novoEmprestimo-sugestoes">
                    {sugestoesTitulo.map((m) => (
                      <li
                        key={m.idMidia ?? m.id ?? m.chaveIdentificadora}
                        onMouseDown={(ev) => ev.preventDefault()} // evita blur antes do click
                        onClick={() => selecionarLivro(m)}
                        className="novoEmprestimo-sugestao-item"
                      >
                        {m.titulo}
                      </li>
                    ))}
                  </ul>
                )}
              </label>

              {/* Status */}
              <label>
                <span className="novoEmprestimo-label">Status:</span>
                <div className="novoEmprestimo-status-wrap">
                  {livro ? (
                    livro.dispo === 1 ? (
                      <span className="novoEmprestimo-status-livre">Livre</span>
                    ) : (
                      <span className="novoEmprestimo-status-ocupado">Emprestado</span>
                    )
                  ) : (
                    <span className="novoEmprestimo-status-vazio">---</span>
                  )}
                  <ChevronDown size={18} className="novoEmprestimo-status-icon" />
                </div>
              </label>

              <div className="novoEmprestimo-info">
                <span className="novoEmprestimo-label">Autor:</span>
                <span>{livro ? livro.autor : "---"}</span>
              </div>
            </div>

            {/* COLUNA LEITOR */}
            <div className="novoEmprestimo-col">
              <div className="novoEmprestimo-label-grande">Leitor:</div>

              {/* USUÁRIO COM AUTOCOMPLETE */}
              <label style={{ position: "relative" }}>
                <span className="novoEmprestimo-label">Usuário:</span>
                <input
                  type="text"
                  value={username}
                  onChange={(e) => atualizarSugestoesUsuario(e.target.value)}
                  // mantém sugestões por um pequeno tempo para clique:
                  onBlur={() => setTimeout(() => setSugestoesUsuarios([]), 150)}
                  placeholder="Digite o username..."
                  autoComplete="off"
                />

                {sugestoesUsuarios.length > 0 && (
                  <ul className="novoEmprestimo-sugestoes">
                    {sugestoesUsuarios.map((u: any) => (
                      <li
                        key={u.idCliente ?? u.id ?? u.user ?? u.username ?? JSON.stringify(u)}
                        onMouseDown={(ev) => ev.preventDefault()} // impede blur
                        onClick={() => selecionarUsuario(u)}
                        className="novoEmprestimo-sugestao-item"
                      >
                        {u.user ?? u.username ?? u.userName ?? u.nome ?? "—"}{" "}
                        {u.nome ? `— ${u.nome}` : ""}
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
                <span>{leitor ? leitor.cpf || "Não informado" : "---"}</span>
              </div>

              <a
                className="novoEmprestimo-link"
                onClick={(e) => {
                  e.preventDefault();
                  // se já tiver leitor carregado, abre; senão tenta buscar primeiro
                  if (leitor) {
                    abrirHistorico();
                  } else {
                    // tenta buscar e, depois de um pequeno timeout, abre histórico
                    buscarLeitorPorUsername().then(() => {
                      // abre após ter setado leitor (se encontrado)
                      setTimeout(() => {
                        if (leitor) abrirHistorico();
                      }, 200);
                    });
                  }
                }}
                href="#"
              >
                Visualizar histórico
              </a>
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
              onClick={() => {
                // implementar lógica de empréstimo aqui
                // por enquanto apenas log
                console.log("Emprestar:", { leitor, livro });
              }}
            >
              <ArrowRightLeft size={20} />
              <span className="novoEmprestimo-btn-bar" />
              Emprestar
            </button>
          </div>
        </div>
      </div>

      {/* ===================================================
          MODAL DE HISTÓRICO (overlay separado para clareza)
         =================================================== */}
      {historicoOpen && (
        <div className="novoEmprestimo-modal-overlay" style={{ zIndex: 22000 }}>
          <div className="novoEmprestimo-modal">
            <button className="novoEmprestimo-fechar" onClick={fecharHistorico}>
              <X size={28} />
            </button>

            <h3 className="novoEmprestimo-titulo">Histórico de Empréstimos</h3>

            <div style={{ maxHeight: "60vh", overflowY: "auto", padding: "8px 16px" }}>
              {historicoCarregando ? (
                <p>Carregando...</p>
              ) : historicoErro ? (
                <p style={{ color: "red" }}>{historicoErro}</p>
              ) : historico.length === 0 ? (
                <p>Nenhum histórico encontrado para esse leitor.</p>
              ) : (
                <table style={{ width: "100%", borderCollapse: "collapse" }}>
                  <thead>
                    <tr>
                      <th style={{ textAlign: "left", padding: "8px 4px" }}>Título</th>
                      <th style={{ textAlign: "left", padding: "8px 4px" }}>Data Empréstimo</th>
                      <th style={{ textAlign: "left", padding: "8px 4px" }}>Data Devolução</th>
                      <th style={{ textAlign: "left", padding: "8px 4px" }}>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {historico.map((h: any, idx: number) => (
                      <tr key={h.idHistorico ?? h.id ?? idx} style={{ borderTop: "1px solid #eee" }}>
                        <td style={{ padding: "8px 4px" }}>{h.titulo ?? h.nomeMidia ?? h.tituloMidia ?? "—"}</td>
                        <td style={{ padding: "8px 4px" }}>{h.dataEmprestimo ?? h.data_saida ?? "—"}</td>
                        <td style={{ padding: "8px 4px" }}>{h.dataDevolucao ?? h.data_retorno ?? "—"}</td>
                        <td style={{ padding: "8px 4px" }}>{h.status ?? h.situacao ?? "—"}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>

            <div style={{ display: "flex", justifyContent: "flex-end", gap: 8, padding: "12px 16px" }}>
              <button className="novoEmprestimo-cancelar" onClick={fecharHistorico}>
                <X size={16} />
                <span style={{ marginLeft: 6 }}>Fechar</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default NovoEmprestimo;
