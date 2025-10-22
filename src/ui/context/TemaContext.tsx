import { createContext, useContext, useState, useEffect } from "react";

interface TemaContextType {
  temaEscuro: boolean;
  alternarTema: () => void;
}

const TemaContext = createContext<TemaContextType | undefined>(undefined);

export function TemaProvider({ children }: { children: React.ReactNode }) {
  const [temaEscuro, setTemaEscuro] = useState(true);

  // Quando o tema mudar, aplica a classe no <body>
  useEffect(() => {
    document.body.classList.toggle("dark", temaEscuro);
  }, [temaEscuro]);

  function alternarTema() {
    setTemaEscuro((prev) => !prev);
  }

  return (
    <TemaContext.Provider value={{ temaEscuro, alternarTema }}>
      {children}
    </TemaContext.Provider>
  );
}

// Hook personalizado pra usar o contexto
export function useTema() {
  const context = useContext(TemaContext);
  if (!context) {
    throw new Error("useTema deve ser usado dentro de TemaProvider");
  }
  return context;
}
