import React, { useState, useEffect } from 'react';
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

interface EntradaDiaria {
  id: number;
  fechaEntrada: string;
  completado: boolean;
}

const Calendario: React.FC = () => {
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [data, setData] = useState<CalendarEntryResponse | null>(null);
  const [valores, setValores] = useState<{ [key: number]: CampoValor }>({});
  const [loading, setLoading] = useState(false);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [entradasAnuales, setEntradasAnuales] = useState<{ [mes: number]: EntradaDiaria[] }>({});
  const [existingEntry, setExistingEntry] = useState<EntradaDiaria | null>(null);

  useEffect(() => {
    fetchEntradasAnuales();
  }, [selectedYear]);

  const fetchEntradasAnuales = async () => {
    try {
      const token = localStorage.getItem('token');
      const promises = [];
      for (let mes = 1; mes <= 12; mes++) {
        promises.push(
          axios.get(`http://localhost:8085/api/daily-entry/user-entries?anio=${selectedYear}&mes=${mes}`, {
            headers: { Authorization: `Bearer ${token}` }
          }).then(response => ({ mes, data: response.data }))
        );
      }
      const results = await Promise.all(promises);
      const nuevasEntradas: { [mes: number]: EntradaDiaria[] } = {};
      results.forEach(({ mes, data }) => {
        nuevasEntradas[mes] = data;
      });
      setEntradasAnuales(nuevasEntradas);
    } catch (error) {
      console.error('Error fetching entradas anuales', error);
    }
  };

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

  const getCalendarDays = (year: number, month: number) => {
    const firstDay = new Date(year, month - 1, 1);
    const lastDay = new Date(year, month, 0);
    const daysInMonth = lastDay.getDate();
    const startDayOfWeek = firstDay.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

    // Adjust for Monday as first day: if startDayOfWeek is 0 (Sunday), set to 6 (last), else subtract 1
    const adjustedStartDay = startDayOfWeek === 0 ? 6 : startDayOfWeek - 1;

    const days = [];
    // Add empty cells for days before the first day of the month
    for (let i = 0; i < adjustedStartDay; i++) {
      days.push(null);
    }
    // Add days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(day);
    }
    return days;
  };

  const hasEntry = (year: number, month: number, day: number) => {
    const entradasMes = entradasAnuales[month] || [];
    return entradasMes.some(entrada => {
      const fecha = new Date(entrada.fechaEntrada);
      return fecha.getFullYear() === year && fecha.getMonth() + 1 === month && fecha.getDate() === day;
    });
  };

  const handleDayClick = (year: number, month: number, day: number) => {
    const dateStr = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
    handleDateChange(dateStr);
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

  const monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  const dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  return (
    <div className="app-container">
      <div className="card">
        <h2>Calendario de Entradas</h2>

        <div style={{ marginBottom: '20px' }}>
          <label>Seleccionar Año:</label>
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value))}
            className="input"
          >
            <option value={selectedYear - 1}>{selectedYear - 1}</option>
            <option value={selectedYear}>{selectedYear}</option>
            <option value={selectedYear + 1}>{selectedYear + 1}</option>
          </select>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '20px' }}>
          {monthNames.map((monthName, index) => {
            const month = index + 1;
            const days = getCalendarDays(selectedYear, month);
            return (
              <div key={month} style={{ border: '1px solid #ccc', padding: '10px' }}>
                <h3 style={{ textAlign: 'center' }}>{monthName} {selectedYear}</h3>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '5px', marginBottom: '10px' }}>
                  {dayNames.map(day => (
                    <div key={day} style={{ textAlign: 'center', fontWeight: 'bold' }}>{day}</div>
                  ))}
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '5px' }}>
                  {days.map((day, dayIndex) => (
                    <div
                      key={dayIndex}
                      style={{
                        textAlign: 'center',
                        padding: '5px',
                        cursor: day ? 'pointer' : 'default',
                        backgroundColor: day && hasEntry(selectedYear, month, day) ? '#d4edda' : 'transparent',
                        border: day ? '1px solid #ddd' : 'none'
                      }}
                      onClick={day ? () => handleDayClick(selectedYear, month, day) : undefined}
                    >
                      {day}
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {selectedDate && (
          <>
            <h3>Seleccionar Fecha: {selectedDate}</h3>
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => handleDateChange(e.target.value)}
              className="input"
              style={{ marginBottom: '20px' }}
            />
          </>
        )}

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