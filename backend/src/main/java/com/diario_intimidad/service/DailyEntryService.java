package com.diario_intimidad.service;

import com.diario_intimidad.dto.CalendarEntryResponse;
import com.diario_intimidad.entity.*;
import com.diario_intimidad.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
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

    public CalendarEntryResponse getTodayData(LocalDate date) {
        Optional<DiaMaestro> diaMaestro = getDiaMaestroForDate(date.getYear(), date.getMonthValue(), date.getDayOfMonth());
        if (diaMaestro.isEmpty()) {
            return null;
        }

        DiarioAnual diarioAnual = diaMaestro.get().getMesMaestro().getDiarioAnual();

        List<CamposDiario> camposDiario = getCamposDiarioForDiario(diarioAnual.getId());

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
        if (versiculoReference == null) {
            versiculoReference = "";
        }
        response.setVersiculoDiario(versiculoReference); // Para compatibilidad
        response.setVersiculoReference(versiculoReference);
        response.setDiarioAnual(diarioAnual);
        response.setCamposDiario(camposDiario);

        return response;
    }
}