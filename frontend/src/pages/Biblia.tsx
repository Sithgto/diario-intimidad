import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { API_BASE_URL } from '../constants/api';

interface VerseData {
  reference: string;
  text: string;
  translation_id: string;
  translation_name: string;
}

interface Translation {
  id: string;
  name: string;
  language: string;
}

const Biblia: React.FC = () => {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [verse1, setVerse1] = useState<VerseData | null>(null);
  const [verse2, setVerse2] = useState<VerseData | null>(null);
  const [loading, setLoading] = useState(false);
  const [translations, setTranslations] = useState<Translation[]>([]);
  const [translation1, setTranslation1] = useState('rv1960');
  const [translation2, setTranslation2] = useState('nvi');
  const [isPlaying1, setIsPlaying1] = useState(false);
  const [isPlaying2, setIsPlaying2] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [showNumbers, setShowNumbers] = useState(false);
  const [showTtsSettings, setShowTtsSettings] = useState(false);
  // TTS configuration states
  const [voices, setVoices] = useState<SpeechSynthesisVoice[]>([]);
  const [selectedVoice, setSelectedVoice] = useState<string>('');
  const [ttsRate, setTtsRate] = useState<number>(1);
  const [ttsPitch, setTtsPitch] = useState<number>(1);
  const [ttsVolume, setTtsVolume] = useState<number>(1);

  useEffect(() => {
    fetchTranslations();
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
    if (verse1 || verse2) {
      searchVerse();
    }
  }, [showNumbers]);

  const fetchTranslations = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/api/bible/translations`);
      setTranslations(response.data);
    } catch (error) {
      console.error('Error fetching translations:', error);
      // Fallback a traducciones por defecto
      setTranslations([
        { id: 'rv1960', name: 'Reina Valera 1960', language: 'es' },
        { id: 'rv', name: 'Reina Valera Antigua', language: 'es' },
        { id: 'nvi', name: 'Nueva Versión Internacional', language: 'es' },
        { id: 'lbla', name: 'La Biblia de las Américas', language: 'es' },
        { id: 'kjv', name: 'King James Version', language: 'en' },
        { id: 'esv', name: 'English Standard Version', language: 'en' }
      ]);
    }
  };

  const searchVerse = async () => {
    if (!searchQuery.trim()) return;

    console.log('Searching for query:', searchQuery.trim());
    console.log('Translations:', translation1, translation2);
    console.log('Include numbers:', showNumbers);

    setLoading(true);
    setErrorMessage('');
    try {
      const [response1, response2] = await Promise.all([
        axios.get(`${API_BASE_URL}/api/bible/verse/${searchQuery.trim()}`, {
          params: { translation: translation1, includeNumbers: showNumbers }
        }),
        axios.get(`${API_BASE_URL}/api/bible/verse/${searchQuery.trim()}`, {
          params: { translation: translation2, includeNumbers: showNumbers }
        })
      ]);
      console.log('Response1:', response1.data);
      console.log('Response2:', response2.data);
      setVerse1(response1.data);
      setVerse2(response2.data);
    } catch (error) {
      console.error('Error fetching verse:', error);
      setErrorMessage('Versículo no encontrado. Intenta con un formato como "Juan 3:16"');
    } finally {
      setLoading(false);
    }
  };

  const speakVerse = (text: string, translation: string, setPlaying: (playing: boolean) => void, isPlaying: boolean) => {
    if ('speechSynthesis' in window) {
      if (isPlaying) {
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
          utterance.lang = translation.startsWith('rv') || translation.startsWith('nvi') ||
                          translation.startsWith('lbla') || translation.startsWith('dhh') ||
                          translation.startsWith('pdt') ? 'es-ES' : 'en-US';
        }
      } else {
        utterance.lang = translation.startsWith('rv') || translation.startsWith('nvi') ||
                        translation.startsWith('lbla') || translation.startsWith('dhh') ||
                        translation.startsWith('pdt') ? 'es-ES' : 'en-US';
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

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      searchVerse();
    }
  };

  return (
    <div className="app-container">
      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2>📖 Biblia</h2>
          <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
            {(verse1 || verse2) && (
              <button
                className="btn"
                onClick={() => setShowTtsSettings(!showTtsSettings)}
                style={{ fontSize: '14px', padding: '5px 10px' }}
              >
                {showTtsSettings ? 'Ocultar Voz' : 'Configurar Voz'}
              </button>
            )}
            <button
              className="btn"
              onClick={() => navigate('/')}
              style={{ fontSize: '18px', padding: '5px 10px' }}
            >
              ✕
            </button>
          </div>
        </div>

        <div style={{ marginBottom: '10px' }}>
          <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
            <input
              className="input"
              type="text"
              placeholder="Buscar versículo (ej: Juan 3:16)"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyPress={handleKeyPress}
              style={{ flex: 1 }}
            />
            <button className="btn" onClick={searchVerse} disabled={loading} style={{ padding: '8px 16px', fontSize: '14px' }}>
              {loading ? 'Buscando...' : 'Buscar'}
            </button>
          </div>
          {errorMessage && <p style={{color: 'red', marginTop: '10px'}}>{errorMessage}</p>}
        </div>

        {(verse1 || verse2) && (
          <>
            <h3>{verse1?.reference || verse2?.reference}</h3>
            <div style={{ display: 'flex', gap: '20px', marginTop: '15px' }}>
              {/* Versión 1 */}
              <div style={{ flex: 1, padding: '15px', border: '1px solid #ddd', borderRadius: '8px', backgroundColor: '#f9f9f9' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                  <select
                    value={translation1}
                    onChange={(e) => {
                      setTranslation1(e.target.value);
                      // Re-fetch if verse1 exists
                      if (verse1) {
                        searchVerse();
                      }
                    }}
                    style={{ padding: '5px', borderRadius: '4px' }}
                  >
                    {translations.map(t => (
                      <option key={t.id} value={t.id}>
                        {t.name}
                      </option>
                    ))}
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
                      onClick={() => speakVerse(verse1?.text || '', translation1, setIsPlaying1, isPlaying1)}
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
                      onClick={() => searchVerse()}
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
                      // Re-fetch if verse2 exists
                      if (verse2) {
                        searchVerse();
                      }
                    }}
                    style={{ padding: '5px', borderRadius: '4px' }}
                  >
                    {translations.map(t => (
                      <option key={t.id} value={t.id}>
                        {t.name}
                      </option>
                    ))}
                  </select>
                  <div style={{ display: 'flex', gap: '10px' }}>
                    <button
                      title={isPlaying2 ? 'Detener' : 'Escuchar'}
                      onClick={() => speakVerse(verse2?.text || '', translation2, setIsPlaying2, isPlaying2)}
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
                      onClick={() => searchVerse()}
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

        <div style={{ marginTop: '30px', padding: '20px', backgroundColor: '#f0f8ff', borderRadius: '8px' }}>
          <h4>💡 Consejos de búsqueda:</h4>
          <ul style={{ margin: 0, paddingLeft: '20px' }}>
            <li>Usa el formato: Libro Capítulo:Versículo (ej: Génesis 1:1)</li>
            <li>Puedes buscar rangos: Juan 3:16-20</li>
            <li>Libros completos: Juan 3</li>
            <li>Múltiples versículos: Juan 3:16,17,18</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default Biblia;