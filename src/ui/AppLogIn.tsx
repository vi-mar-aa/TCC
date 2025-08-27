import { Routes, Route, useNavigate } from 'react-router-dom';
import { useState } from 'react';
import Cadastro from './Cadastro';
import './AppLogIn.css'
import logo from './assets/logoLazul.png'
import { LogIn, Eye, EyeOff } from 'lucide-react';
import Dashboard from './dashboard';
import Acervo from './acervo';
import Emprestimo from './emprestimos';
import EmprestimoHistorico from './emprestimoHistorico';
import EmprestimoGrafico from './emprestimoGrafico';
import Reservas from './reservas';
import Forum from './postagens';
import Indicacoes from './indicacoes';
import Eventos from './eventos';
import Denuncias from './denuncias';
import Configuracao from './configuracao';
import InfoAcervo from './InfoAcervo';



function Login() {
  const [selected, setSelected] = useState<'admin' | 'biblio'>('admin');
  const [showSenha, setShowSenha] = useState(false);
  const navigate = useNavigate();

  return (
    <>
    <div className='conteiner'>

  

      <img id='logo' src={logo} alt="Logo Littera" />
      <div id='cx1'>
        <h1 id='textao'>Bem-Vindo de Volta!</h1>
        <div id='cx2'>
          <p id='p1'>Acesse sua conta e continue explorando as ferramentas que facilitam a gestão da sua biblioteca.</p>
        </div>
        <div id='cx3'>
          <button
            className={`btnA ${selected === 'admin' ? 'btnA-selected' : ''}`}
            id='btn1'
            onClick={() => setSelected('admin')}
          >
            Administrador
          </button>
          <button
            className={`btnA ${selected === 'biblio' ? 'btnA-selected' : ''}`}
            id='btn2'
            onClick={() => setSelected('biblio')}
          >
            Bibliotecário(a)
          </button>
        </div>
        <div id='cx4'>
          <div className='cx4-1'>
            <p className='textinho'>Usuário</p>
            <input className='txt1' type="email" />
          </div>
          <div className='cx4-1'>
            <p className='textinho'>Senha</p>
            <div className="cadastro-input-group">
              <input
                type={showSenha ? "text" : "password"}
                className="cadastro-input"
              />
              <button
                type="button"
                className="cadastro-eye"
                onClick={() => setShowSenha((v) => !v)}
                tabIndex={-1}
                aria-label="Mostrar/ocultar senha"
              >
                {showSenha ? (
                  <EyeOff size={22} color="#0A4489" />
                ) : (
                  <Eye size={22} color="#0A4489" />
                )}
              </button>
            </div>
          </div>
        </div>
         <button className="btn-cadastrar">
          <LogIn className="btn-cadastrar-img" />
          <span className="btn-cadastrar-divider"></span>
          <span className="btn-cadastrar-text">Log in</span>
        </button>
        <div id='cx5'>
          <p className='textinho'>Ainda não possui um cadastro?</p>
          <a onClick={() => navigate('/cadastro')} style={{ cursor: 'pointer' }}>Cadastre-se</a>
        </div>
      </div>
    </div>
      
    </>
  )
}


import Catalogacao from './dashboard';

function AppLogIn() {
  return (
    <Routes>
      <Route path="/" element={<Login />} />
      <Route path="/cadastro" element={<Cadastro />} />
      <Route path="/catalogacao" element={<Catalogacao />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/acervo" element={<Acervo />} />
      <Route path="/emprestimo" element={<Emprestimo />} />
      <Route path="/emprestimo/historico" element={<EmprestimoHistorico />} />
      <Route path="/emprestimo/graficos" element={<EmprestimoGrafico />} />
      <Route path="/reservas" element={<Reservas />} />
      <Route path="/forum/postagens" element={<Forum />} />
      <Route path="/indicacoes" element={<Indicacoes />} />
      <Route path="/eventos" element={<Eventos />} />
      <Route path="/forum/denuncias" element={<Denuncias />} />
      <Route path="/configuracao" element={<Configuracao />} />
      <Route path="/infoAcervo" element={<InfoAcervo />} />
    </Routes>
  );
}


export default AppLogIn;