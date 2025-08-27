import React from 'react';
import './denuncias.css';
import Menu from './components/menu';
import { User } from 'lucide-react';

const denuncias = [
  {
    autor: 'Vitória',
    motivo: 'Spam',
    post: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.si tincidunt id justo.Lorem ipsum dolor sit amet, consectetur adipiscing elit.si tincidunt sapien, eget volutpat sapien lacus id justo......',
  },
  {
    autor: 'Vitória',
    motivo: 'Conteúdo Impróprio',
    post: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.si tincidunt id justo.Lorem ipsum dolor sit amet, consectetur adipiscing elit.si tincidunt sapien, eget volutpat sapien lacus id justo......',
  },
];

function Denuncias() {
  return (
    <div className="conteinerDenuncias">
      <Menu />
      <div className="conteudoDenuncias">
        <h2 className="denuncias-titulo">Denúncias</h2>
        <div className="denuncias-box">
          <table className="denuncias-tabela">
            <thead>
              <tr>
                <th>Autor da denúncia</th>
                <th>Motivo</th>
                <th>Post Denunciado</th>
              </tr>
            </thead>
            <tbody>
              {denuncias.map((d, i) => (
                <tr key={i}>
                  <td>
                    <div className="denuncias-user">
                      <User size={22} style={{ marginRight: 8 }} />
                      {d.autor}
                    </div>
                  </td>
                  <td className="denuncias-motivo">{d.motivo}</td>
                  <td className="denuncias-post">
                    <span>{d.post}</span>
                    <button className="denuncias-vermais">ver mais</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default Denuncias;