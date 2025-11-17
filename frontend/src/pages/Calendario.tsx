import React, { useState } from 'react';
import axios from 'axios';

interface CalendarEntryResponse {
  fecha: string; // Asumiendo que se serializa como string
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

const Calendario: React.FC = () => {
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [data, setData] = useState<CalendarEntryResponse | null>(null);
  const [valores, setValores] = useState<{ [key: number]: CampoValor }>({});
  const [loading, setLoading] = useState(false);

  const handleDateChange = async (date: string) => {
    setSelectedDate(date);
    if (!date) {
      setData(null);
      return;
    }

    const [anio, mes, dia] = date.split('-').map(Number);
    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      console.log('Token obtenido de localStorage:', token);
      const url = `http://localhost:8085/api/daily-entry/today?dia=${dia}&mes=${mes}&anio=${anio}`;
      console.log('Enviando petición GET con token:', token);
      console.log('URL completa de la petición:', url);
      console.log('Headers de la petición:', { Authorization: `Bearer ${token}` });
      console.log('Detalles adicionales: método GET, fecha seleccionada:', date);
      const response = await axios.get(url, {
        headers: { Authorization: `Bearer ${token}` }
      });
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
      console.error('Error detallado en la petición GET:', error);
      setData(null);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      const token = localStorage.getItem('token');
      console.log('Token obtenido de localStorage:', token);
      const requestData = {
        valoresCampo: Object.values(valores)
      };
      console.log('Enviando petición POST con token:', token);
      await axios.post('http://localhost:8085/api/daily-entry/save', requestData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert('Entrada guardada exitosamente');
    } catch (error) {
      console.error('Error detallado en la petición POST:', error);
      alert('Error al guardar la entrada');
    }
  };

  return (
    <div className="app-container">
      <div className="card">
        <h2>Calendario de Entradas</h2>

        <div style={{ marginBottom: '20px' }}>
          <label>Seleccionar Fecha:</label>
          <input
            type="date"
            value={selectedDate}
            onChange={(e) => handleDateChange(e.target.value)}
            className="input"
          />
        </div>

        {loading && <div>Cargando...</div>}

        {data && (
          <>
            <h3>Entrada para {data.fecha}</h3>

            {data.tipoDia === 'DOMINGO' && data.diarioAnual && (
              <div>
                <h4>{data.diarioAnual.titulo} - {data.diarioAnual.anio}</h4>
                <p><strong>Versículo Diario:</strong> {data.versiculoDiario}</p>
              </div>
            )}

            {data.tipoDia === 'NORMAL' && data.lecturaBiblica && (
              <div>
                <h4>Lectura Bíblica</h4>
                <p>{data.lecturaBiblica}</p>
              </div>
            )}

            <h4>Campos a Rellenar</h4>
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
          </>
        )}

        {!data && !loading && selectedDate && <div>No hay datos para la fecha seleccionada</div>}
      </div>
    </div>
  );
};

export default Calendario;