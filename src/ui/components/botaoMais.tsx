import React, { useState, useRef, useEffect } from 'react';
import { ArrowRightLeft } from 'lucide-react';
import Catalogacao from './catalogacao';
import NovoEmprestimo from './novoEmprestimo';
import './botaoMais.css';

interface BotaoMaisProps {
  onAdicionarFuncionario?: () => void;
  onEmprestimoCriado?: () => void;   // << NOVO
  title?: string;
  style?: React.CSSProperties;
  className?: string;
}

const BotaoMais: React.FC<BotaoMaisProps> = ({
  onAdicionarFuncionario,
  onEmprestimoCriado,       // << NOVO
  title = "Adicionar",
  style,
  className
}) => {
  const [open, setOpen] = useState(false);
  const [catalogacaoOpen, setCatalogacaoOpen] = useState(false);
  const [novoEmprestimoOpen, setNovoEmprestimoOpen] = useState(false);

  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    if (open) document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [open]);

  return (
    <>
      <div
        ref={ref}
        style={{
          position: 'fixed',
          right: '3vw',
          bottom: '3vw',
          zIndex: 9999
        }}
      >
        {open && (
          <div className="fab-menu-popup">
            <div className="fab-menu-arrow" />
            <div className="fab-menu-list">

              <div
                className="fab-menu-item"
                onClick={() => {
                  setNovoEmprestimoOpen(true);
                  setOpen(false);
                }}
              >
                <ArrowRightLeft size={20} style={{ marginRight: 8, color: '#0A4489' }} />
                Novo Empréstimo
              </div>

              <div
                className="fab-menu-item"
                onClick={() => {
                  setCatalogacaoOpen(true);
                  setOpen(false);
                }}
              >
                Catalogação
              </div>
            </div>
          </div>
        )}

        <button
          className={`fab-btn${className ? ' ' + className : ''}`}
          title={title}
          onClick={() => setOpen(o => !o)}
          style={style}
          type="button"
        >
          +
        </button>
      </div>

      {/* QUANDO O MODAL FECHA, AVISA O PAI */}
      <Catalogacao open={catalogacaoOpen} onClose={() => setCatalogacaoOpen(false)} />

      <NovoEmprestimo
        open={novoEmprestimoOpen}
        onClose={(created?: boolean) => {
          setNovoEmprestimoOpen(false);

          if (created && onEmprestimoCriado) {
            onEmprestimoCriado();  // << AQUI ATUALIZA A TABELA
          }
        }}
      />
    </>
  );
};

export default BotaoMais;
