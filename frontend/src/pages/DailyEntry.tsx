import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

interface DailyEntryData {
  fecha: string;
  tipoDia: string;
  lecturaBiblica?: string;
  versiculoDiario?: string;
  diarioAnual?: {
    titulo: string;
    anio: number;
  };
  camposDiario: CampoDiario[];
}

interface CampoDiario {
  id: number;
  nombreCampo: string;
  tipoEntrada: string;
  esRequerido: boolean;
}

interface CampoValor {
  campoDiarioId: number;
  valorTexto: string;
  valorAudioUrl?: string;
}

interface DiarioAnual {
  id: number;
  titulo: string;
  anio: number;
}

const DailyEntry: React.FC = () => {
  const [data, setData] = useState<DailyEntryData | null>(null);
  const [valores, setValores] = useState<{ [key: number]: CampoValor }>({});
  const [loading, setLoading] = useState(true);
  const [diarios, setDiarios] = useState<DiarioAnual[]>([]);
  const [selectedAnio, setSelectedAnio] = useState<number | null>(null);

  useEffect(() => {
    const fetchDiarios = async () => {
      try {
        console.log('Frontend: Fetching diarios...');
        const token = localStorage.getItem('token');
        const response = await axios.get('http://localhost:8085/api/daily-entry/diarios', {
          headers: { Authorization: `Bearer ${token}` }
        });
        console.log('Frontend: Diarios response:', response.data);
        setDiarios(response.data);
        // Seleccionar el año actual por defecto si existe
        const currentYear = new Date().getFullYear();
        const defaultDiario = response.data.find((d: DiarioAnual) => d.anio === currentYear);
        console.log('Frontend: Selected diario:', defaultDiario);
        if (defaultDiario) {
          setSelectedAnio(defaultDiario.anio);
        }
      } catch (error) {
        console.error('Frontend: Error fetching diarios', error);
      }
    };
    fetchDiarios();
  }, []);

  useEffect(() => {
    if (selectedAnio !== null) {
      const fetchData = async () => {
        console.log('Frontend: Fetching daily entry for anio:', selectedAnio);
        setLoading(true);
        try {
          const token = localStorage.getItem('token');
          const url = `http://localhost:8085/api/daily-entry/today?anio=${selectedAnio}`;
          console.log('Frontend: Request URL:', url);
          const response = await axios.get(url, {
            headers: { Authorization: `Bearer ${token}` }
          });
          console.log('Frontend: Daily entry response:', response.data);
          setData(response.data);
          // Inicializar valores
          const initialValores: { [key: number]: CampoValor } = {};
          response.data.camposDiario.forEach((campo: CampoDiario) => {
            initialValores[campo.id] = {
              campoDiarioId: campo.id,
              valorTexto: '',
              valorAudioUrl: campo.tipoEntrada === 'AUDIO' ? '' : undefined
            };
          });
          setValores(initialValores);
        } catch (error) {
          console.error('Frontend: Error fetching daily entry data', error);
          console.log('Frontend: Error response:', error.response);
          setData(null);
        } finally {
          setLoading(false);
        }
      };
      fetchData();
    }
  }, [selectedAnio]);

  const handleSave = async () => {
    try {
      const token = localStorage.getItem('token');
      const requestData = {
        valoresCampo: Object.values(valores)
      };
      await axios.post('http://localhost:8085/api/daily-entry/save', requestData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert('Entrada guardada exitosamente');
    } catch (error) {
      console.error('Error saving entry', error);
      alert('Error al guardar la entrada');
    }
  };

  if (loading) return <div>Cargando...</div>;
  if (!data) return <div>No hay datos para hoy</div>;

  return (
    <div className="app-container">
      <header className="header">
        <div className="header-title">Diario de Intimidad</div>
        <nav className="header-nav">
          <Link to="/" className="nav-icon">🏠 Inicio</Link>
          <Link to="/users" className="nav-icon">👥 Gestionar Usuarios</Link>
          <Link to="/api-docs" className="nav-icon">📚 Documentación APIs</Link>
          <button className="nav-icon logout-btn" onClick={() => { localStorage.removeItem('token'); window.location.href = '/login'; }}>🚪 Logout</button>
        </nav>
      </header>
      <div className="card">
        <h2>Entrada Diaria - {data.fecha}</h2>

        <div style={{ marginBottom: '20px' }}>
          <label>Seleccionar Año del Diario:</label>
          <select
            value={selectedAnio || ''}
            onChange={(e) => setSelectedAnio(Number(e.target.value))}
            className="input"
          >
            {diarios.map(diario => (
              <option key={diario.id} value={diario.anio}>
                {diario.titulo} - {diario.anio}
              </option>
            ))}
          </select>
        </div>

        {data.tipoDia === 'DOMINGO' && data.diarioAnual && (
          <div>
            <h3>{data.diarioAnual.titulo} - {data.diarioAnual.anio}</h3>
            <p><strong>Versículo Diario:</strong> {data.versiculoDiario}</p>
          </div>
        )}

        {data.tipoDia === 'NORMAL' && data.lecturaBiblica && (
          <div>
            <h3>Lectura Bíblica</h3>
            <p>{data.lecturaBiblica}</p>
          </div>
        )}

        <h3>Campos a Rellenar</h3>
        {data.camposDiario.map(campo => (
          <div key={campo.id} style={{ marginBottom: '15px' }}>
            <label>{campo.nombreCampo} {campo.esRequerido ? '*' : ''}</label>
            {campo.tipoEntrada === 'TEXTAREA' ? (
              <textarea
                className="input"
                value={valores[campo.id]?.valorTexto || ''}
                onChange={(e) => setValores({
                  ...valores,
                  [campo.id]: { ...valores[campo.id], valorTexto: e.target.value }
                })}
                required={campo.esRequerido}
              />
            ) : campo.tipoEntrada === 'AUDIO' ? (
              <div>
                <input
                  className="input"
                  type="text"
                  placeholder="URL del audio"
                  value={valores[campo.id]?.valorAudioUrl || ''}
                  onChange={(e) => setValores({
                    ...valores,
                    [campo.id]: { ...valores[campo.id], valorAudioUrl: e.target.value }
                  })}
                />
                <input
                  className="input"
                  type="text"
                  placeholder="Transcripción"
                  value={valores[campo.id]?.valorTexto || ''}
                  onChange={(e) => setValores({
                    ...valores,
                    [campo.id]: { ...valores[campo.id], valorTexto: e.target.value }
                  })}
                />
              </div>
            ) : (
              <input
                className="input"
                type="text"
                value={valores[campo.id]?.valorTexto || ''}
                onChange={(e) => setValores({
                  ...valores,
                  [campo.id]: { ...valores[campo.id], valorTexto: e.target.value }
                })}
                required={campo.esRequerido}
              />
            )}
          </div>
        ))}

        <button className="btn" onClick={handleSave}>Guardar Entrada</button>
      </div>
    </div>
  );
};

export default DailyEntry;