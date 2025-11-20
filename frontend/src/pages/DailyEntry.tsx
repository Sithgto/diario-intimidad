import React, { useEffect, useState } from 'react';
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
  logoUrl?: string;
}

interface VerseData {
  reference: string;
  text: string;
  translation_id: string;
  translation_name: string;
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  const day = date.getDate();
  const monthNames = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  const month = monthNames[date.getMonth()];
  return `${day} de ${month}`;
};

const DailyEntry: React.FC = () => {
  const [data, setData] = useState<DailyEntryData | null>(null);
  const [valores, setValores] = useState<{ [key: number]: CampoValor }>({});
  const [loading, setLoading] = useState(true);
  const [selectedAnio, setSelectedAnio] = useState<number | null>(null);
  const [verse1, setVerse1] = useState<VerseData | null>(null);
  const [verse2, setVerse2] = useState<VerseData | null>(null);
  const [translation1, setTranslation1] = useState('rv1960');
  const [translation2, setTranslation2] = useState('rv1995');
  const [isPlaying1, setIsPlaying1] = useState(false);
  const [isPlaying2, setIsPlaying2] = useState(false);
  const [customVerse, setCustomVerse] = useState('');
  const [showVerseSelector, setShowVerseSelector] = useState(false);
  const [verseError, setVerseError] = useState('');

  useEffect(() => {
    // Establecer el año actual por defecto
    const currentYear = new Date().getFullYear();
    setSelectedAnio(currentYear);
  }, []);

  useEffect(() => {
    if (selectedAnio !== null) {
      const fetchData = async () => {
        const currentDate = new Date();
        const mes = currentDate.getMonth() + 1; // getMonth() es 0-based
        const dia = currentDate.getDate();
        console.log('Frontend: Fetching daily entry for anio:', selectedAnio, 'mes:', mes, 'dia:', dia);
        setLoading(true);
        try {
          const token = localStorage.getItem('token');
          const url = `http://localhost:8085/api/daily-entry/today?anio=${selectedAnio}&mes=${mes}&dia=${dia}`;
          console.log('Frontend: Request URL:', url);
          const response = await axios.get(url, {
            headers: { Authorization: `Bearer ${token}` }
          });
          console.log('Frontend: Daily entry response:', response.data);
          console.log('versiculoDiario:', response.data.versiculoDiario);
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

          // Fetch Bible verses if there's a daily verse defined
          if (response.data.versiculoDiario) {
            await fetchVerses(response.data.versiculoDiario);
          } else {
            // If no daily verse, show selector
            setShowVerseSelector(true);
          }
        } catch (error) {
          console.error('Frontend: Error fetching daily entry data', error);
          setData(null);
        } finally {
          setLoading(false);
        }
      };
      fetchData();
    }
  }, [selectedAnio]);

  const fetchVerses = async (reference: string) => {
    setVerseError('');
    try {
      const [response1, response2] = await Promise.all([
        axios.get(`http://localhost:8085/api/bible/verse/${reference}`, {
          params: { translation: translation1 }
        }),
        axios.get(`http://localhost:8085/api/bible/verse/${reference}`, {
          params: { translation: translation2 }
        })
      ]);
      setVerse1(response1.data);
      setVerse2(response2.data);
    } catch (error) {
      console.error('Error fetching verses:', error);
      setVerseError('No se pudo cargar el versículo. Por favor, selecciona uno manualmente.');
      setVerse1(null);
      setVerse2(null);
    }
  };

  const speakVerse = (text: string, setPlaying: (playing: boolean) => void) => {
    if ('speechSynthesis' in window) {
      if (speechSynthesis.speaking) {
        speechSynthesis.cancel();
        setPlaying(false);
        setIsPlaying1(false);
        setIsPlaying2(false);
        return;
      }

      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'es-ES'; // Spanish by default

      utterance.onend = () => {
        setPlaying(false);
        setIsPlaying1(false);
        setIsPlaying2(false);
      };
      utterance.onerror = () => {
        setPlaying(false);
        setIsPlaying1(false);
        setIsPlaying2(false);
      };

      speechSynthesis.speak(utterance);
      setPlaying(true);
    } else {
      alert('Tu navegador no soporta síntesis de voz');
    }
  };

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
  if (!data) return <div>No hay datos para hoy. Verifica que haya un diario configurado para el año {selectedAnio}.</div>;

  return (
    <div className="app-container">
      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2>{formatDate(data.fecha).toUpperCase()}</h2>
          {data.diarioAnual?.logoUrl && <img src={data.diarioAnual.logoUrl} alt="Logo del diario" style={{ width: '30px', height: '30px' }} />}
        </div>

        {data.diarioAnual && (
          <div>
            <h3>{data.diarioAnual.titulo} - {data.diarioAnual.anio}</h3>
          </div>
        )}

        <div style={{ marginTop: '20px', marginBottom: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '15px' }}>
            <h3>📖 Versículo Diario</h3>
            {(!verse1 || verseError) && (
              <button
                className="btn"
                onClick={() => setShowVerseSelector(!showVerseSelector)}
                style={{ fontSize: '14px', padding: '5px 10px' }}
              >
                {showVerseSelector ? 'Ocultar' : 'Seleccionar Versículo'}
              </button>
            )}
          </div>
          {verseError && <p style={{color: 'red', marginBottom: '10px'}}>{verseError}</p>}

          {showVerseSelector && (
            <div style={{ marginBottom: '15px', padding: '10px', backgroundColor: '#fff3cd', borderRadius: '5px' }}>
              <input
                className="input"
                type="text"
                placeholder="Buscar versículo (ej: Juan 3:16)"
                value={customVerse}
                onChange={(e) => setCustomVerse(e.target.value)}
                style={{ marginRight: '10px', width: '250px' }}
              />
              <button
                className="btn"
                onClick={() => {
                  if (customVerse.trim()) {
                    fetchVerses(customVerse.trim());
                    setShowVerseSelector(false);
                  }
                }}
              >
                Cargar Versículo
              </button>
            </div>
          )}

          {(data.versiculoDiario || (verse1 && verse2)) && (
            <>
              <h4>{data.versiculoDiario || customVerse}</h4>
              <div style={{ display: 'flex', gap: '20px', marginTop: '15px' }}>
                {/* Versión 1 */}
                <div style={{ flex: 1, padding: '15px', border: '1px solid #ddd', borderRadius: '8px', backgroundColor: '#f9f9f9' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <select
                      value={translation1}
                      onChange={(e) => {
                        setTranslation1(e.target.value);
                        if (data.versiculoDiario) fetchVerses(data.versiculoDiario);
                      }}
                      style={{ padding: '5px', borderRadius: '4px' }}
                    >
                      <option value="rv1960">Reina Valera 1960</option>
                      <option value="rv1995">Reina Valera 1995</option>
                      <option value="nvi">Nueva version internacional</option>
                      <option value="dhh">Dios habla hoy</option>
                      <option value="pdt">Palabra de Dios para todos</option>
                      <option value="kjv">King James Version</option>
                    </select>
                    <button
                      className="btn"
                      onClick={() => speakVerse(verse1?.text || '', setIsPlaying1)}
                      style={{
                        backgroundColor: isPlaying1 ? '#ff4444' : '#4CAF50',
                        color: 'white',
                        border: 'none',
                        padding: '8px 12px',
                        borderRadius: '4px',
                        cursor: 'pointer'
                      }}
                    >
                      {isPlaying1 ? '⏹️ Detener' : '🔊 Escuchar'}
                    </button>
                  </div>
                  {verse1 && (
                    <div>
                      <p style={{ fontSize: '16px', lineHeight: '1.6', margin: 0 }}>
                        {verse1.text}
                      </p>
                      <small style={{ color: '#666', display: 'block', marginTop: '8px' }}>
                        {verse1.translation_name}
                      </small>
                    </div>
                  )}
                </div>

                {/* Versión 2 */}
                <div style={{ flex: 1, padding: '15px', border: '1px solid #ddd', borderRadius: '8px', backgroundColor: '#f0f8ff' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <select
                      value={translation2}
                      onChange={(e) => {
                        setTranslation2(e.target.value);
                        if (data.versiculoDiario) fetchVerses(data.versiculoDiario);
                      }}
                      style={{ padding: '5px', borderRadius: '4px' }}
                    >
                      <option value="rv1960">Reina Valera 1960</option>
                      <option value="rv1995">Reina Valera 1995</option>
                      <option value="nvi">Nueva version internacional</option>
                      <option value="dhh">Dios habla hoy</option>
                      <option value="pdt">Palabra de Dios para todos</option>
                      <option value="kjv">King James Version</option>
                    </select>
                    <button
                      className="btn"
                      onClick={() => speakVerse(verse2?.text || '', setIsPlaying2)}
                      style={{
                        backgroundColor: isPlaying2 ? '#ff4444' : '#4CAF50',
                        color: 'white',
                        border: 'none',
                        padding: '8px 12px',
                        borderRadius: '4px',
                        cursor: 'pointer'
                      }}
                    >
                      {isPlaying2 ? '⏹️ Detener' : '🔊 Escuchar'}
                    </button>
                  </div>
                  {verse2 && (
                    <div>
                      <p style={{ fontSize: '16px', lineHeight: '1.6', margin: 0 }}>
                        {verse2.text}
                      </p>
                      <small style={{ color: '#666', display: 'block', marginTop: '8px' }}>
                        {verse2.translation_name}
                      </small>
                    </div>
                  )}
                </div>
              </div>
            </>
          )}
        </div>

        {data.tipoDia === 'NORMAL' && data.lecturaBiblica && (
          <h3>Leer {data.lecturaBiblica}</h3>
        )}

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
              <textarea
                className="input"
                value={valores[campo.id]?.valorTexto || ''}
                onChange={(e) => setValores({
                  ...valores,
                  [campo.id]: { ...valores[campo.id], valorTexto: e.target.value }
                })}
                required={campo.esRequerido}
                rows={4}
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