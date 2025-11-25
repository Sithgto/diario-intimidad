import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { API_BASE_URL } from '../constants/api';

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

interface DiarioAnual {
  id: number;
  titulo: string;
  anio: number;
  nombreLogo?: string;
  nombrePortada?: string;
}

const Calendario: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [data, setData] = useState<CalendarEntryResponse | null>(null);
  const [valores, setValores] = useState<{ [key: number]: CampoValor }>({});
  const [loading, setLoading] = useState(false);
  const [selectedYear, setSelectedYear] = useState(() => {
    const yearParam = searchParams.get('year');
    return yearParam ? parseInt(yearParam) : new Date().getFullYear();
  });
  const [entradasAnuales, setEntradasAnuales] = useState<{ [mes: number]: EntradaDiaria[] }>({});
  const [existingEntry, setExistingEntry] = useState<EntradaDiaria | null>(null);
  const [showDetails, setShowDetails] = useState(false);
  const [hoveredDay, setHoveredDay] = useState<string | null>(null);
  const [diary, setDiary] = useState<DiarioAnual | null>(null);
  const [columns, setColumns] = useState(4);

  useEffect(() => {
    fetchEntradasAnuales();
    fetchDiary(selectedYear);
  }, [selectedYear]);

  useEffect(() => {
    const updateColumns = () => {
      const width = window.innerWidth;
      if (width >= 1200) setColumns(4); // desktop
      else if (width >= 992) setColumns(3); // laptop
      else if (width >= 768) setColumns(2); // tablet
      else setColumns(1); // mobile
    };
    updateColumns();
    window.addEventListener('resize', updateColumns);
    return () => window.removeEventListener('resize', updateColumns);
  }, []);

  const fetchEntradasAnuales = async () => {
    try {
      const token = localStorage.getItem('token');
      const promises = [];
      for (let mes = 1; mes <= 12; mes++) {
        promises.push(
          axios.get(`${API_BASE_URL}/api/daily-entry/user-entries?anio=${selectedYear}&mes=${mes}`, {
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

  const fetchDiary = async (year: number) => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_BASE_URL}/api/diarios-anuales`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      const diary = response.data.find((d: any) => d.anio === year);
      setDiary(diary || null);
    } catch (error) {
      console.error('Error fetching diary', error);
      setDiary(null);
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
      const url = `${API_BASE_URL}/api/daily-entry/today?dia=${dia}&mes=${mes}&anio=${anio}`;
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
    navigate(`/daily-entry?date=${dateStr}`);
  };

  const handleSave = async () => {
    try {
      const token = localStorage.getItem('token');
      console.log('Token obtenido de localStorage:', token);
      const requestData = {
        valoresCampo: Object.values(valores)
      };
      console.log('Enviando petición POST con token:', token);
      await axios.post(`${API_BASE_URL}/api/daily-entry/save`, requestData, {
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
    <div className="app-container" style={{ position: 'relative' }}>
      {diary?.nombrePortada && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundImage: `url(${API_BASE_URL}/uploads/images/${diary.nombrePortada})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
            filter: 'blur(10px)',
            zIndex: -1
          }}
        />
      )}
      <div className="card" style={{ position: 'relative', zIndex: 2, backgroundColor: 'rgba(255, 255, 255, 0.6)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h2>Calendario de Entradas</h2>
          {diary?.nombreLogo && (
            <img
              src={`${API_BASE_URL}/uploads/images/${diary.nombreLogo}`}
              alt="Logo"
              style={{
                width: columns === 4 ? '150px' : columns === 3 ? '130px' : columns === 2 ? '110px' : '90px',
                height: 'auto'
              }}
            />
          )}
        </div>

        <div style={{ marginBottom: '20px' }}>
          <label>Seleccionar Año:</label>
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value))}
            className="input"
            style={{ width: '120px', marginLeft: '10px' }}
          >
            <option value={selectedYear - 1}>{selectedYear - 1}</option>
            <option value={selectedYear}>{selectedYear}</option>
            <option value={selectedYear + 1}>{selectedYear + 1}</option>
          </select>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: `repeat(${columns}, 1fr)`, gap: '20px' }}>
          {monthNames.map((monthName, index) => {
            const month = index + 1;
            const days = getCalendarDays(selectedYear, month);
            const today = new Date();
            const isCurrentMonth = selectedYear === today.getFullYear() && month === today.getMonth() + 1;
            return (
              <div key={month} style={{ border: '1px solid #ccc', padding: '5px' }}>
                <h3 style={{ textAlign: 'center' }}>{monthName} {selectedYear}</h3>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '2px', marginBottom: '5px' }}>
                  {dayNames.map(day => (
                    <div key={day} style={{ textAlign: 'center', fontWeight: 'bold', fontSize: '12px' }}>{day}</div>
                  ))}
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '2px' }}>
                  {days.map((day, dayIndex) => {
                    const isToday = day && isCurrentMonth && day === today.getDate();
                    return (
                      <div
                        key={dayIndex}
                        style={{
                          textAlign: 'center',
                          padding: '3px',
                          cursor: day ? 'pointer' : 'default',
                          backgroundColor: isToday ? '#add8e6' : day && hasEntry(selectedYear, month, day) ? '#4CAF50' : hoveredDay === `${month}-${day}` ? '#0900D2' : 'transparent',
                          border: isToday ? '2px solid #007bff' : day ? '1px solid #ddd' : 'none',
                          fontWeight: isToday ? 'bold' : 'normal'
                        }}
                        onMouseEnter={day ? () => setHoveredDay(`${month}-${day}`) : undefined}
                        onMouseLeave={day ? () => setHoveredDay(null) : undefined}
                        onClick={day ? () => handleDayClick(selectedYear, month, day) : undefined}
                      >
                        {day}
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>

        {showDetails && (
          <>
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

            <button className="btn" onClick={() => { setShowDetails(false); setSelectedDate(''); setData(null); }}>Ocultar Detalles</button>
          </>
        )}
      </div>
    </div>
  );
};

export default Calendario;