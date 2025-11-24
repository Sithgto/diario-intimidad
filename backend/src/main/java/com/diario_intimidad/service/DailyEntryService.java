package com.diario_intimidad.service;

import com.diario_intimidad.dto.CalendarEntryResponse;
import com.diario_intimidad.entity.*;
import com.diario_intimidad.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class DailyEntryService {

    private static final Logger logger = LoggerFactory.getLogger(DailyEntryService.class);

    @Autowired
    private DiaMaestroRepository diaMaestroRepository;

    @Autowired
    private DiarioAnualRepository diarioAnualRepository;

    @Autowired
    private CamposDiarioRepository camposDiarioRepository;

    @Autowired
    private EntradaDiariaRepository entradaDiariaRepository;

    @Autowired
    private ValoresCampoRepository valoresCampoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private MesMaestroRepository mesMaestroRepository;

    public Optional<DiaMaestro> getDiaMaestroForToday() {
        LocalDate today = LocalDate.now();
        return getDiaMaestroForDate(today.getYear(), today.getMonthValue(), today.getDayOfMonth());
    }

    public Optional<DiaMaestro> getDiaMaestroForDate(int anio, int mes, int dia) {
        logger.info("Buscando DiaMaestro para anio={}, mes={}, dia={}", anio, mes, dia);
        // Buscar el diario anual del año especificado
        Optional<DiarioAnual> diario = diarioAnualRepository.findByAnio(anio);
        logger.info("Diario encontrado: {}", diario.isPresent() ? diario.get().getId() : "ninguno");
        if (diario.isEmpty()) return Optional.empty();

        // Buscar el mes maestro del diario y mes especificado
        Optional<MesMaestro> mesMaestro = mesMaestroRepository.findByDiarioAnualIdAndMesNumero(diario.get().getId(), mes);
        logger.info("MesMaestro encontrado: {}", mesMaestro.isPresent() ? mesMaestro.get().getId() : "ninguno");
        if (mesMaestro.isEmpty()) return Optional.empty();

        // Buscar el día maestro del mes y día especificado
        Optional<DiaMaestro> diaMaestro = diaMaestroRepository.findByMesMaestroIdAndDiaNumero(mesMaestro.get().getId(), dia);
        logger.info("DiaMaestro encontrado: {}", diaMaestro.isPresent() ? diaMaestro.get().getId() : "ninguno");
        return diaMaestro;
    }

    public List<CamposDiario> getCamposDiario() {
        // Asumir diario_id = 1
        return camposDiarioRepository.findByDiarioAnualIdOrderByOrdenAsc(1L);
    }

    public List<CamposDiario> getCamposDiarioForDiario(Long diarioId) {
        return camposDiarioRepository.findByDiarioAnualIdOrderByOrdenAsc(diarioId);
    }

    public EntradaDiaria saveEntradaDiaria(EntradaDiaria entrada) {
        return entradaDiariaRepository.save(entrada);
    }

    public ValoresCampo saveValoresCampo(ValoresCampo valoresCampo) {
        return valoresCampoRepository.save(valoresCampo);
    }

    public EntradaDiaria findEntradaById(Long id) {
        return entradaDiariaRepository.findById(id).orElse(null);
    }

    public List<ValoresCampo> getValoresByEntrada(Long entradaId) {
        return valoresCampoRepository.findByEntradaDiariaId(entradaId);
    }

    public List<EntradaDiaria> getEntradasByUsuarioAndMes(Long usuarioId, Integer anio, Integer mes) {
        LocalDate start = LocalDate.of(anio, mes, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());
        return entradaDiariaRepository.findByUsuarioIdAndFechaEntradaBetween(usuarioId, start, end);
    }

    public CalendarEntryResponse getTodayData(LocalDate date, Long userId) {
        System.out.println("DailyEntryService.getTodayData called with date: " + date + ", userId: " + userId);
        logger.info("getTodayData called with date: {}, userId: {}", date, userId);

        Optional<DiaMaestro> diaMaestro = getDiaMaestroForDate(date.getYear(), date.getMonthValue(), date.getDayOfMonth());
        if (diaMaestro.isEmpty()) {
            logger.warn("No DiaMaestro found for date: {}, showing default verse", date);
            // Para fechas sin DiaMaestro, devolver response con versículo por defecto
            CalendarEntryResponse response = new CalendarEntryResponse();
            response.setFecha(date);
            response.setTipoDia("NORMAL");
            response.setLecturaBiblica(null);
            response.setVersiculoDiario("Juan 3:16");
            response.setVersiculoReference("Juan 3:16");
            response.setDiarioAnual(null);
            response.setCamposDiario(new ArrayList<>()); // vacío
            response.setValoresCampo(null);
            return response;
        }
        logger.info("DiaMaestro found: {}", diaMaestro.get().getId());

        DiarioAnual diarioAnual = diaMaestro.get().getMesMaestro().getDiarioAnual();
        logger.info("DiarioAnual: {}", diarioAnual.getTitulo());

        List<CamposDiario> camposDiario = getCamposDiarioForDiario(diarioAnual.getId());
        logger.info("CamposDiario count: {}", camposDiario.size());

        CalendarEntryResponse response = new CalendarEntryResponse();
        response.setFecha(date);
        response.setTipoDia(diaMaestro.get().getTipoDia().name());
        response.setLecturaBiblica(diaMaestro.get().getLecturaBiblica());
        String versiculoReference;
        String tipoDia = diaMaestro.get().getTipoDia().name();
        if (tipoDia.equals("NORMAL")) {
            versiculoReference = diaMaestro.get().getLecturaBiblica();
        } else if (tipoDia.equals("DOMINGO")) {
            versiculoReference = diaMaestro.get().getVersiculoDiario();
        } else {
            versiculoReference = diaMaestro.get().getVersiculoDiario();
        }
        if (versiculoReference == null || versiculoReference.isEmpty()) {
            versiculoReference = "Juan 3:16";
        }
        response.setVersiculoDiario(versiculoReference); // Para compatibilidad
        response.setVersiculoReference(versiculoReference);
        response.setDiarioAnual(diarioAnual);
        response.setCamposDiario(camposDiarioRepository.findByDiarioAnualIdOrderByOrdenAsc(diarioAnual.getId()));
        logger.info("CamposDiario set: {}", response.getCamposDiario().size());

        // Load existing valores if any
        if (userId != null && diaMaestro.isPresent()) {
            // Find existing entry by usuario and diaMaestro to ensure uniqueness
            Usuario usuario = usuarioRepository.findById(userId).orElse(null);
            if (usuario != null) {
                Optional<EntradaDiaria> existing = entradaDiariaRepository.findByUsuarioAndDiaMaestro(usuario, diaMaestro.get());
                if (existing.isPresent()) {
                    List<ValoresCampo> valores = valoresCampoRepository.findByEntradaDiariaId(existing.get().getId());
                    response.setValoresCampo(valores);
                    logger.info("ValoresCampo loaded: {}", valores.size());
                } else {
                    logger.info("No existing EntradaDiaria for userId: {}, diaMaestro: {}", userId, diaMaestro.get().getId());
                }
            } else {
                logger.warn("Usuario not found for userId: {}", userId);
            }
        } else {
            logger.warn("userId is null or diaMaestro not present");
        }

        logger.info("Response ready: camposDiario={}, valoresCampo={}", response.getCamposDiario().size(), response.getValoresCampo() != null ? response.getValoresCampo().size() : 0);
        return response;
    }
}