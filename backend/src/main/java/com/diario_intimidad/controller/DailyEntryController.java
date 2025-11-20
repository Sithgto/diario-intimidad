package com.diario_intimidad.controller;

import com.diario_intimidad.dto.CalendarEntryResponse;
import com.diario_intimidad.dto.DailyEntryRequest;
import com.diario_intimidad.dto.DailyEntryResponse;
import com.diario_intimidad.entity.*;
import com.diario_intimidad.repository.CamposDiarioRepository;
import com.diario_intimidad.repository.DiarioAnualRepository;
import com.diario_intimidad.repository.MesMaestroRepository;
import com.diario_intimidad.repository.DiaMaestroRepository;
import com.diario_intimidad.service.DailyEntryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/api/daily-entry")
@CrossOrigin(origins = "http://localhost:3005")
public class DailyEntryController {

    private static final Logger logger = LoggerFactory.getLogger(DailyEntryController.class);

    @Autowired
    private DailyEntryService dailyEntryService;

    @Autowired
    private DiarioAnualRepository diarioAnualRepository;

    @Autowired
    private MesMaestroRepository mesMaestroRepository;

    @Autowired
    private DiaMaestroRepository diaMaestroRepository;

    @Autowired
    private CamposDiarioRepository camposDiarioRepository;

    @GetMapping("/diarios")
    public ResponseEntity<List<DiarioAnual>> getDiariosDisponibles() {
        List<DiarioAnual> diarios = diarioAnualRepository.findAll();
        return ResponseEntity.ok(diarios);
    }

    @GetMapping("/today")
    public ResponseEntity<CalendarEntryResponse> getTodayEntry(@RequestParam(required = false) Integer anio, @RequestParam(required = false) Integer mes, @RequestParam(required = false) Integer dia, Authentication authentication) {
        logger.info("Parámetros recibidos: anio={}, mes={}, dia={}, usuario={}", anio, mes, dia, authentication != null ? authentication.getName() : "null");
        LocalDate fecha;
        if (anio != null && mes != null && dia != null) {
            fecha = LocalDate.of(anio, mes, dia);
        } else {
            fecha = LocalDate.now();
        }
        logger.info("Fecha construida: {}", fecha);
        logger.info("Llamando al servicio getTodayData con fecha: {}", fecha);

        CalendarEntryResponse response = dailyEntryService.getTodayData(fecha);
        logger.info("Resultado del servicio getTodayData: {}", response != null ? "encontrado" : "null");
        if (response == null) {
            logger.info("Retornando 404 Not Found");
            return ResponseEntity.notFound().build();
        }

        logger.info("Respuesta completa: fecha={}, tipoDia={}, lecturaBiblica={}, versiculoDiario={}, diarioAnual={}",
            response.getFecha(), response.getTipoDia(), response.getLecturaBiblica(), response.getVersiculoDiario(),
            response.getDiarioAnual() != null ? response.getDiarioAnual().getTitulo() : "null");
        logger.info("Retornando 200 OK con respuesta");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user-entries")
    public ResponseEntity<List<EntradaDiaria>> getUserEntries(@RequestParam Integer anio, @RequestParam Integer mes, Authentication authentication) {
        Usuario usuario = (Usuario) authentication.getPrincipal();
        List<EntradaDiaria> entradas = dailyEntryService.getEntradasByUsuarioAndMes(usuario.getId(), anio, mes);
        return ResponseEntity.ok(entradas);
    }

    @GetMapping("/entry-values/{entryId}")
    public ResponseEntity<List<ValoresCampo>> getEntryValues(@PathVariable Long entryId, Authentication authentication) {
        Usuario usuario = (Usuario) authentication.getPrincipal();
        // Verificar que la entrada pertenece al usuario
        EntradaDiaria entrada = dailyEntryService.findEntradaById(entryId);
        if (entrada == null || !entrada.getUsuario().getId().equals(usuario.getId())) {
            return ResponseEntity.notFound().build();
        }
        List<ValoresCampo> valores = dailyEntryService.getValoresByEntrada(entryId);
        return ResponseEntity.ok(valores);
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveEntry(@RequestBody DailyEntryRequest request, Authentication authentication) {
        Usuario usuario = (Usuario) authentication.getPrincipal();

        // Crear EntradaDiaria
        EntradaDiaria entrada = new EntradaDiaria();
        entrada.setUsuario(usuario);
        LocalDate fecha = LocalDate.now();
        entrada.setFechaEntrada(fecha);

        // Obtener DiaMaestro para la fecha actual
        int anio = fecha.getYear();
        int mes = fecha.getMonthValue();
        int dia = fecha.getDayOfMonth();

        Optional<DiarioAnual> diarioOpt = diarioAnualRepository.findByAnio(anio);
        if (diarioOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Diario anual no encontrado para el año " + anio);
        }
        DiarioAnual diario = diarioOpt.get();

        Optional<MesMaestro> mesOpt = mesMaestroRepository.findByDiarioAnualIdAndMesNumero(diario.getId(), mes);
        if (mesOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Mes maestro no encontrado para el mes " + mes);
        }
        MesMaestro mesMaestro = mesOpt.get();

        Optional<DiaMaestro> diaOpt = diaMaestroRepository.findByMesMaestroIdAndDiaNumero(mesMaestro.getId(), dia);
        if (diaOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Dia maestro no encontrado para el día " + dia);
        }
        DiaMaestro diaMaestro = diaOpt.get();

        entrada.setDiario(diaMaestro.getMesMaestro().getDiarioAnual());
        entrada.setDiaMaestro(diaMaestro);

        entrada.setEstadoLlenado(BigDecimal.valueOf(100.0)); // Calcular basado en campos
        entrada.setCompletado(true);

        EntradaDiaria savedEntrada = dailyEntryService.saveEntradaDiaria(entrada);

        // Guardar ValoresCampo
        for (DailyEntryRequest.CampoValor cv : request.getValoresCampo()) {
            ValoresCampo vc = new ValoresCampo();
            vc.setEntradaDiaria(savedEntrada);
            Optional<CamposDiario> campoOpt = camposDiarioRepository.findById(cv.getCampoDiarioId());
            if (campoOpt.isPresent()) {
                vc.setCamposDiario(campoOpt.get());
            } else {
                return ResponseEntity.badRequest().body("Campo diario no encontrado: " + cv.getCampoDiarioId());
            }
            vc.setValorTexto(cv.getValorTexto());
            vc.setValorAudioUrl(cv.getValorAudioUrl());
            dailyEntryService.saveValoresCampo(vc);
        }

        return ResponseEntity.ok().build();
    }
}