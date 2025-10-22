import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './cadastro.css';
import logo from './assets/logoLazul.png';
import { Eye, EyeOff } from 'lucide-react';
import ApiManager from './ApiManager';
import temaEscuro from './AppLogIn';
import AppLogIn from './AppLogIn';

function Cadastro() {
  const [showSenha1, setShowSenha1] = useState(false);
  const [showConfirma1, setShowConfirma1] = useState(false);
  const [email, setEmail] = useState('');
  const [usuario, setUsuario] = useState('');
  const [senha, setSenha] = useState('');
  const [confirmaSenha, setConfirmaSenha] = useState('');
  const [cpf, setCpf] = useState('');
  const [telefone, setTelefone] = useState('');
  const [erro, setErro] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErro('');

    // Validações
    if (!email || !usuario || !senha || !confirmaSenha || !cpf || !telefone) {
      setErro('Preencha todos os campos.');
      return;
    }
    if (!email.includes('@')) {
      setErro('Email inválido.');
      return;
    }
    if (cpf.length !== 14) {
      setErro('CPF inválido.');
      return;
    }
    if (!(telefone.length === 14 || telefone.length === 15)) {
      setErro('Telefone inválido.');
      return;
    }
    if (senha !== confirmaSenha) {
      setErro('As senhas não coincidem.');
      return;
    }

    // Monta o payload conforme a API espera
    const dados = {
      idFuncionario: 0,        // default
      idcargo: 0,              // default
      nome: usuario,
      cpf: cpf, // apenas números
      email,
      senha,
      telefone,
      statusconta: "ativo"     // default
    };

    console.log('Payload enviado:', dados);

    try {
      const api = ApiManager.getApiService();
      const response = await api.post('/CadastrarBibliotecario', dados); // endpoint da API

      if (response.status === 200 || response.status === 201) {
        alert('Cadastro realizado com sucesso!');
        navigate('/dashboard');
      } else {
        alert('Erro ao cadastrar. Verifique os dados.');
      }
    } catch (error: any) {
      console.error('Erro no cadastro:', error.response?.data || error);
      alert('Erro de conexão ou dados inválidos.');
    }
  };

  

  return (
    <div className='conteiner'>
      <div id="cadastro-root">
        <img
          id="logo-cadastro"
          src={logo}
          alt="Logo Littera"
          style={{ cursor: 'pointer' }}
          onClick={() => navigate('/dashboard')}
        />
        <h1 id="cadastro-titulo">Seja Bem-Vindo!</h1>
        <div id="cadastro-desc">
          Cadastre-se agora e descubra um universo de ferramentas para a organização da sua biblioteca
        </div>
        <form id="cadastro-form" onSubmit={handleSubmit}>
          {erro && <div style={{ color: 'red', marginBottom: '10px' }}>{erro}</div>}
          <div className="cadastro-row">
            <div className="cadastro-col">
              <label className="textinho">Email</label>
              <input type="email" className="cadastro-input" value={email} onChange={e => setEmail(e.target.value)} />
              <label className="textinho">Usuário</label>
              <input type="text" className="cadastro-input" value={usuario} onChange={e => setUsuario(e.target.value)} />
              <label className="textinho">Senha</label>
              <div className="cadastro-input-group">
                <input
                  type={showSenha1 ? "text" : "password"}
                  className="cadastro-input"
                  value={senha}
                  onChange={e => setSenha(e.target.value)}
                />
                <button
                  type="button"
                  className="cadastro-eye"
                  onClick={() => setShowSenha1(v => !v)}
                  tabIndex={-1}
                  aria-label="Mostrar/ocultar senha"
                >
                  {showSenha1 ? <EyeOff size={22} color="#0A4489" /> : <Eye size={22} color="#0A4489" />}
                </button>
              </div>
              <label className="textinho">Confirmar senha</label>
              <div className="cadastro-input-group">
                <input
                  type={showConfirma1 ? "text" : "password"}
                  className="cadastro-input"
                  value={confirmaSenha}
                  onChange={e => setConfirmaSenha(e.target.value)}
                />
                <button
                  type="button"
                  className="cadastro-eye"
                  onClick={() => setShowConfirma1(v => !v)}
                  tabIndex={-1}
                  aria-label="Mostrar/ocultar senha"
                >
                  {showConfirma1 ? <EyeOff size={22} color="#0A4489" /> : <Eye size={22} color="#0A4489" />}
                </button>
              </div>
            </div>
            <div className="cadastro-col">
              <label className="textinho">CPF</label>
              <input
                type="text"
                className="cadastro-input"
                value={cpf}
                maxLength={14}
                onChange={e => {
                  let onlyNums = e.target.value.replace(/\D/g, '').slice(0, 11);
                  let formatted = onlyNums;
                  if (onlyNums.length > 9) formatted = onlyNums.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
                  else if (onlyNums.length > 6) formatted = onlyNums.replace(/(\d{3})(\d{3})(\d{1,3})/, '$1.$2.$3');
                  else if (onlyNums.length > 3) formatted = onlyNums.replace(/(\d{3})(\d{1,3})/, '$1.$2');
                  setCpf(formatted);
                }}
              />
              <label className="textinho">Telefone</label>
              <input
                type="text"
                className="cadastro-input"
                value={telefone}
                maxLength={15}
                onChange={e => {
                  let onlyNums = e.target.value.replace(/\D/g, '').slice(0, 11);
                  let formatted = onlyNums;
                  if (onlyNums.length > 10) formatted = onlyNums.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
                  else if (onlyNums.length > 6) formatted = onlyNums.replace(/(\d{2})(\d{4})(\d{0,4})/, '($1) $2-$3');
                  else if (onlyNums.length > 2) formatted = onlyNums.replace(/(\d{2})(\d{0,5})/, '($1) $2');
                  else if (onlyNums.length > 0) formatted = onlyNums.replace(/(\d{0,2})/, '($1');
                  setTelefone(formatted.trim());
                }}
              />
            </div>
          </div>
          <button type="submit" id="cadastro-btn">Cadastre-se</button>
        </form>
      </div>
    </div>
  );
}

export default Cadastro;
