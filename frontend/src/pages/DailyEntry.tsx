import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { API_BASE_URL } from '../constants/api';

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
  valoresCampo?: CampoValor[];
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
  nombreLogo?: string;
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
  console.log('DailyEntry component rendered');
  const [data, setData] = useState<DailyEntryData | null>(null);
  const [valores, setValores] = useState<{ [key: number]: CampoValor }>({});
  const [loading, setLoading] = useState(true);
  const [selectedAnio, setSelectedAnio] = useState<number | null>(null);
  const [verse1, setVerse1] = useState<VerseData | null>(null);
  const [verse2, setVerse2] = useState<VerseData | null>(null);
  const [translation1, setTranslation1] = useState('rv1960');
  const [translation2, setTranslation2] = useState('nvi');
  const [isPlaying1, setIsPlaying1] = useState(false);
  const [isPlaying2, setIsPlaying2] = useState(false);
  const [customVerse, setCustomVerse] = useState('');
  const [showVerseSelector, setShowVerseSelector] = useState(false);
  const [verseError, setVerseError] = useState('');
  const [showNumbers, setShowNumbers] = useState(false);
  const [isSaved, setIsSaved] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);
  const [currentReference, setCurrentReference] = useState<string>('');
  // TTS configuration states
  const [voices, setVoices] = useState<SpeechSynthesisVoice[]>([]);
  const [selectedVoice, setSelectedVoice] = useState<string>('');
  const [ttsRate, setTtsRate] = useState<number>(1);
  const [ttsPitch, setTtsPitch] = useState<number>(1);
  const [ttsVolume, setTtsVolume] = useState<number>(1);
  const [showTtsSettings, setShowTtsSettings] = useState(false);

  useEffect(() => {
    // Establecer el año actual por defecto
    const currentYear = new Date().getFullYear();
    console.log('DailyEntry: Setting selectedAnio to', currentYear);
    setSelectedAnio(currentYear);
  }, []);

  useEffect(() => {
    // Load available voices for TTS
    const loadVoices = () => {
      const availableVoices = speechSynthesis.getVoices();
      setVoices(availableVoices);
      // Set default voice to first Spanish voice if available
      const spanishVoice = availableVoices.find(voice => voice.lang.startsWith('es'));
      if (spanishVoice) {
        setSelectedVoice(spanishVoice.name);
      }
    };

    loadVoices();
    if (speechSynthesis.onvoiceschanged !== undefined) {
      speechSynthesis.onvoiceschanged = loadVoices;
    }
  }, []);

  useEffect(() => {
    console.log('DailyEntry: useEffect fetch triggered');
    const fetchData = async () => {
        const currentDate = new Date();
        const mes = currentDate.getMonth() + 1; // getMonth() es 0-based
        const dia = currentDate.getDate();
        console.log('Frontend: Fetching daily entry for anio:', selectedAnio, 'mes:', mes, 'dia:', dia);
        setLoading(true);
        try {
          const token = localStorage.getItem('token');
          console.log('Frontend: Token from localStorage:', token ? 'present' : 'null');
          const url = `${API_BASE_URL}/api/daily-entry/today?anio=${selectedAnio}&mes=${mes}&dia=${dia}`;
          console.log('Frontend: Request URL:', url);
          const response = await axios.get(url, {
            headers: { Authorization: `Bearer ${token}` }
          });
          console.log('Frontend: Daily entry response received');
          console.log('Frontend: Response data:', response.data);
          console.log('Frontend: versiculoDiario:', response.data.versiculoDiario);
          console.log('Frontend: camposDiario length:', response.data.camposDiario ? response.data.camposDiario.length : 'null');
          console.log('Frontend: valoresCampo:', response.data.valoresCampo);
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
          // Load existing valores if present
          if (response.data.valoresCampo) {
            response.data.valoresCampo.forEach((valor: CampoValor) => {
              initialValores[valor.campoDiarioId] = {
                campoDiarioId: valor.campoDiarioId,
                valorTexto: valor.valorTexto,
                valorAudioUrl: valor.valorAudioUrl
              };
            });
            setIsSaved(true);
          }
          setValores(initialValores);

          // Fetch Bible verses if there's a daily verse defined
          if (response.data.versiculoDiario) {
            console.log('Frontend: Calling fetchVerses for:', response.data.versiculoDiario);
            setCurrentReference(response.data.versiculoDiario);
            await fetchVerses(response.data.versiculoDiario, showNumbers);
          } else {
            console.log('Frontend: No versiculoDiario, showing selector');
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
  }, [selectedAnio]);

  useEffect(() => {
    if (currentReference) {
      fetchVerses(currentReference, showNumbers);
    }
  }, [showNumbers]);

  // useEffect(() => {
  //   if (!loading && data && isSaved) {
  //     navigate('/');
  //   }
  // }, [loading, data, isSaved, navigate]);

  const fetchVerses = async (reference: string, includeNumbers: boolean = true) => {
    console.log('Frontend: Fetching verses for reference:', reference, 'translations:', translation1, translation2, 'includeNumbers:', includeNumbers);
    setVerseError('');
    try {
      const [response1, response2] = await Promise.all([
        axios.get(`${API_BASE_URL}/api/bible/verse/${reference}`, {
          params: { translation: translation1, includeNumbers }
        }),
        axios.get(`${API_BASE_URL}/api/bible/verse/${reference}`, {
          params: { translation: translation2, includeNumbers }
        })
      ]);
      console.log('Frontend: Verse response1:', response1.data);
      console.log('Frontend: Verse response2:', response2.data);
      setVerse1(response1.data);
      setVerse2(response2.data);
      console.log('Frontend: Set verse1 and verse2');
    } catch (error) {
      console.error('Error fetching verses:', error);
      setVerseError('No se pudo cargar el versículo. Por favor, selecciona uno manualmente.');
      setVerse1(null);
      setVerse2(null);
      console.log('Frontend: Failed to fetch verses, set to null');
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
      // Set voice if selected
      if (selectedVoice) {
        const voice = voices.find(v => v.name === selectedVoice);
        if (voice) {
          utterance.voice = voice;
        } else {
          utterance.lang = 'es-ES'; // Fallback to Spanish
        }
      } else {
        utterance.lang = 'es-ES'; // Default Spanish
      }
      // Apply TTS settings
      utterance.rate = ttsRate;
      utterance.pitch = ttsPitch;
      utterance.volume = ttsVolume;

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
      await axios.post(`${API_BASE_URL}/api/daily-entry/save`, requestData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert('Entrada guardada exitosamente');
      setIsSaved(true);
      setHasChanges(false);
    } catch (error) {
      console.error('Error saving entry', error);
      alert('Error al guardar la entrada');
    }
  };

  const handleFieldChange = (campoId: number, value: string, isAudioUrl?: boolean) => {
    setValores({
      ...valores,
      [campoId]: isAudioUrl
        ? { ...valores[campoId], valorAudioUrl: value }
        : { ...valores[campoId], valorTexto: value }
    });
    if (isSaved) {
      setHasChanges(true);
    }
  };

  if (loading) return <div>Cargando...</div>;
  if (!data) return <div>No hay datos para hoy. Verifica que haya un diario configurado para el año {selectedAnio}.</div>;

  return (
    <div className="app-container">
      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2>{formatDate(data.fecha).toUpperCase()}</h2>
          {data.diarioAnual?.nombreLogo && <img src={`${API_BASE_URL}/uploads/images/${data.diarioAnual.nombreLogo}`} alt="Logo del diario" style={{ width: '120px', height: '120px' }} />}
        </div>


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
            <button
              className="btn"
              onClick={() => setShowTtsSettings(!showTtsSettings)}
              style={{ fontSize: '14px', padding: '5px 10px' }}
            >
              {showTtsSettings ? 'Ocultar Voz' : 'Configurar Voz'}
            </button>
          </div>
          {verseError && <p style={{color: 'red', marginBottom: '10px'}}>{verseError}</p>}

          {showTtsSettings && (
            <div style={{ marginBottom: '15px', padding: '10px', backgroundColor: '#e7f3ff', borderRadius: '5px' }}>
              <h4>Configuración de Voz</h4>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <div>
                  <label>Voz: </label>
                  <select value={selectedVoice} onChange={(e) => setSelectedVoice(e.target.value)}>
                    <option value="">Predeterminada</option>
                    {voices.filter(v => v.lang.startsWith('es')).map(voice => (
                      <option key={voice.name} value={voice.name}>{voice.name} ({voice.lang})</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label>Velocidad: {ttsRate.toFixed(1)}</label>
                  <input type="range" min="0.5" max="2" step="0.1" value={ttsRate} onChange={(e) => setTtsRate(parseFloat(e.target.value))} />
                </div>
                <div>
                  <label>Tono: {ttsPitch.toFixed(1)}</label>
                  <input type="range" min="0" max="2" step="0.1" value={ttsPitch} onChange={(e) => setTtsPitch(parseFloat(e.target.value))} />
                </div>
                <div>
                  <label>Volumen: {ttsVolume.toFixed(1)}</label>
                  <input type="range" min="0" max="1" step="0.1" value={ttsVolume} onChange={(e) => setTtsVolume(parseFloat(e.target.value))} />
                </div>
              </div>
            </div>
          )}

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
                    fetchVerses(customVerse.trim(), showNumbers);
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
              {console.log('Frontend: Rendering verses: verse1:', verse1, 'verse2:', verse2, 'data.versiculoDiario:', data.versiculoDiario)}
              <h4>{currentReference}</h4>
              <div style={{ display: 'flex', gap: '20px', marginTop: '15px' }}>
                {/* Versión 1 */}
                <div style={{ flex: 1, padding: '15px', border: '1px solid #ddd', borderRadius: '8px', backgroundColor: '#f9f9f9' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <select
                      value={translation1}
                      onChange={(e) => {
                        setTranslation1(e.target.value);
                        fetchVerses(currentReference, showNumbers);
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
                    <div style={{ display: 'flex', gap: '10px' }}>
                      <button
                        title="Mostrar/ocultar números de versículos"
                        onClick={() => setShowNumbers(!showNumbers)}
                        style={{
                          backgroundColor: showNumbers ? '#4CAF50' : '#f44336',
                          color: 'white',
                          border: 'none',
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '18px'
                        }}
                      >
                        {showNumbers ? '🔢' : '📄'}
                      </button>
                      <button
                        title={isPlaying1 ? 'Detener' : 'Escuchar'}
                        onClick={() => speakVerse(verse1?.text || '', setIsPlaying1)}
                        style={{
                          backgroundColor: isPlaying1 ? '#ff4444' : '#4CAF50',
                          color: 'white',
                          border: 'none',
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '18px'
                        }}
                      >
                        {isPlaying1 ? '⏹️' : '🔊'}
                      </button>
                      <button
                        title="Recargar"
                        onClick={() => fetchVerses(currentReference, showNumbers)}
                        style={{
                          backgroundColor: '#2196F3',
                          color: 'white',
                          border: 'none',
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '18px'
                        }}
                      >
                        🔄
                      </button>
                    </div>
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
                        fetchVerses(currentReference, showNumbers);
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
                      title={isPlaying2 ? 'Detener' : 'Escuchar'}
                      onClick={() => speakVerse(verse2?.text || '', setIsPlaying2)}
                      style={{
                        backgroundColor: isPlaying2 ? '#ff4444' : '#4CAF50',
                        color: 'white',
                        border: 'none',
                        width: '40px',
                        height: '40px',
                        borderRadius: '50%',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '18px'
                      }}
                    >
                      {isPlaying2 ? '⏹️' : '🔊'}
                    </button>
                    <button
                      title="Recargar"
                      onClick={() => fetchVerses(currentReference, showNumbers)}
                      style={{
                        backgroundColor: '#2196F3',
                        color: 'white',
                        border: 'none',
                        width: '40px',
                        height: '40px',
                        borderRadius: '50%',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '18px',
                        marginLeft: '10px'
                      }}
                    >
                      🔄
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
                onChange={(e) => handleFieldChange(campo.id, e.target.value)}
                required={campo.esRequerido}
                style={(campo.nombreCampo.includes('Oración') || campo.nombreCampo.includes('Prioridades')) ? { backgroundColor: '#e0e0e0' } : {}}
              />
            ) : campo.tipoEntrada === 'AUDIO' ? (
              <div>
                <input
                  className="input"
                  type="text"
                  placeholder="URL del audio"
                  value={valores[campo.id]?.valorAudioUrl || ''}
                  onChange={(e) => handleFieldChange(campo.id, e.target.value, true)}
                />
                <input
                  className="input"
                  type="text"
                  placeholder="Transcripción"
                  value={valores[campo.id]?.valorTexto || ''}
                  onChange={(e) => handleFieldChange(campo.id, e.target.value)}
                />
              </div>
            ) : (
              <textarea
                className="input"
                value={valores[campo.id]?.valorTexto || ''}
                onChange={(e) => handleFieldChange(campo.id, e.target.value)}
                required={campo.esRequerido}
                rows={4}
              />
            )}
          </div>
        ))}

        {!isSaved && (
          <button className="btn" onClick={handleSave}>Guardar Entrada</button>
        )}
        {isSaved && !hasChanges && (
          <button className="btn" onClick={() => navigate('/')}>Cerrar</button>
        )}
        {isSaved && hasChanges && (
          <button className="btn" onClick={handleSave}>Actualizar</button>
        )}
      </div>
    </div>
  );
};

export default DailyEntry;