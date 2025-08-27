import React, { useState } from 'react';
import './menu.css';
import logo from '../assets/logoLazul.png';
import {
  LayoutDashboard,
  Book,
  ArrowRightLeft,
  Clock,
  Users,
  Heart,
  Calendar,
  ChevronDown,
  ChevronRight,
  Settings,
  FileBarChart2
} from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';

const menuItems = [
  {
    label: 'Dashboard',
    icon: <LayoutDashboard size={28} />,
    chevron: false,
    path: '/dashboard'
  },
  {
    label: 'Acervo',
    icon: <Book size={28} />,
    chevron: false, // alterado para botão normal
    path: '/acervo' // leva para a página principal de acervo
  },
  {
    label: 'Empréstimos',
    icon: <ArrowRightLeft size={28} />,
    chevron: true,
    submenu: [
      { label: 'Atuais', path: '/emprestimo' },
      { label: 'Histórico', path: '/emprestimo/historico' },
      { label: 'Gráficos', path: '/emprestimo/graficos' }
    ]
  },
  {
    label: 'Reservas',
    icon: <Clock size={28} />,
    chevron: false,
    path: '/reservas'
  },
  {
    label: 'Fórum',
    icon: <Users size={28} />,
    chevron: true,
    submenu: [
      { label: 'Postagens', path: '/forum/postagens' },
      { label: 'Denúncias', path: '/forum/denuncias' }
    ]
  },
  {
    label: 'Indicações',
    icon: <Heart size={28} />,
    chevron: false,
    path: '/indicacoes'
  },
  {
    label: 'Eventos',
    icon: <Calendar size={28} />,
    chevron: false,
    path: '/eventos'
  }
];

function Menu() {
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState<string | null>(null);

  const handleMenuClick = (item: any) => {
    if (item.chevron) {
      setOpen(open === item.label ? null : item.label);
    } else if (item.path) {
      navigate(item.path);
      setOpen(null);
    }
  };

  const isActive = (path: string) => location.pathname.startsWith(path);

  return (
    <div className="menu">
      <img
        src={logo}
        alt="Logo Littera"
        style={{ width: '54%', margin: '20px auto', display: 'block', cursor: 'pointer' }}
        onClick={() => navigate('/')}
      />
      <nav style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div>
          {menuItems.map((item) => (
            <div key={item.label} style={{ width: '100%' }}>
              <button
                className={`menu-btn${
                  item.path && isActive(item.path)
                    ? ' active'
                    : item.chevron && item.submenu.some((sub: any) => isActive(sub.path))
                    ? ' active'
                    : ''
                }`}
                onClick={() => handleMenuClick(item)}
                type="button"
              >
                {item.icon}
                <span>{item.label}</span>
                {item.chevron &&
                  (open === item.label
                    ? <ChevronDown size={18} className="chevron" />
                    : <ChevronRight size={18} className="chevron" />)}
              </button>
              {item.chevron && open === item.label && (
                <div className="submenu">
                  {item.submenu.map((sub: any) => (
                    <button
                      key={sub.label}
                      className={`submenu-btn${isActive(sub.path) ? ' active' : ''}`}
                      onClick={() => navigate(sub.path)}
                      type="button"
                    >
                      <span>{sub.label}</span>
                      <ChevronRight size={16} />
                    </button>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
        <button
          className={`menu-btn${isActive('/configuracao') ? ' active' : ''}`}
          onClick={() => navigate('/configuracao')}
          style={{ marginTop: 'auto', marginBottom: '1vw' }} // adicionado marginBottom
        >
          <Settings size={28} />
          <span>Configurações</span>
        </button>
      </nav>
    </div>
  );
}

export default Menu;