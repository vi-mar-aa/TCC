import React from 'react';
import './infoAcervo.css';

export default function InfoAcervo() {
  return (
    <div className="info-acervo-container">
      <div className="info-acervo-top">
        <img
          className="info-acervo-cover"
          src="https://images-na.ssl-images-amazon.com/images/I/81QZVt6lQwL.jpg"
          alt="The Dragon Republic"
        />
        <div className="info-acervo-geral">
          <h2>Informações gerais</h2>
          <div className="info-acervo-list">
            <div><b>Título:</b> The Dragon Republic</div>
            <div><b>Autor:</b> R.F. Kuang</div>
            <div><b>Ano de lançamento:</b> 2022</div>
            <div><b>Editora:</b> Intrínseca</div>
            <div><b>ISBN:</b> 978-3-16-148410-0</div>
            <div><b>Gênero:</b> Fantasia</div>
            <div><b>Edição:</b> 3°</div>
            <div><b>Sinopse:</b> Lorem ipsum dolor...</div>
          </div>
          <button className="info-acervo-edit-btn">
            <svg width="24" height="24" fill="#0A4489"><circle cx="12" cy="12" r="12"/><path d="M7 17h2l7-7-2-2-7 7v2zm9.7-9.3a1 1 0 0 0 0-1.4l-2-2a1 1 0 0 0-1.4 0l-1.1 1.1 3.4 3.4 1.1-1.1z" fill="#fff"/></svg>
          </button>
        </div>
        <div className="info-acervo-status">
          <span className="info-acervo-status-num">2/30</span>
          <span>exemplares<br/>emprestados</span>
        </div>
      </div>
      <div className="info-acervo-bottom">
        <h3>Exemplares:</h3>
        <table>
          <thead>
            <tr>
              <th>Código</th>
              <th>Status</th>
              <th>Usuário</th>
              <th>Data de devolução</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>978-3-16-148410-0/1</td>
              <td className="status-emprestado">Emprestado</td>
              <td>anabferreira</td>
              <td>12/05/25</td>
              <td>...</td>
            </tr>
            <tr>
              <td>978-3-16-148410-0/2</td>
              <td className="status-reservado">Reservado</td>
              <td>—</td>
              <td>—</td>
              <td>...</td>
            </tr>
            <tr>
              <td>978-3-16-148410-0/3</td>
              <td className="status-livre">Livre</td>
              <td>—</td>
              <td>—</td>
              <td>...</td>
            </tr>
            <tr>
              <td>978-3-16-148410-0/4</td>
              <td className="status-atrasado">Atrasado</td>
              <td>anabferreira</td>
              <td>12/05/25</td>
              <td>...</td>
            </tr>
            <tr>
              <td>978-3-16-148410-0/5</td>
              <td className="status-renovado">Renovado</td>
              <td>anabferreira</td>
              <td>12/05/25</td>
              <td>...</td>
            </tr>
            <tr>
              <td>978-3-16-148410-0/6</td>
              <td className="status-livre">Livre</td>
              <td>—</td>
              <td>—</td>
              <td>...</td>
            </tr>
            <tr>
              <td>978-3-16-148410-0/7</td>
              <td className="status-livre">Livre</td>
              <td>—</td>
              <td>—</td>
              <td>...</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}