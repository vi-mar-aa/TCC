import { Routes, Route } from 'react-router-dom';
import Cadastro from './Cadastro';
import './AppLogIn.css';
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
import Catalogacao from './dashboard';
import Login from './Login';
import { TemaProvider } from "./context/TemaContext";

function AppLogIn() {
  return (
    <TemaProvider>
      <div id='main'>
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
      </div>
    </TemaProvider>
  );
}

export default AppLogIn;
