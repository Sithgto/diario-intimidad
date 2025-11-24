package com.diario_intimidad.controller;

import com.diario_intimidad.config.JwtUtil;
import com.diario_intimidad.dto.CalendarEntryResponse;
import com.diario_intimidad.dto.DailyEntryRequest;
import com.diario_intimidad.dto.DailyEntryResponse;
import com.diario_intimidad.entity.*;
import com.diario_intimidad.repository.CamposDiarioRepository;
import com.diario_intimidad.repository.DiarioAnualRepository;
import com.diario_intimidad.repository.EntradaDiariaRepository;
import com.diario_intimidad.repository.MesMaestroRepository;
import com.diario_intimidad.repository.DiaMaestroRepository;
import com.diario_intimidad.repository.UsuarioRepository;
import com.diario_intimidad.repository.ValoresCampoRepository;
import com.diario_intimidad.service.DailyEntryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
    private JwtUtil jwtUtil;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private CamposDiarioRepository camposDiarioRepository;

    @Autowired
    private EntradaDiariaRepository entradaDiariaRepository;

    @Autowired
    private ValoresCampoRepository valoresCampoRepository;

    @GetMapping("/diarios")
    public ResponseEntity<List<DiarioAnual>> getDiariosDisponibles() {
        List<DiarioAnual> diarios = diarioAnualRepository.findAll();
        return ResponseEntity.ok(diarios);
    }

    @GetMapping("/today")
    public ResponseEntity<CalendarEntryResponse> getTodayEntry(@RequestParam(required = false) Integer anio, @RequestParam(required = false) Integer mes, @RequestParam(required = false) Integer dia, Authentication authentication) {
        System.out.println("DailyEntryController.getTodayEntry called");
        logger.info("Parámetros recibidos: anio={}, mes={}, dia={}, usuario={}", anio, mes, dia, authentication != null ? authentication.getName() : "null");
        LocalDate fecha;
        if (anio != null && mes != null && dia != null) {
            fecha = LocalDate.of(anio, mes, dia);
        } else {
            fecha = LocalDate.now();
        }
        logger.info("Fecha construida: {}", fecha);

        Long userId = null;
        if (authentication != null) {
            Usuario usuario = (Usuario) authentication.getPrincipal();
            logger.info("Usuario autenticado: {}", usuario.getEmail());
            userId = usuario.getId();
            logger.info("UserId obtenido: {}", userId);
        } else {
            logger.warn("Authentication is null");
        }
        logger.info("Llamando al servicio getTodayData con fecha: {} y userId: {}", fecha, userId);

        CalendarEntryResponse response = dailyEntryService.getTodayData(fecha, userId);
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
    public ResponseEntity<List<EntradaDiaria>> getUserEntries(@RequestParam Integer anio, @RequestParam Integer mes, @AuthenticationPrincipal Usuario usuario) {
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }
        List<EntradaDiaria> entradas = dailyEntryService.getEntradasByUsuarioAndMes(usuario.getId(), anio, mes);
        return ResponseEntity.ok(entradas);
    }

    @GetMapping("/entry-values/{entryId}")
    public ResponseEntity<List<ValoresCampo>> getEntryValues(@PathVariable Long entryId, @AuthenticationPrincipal Usuario usuario) {
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }
        // Verificar que la entrada pertenece al usuario
        EntradaDiaria entrada = dailyEntryService.findEntradaById(entryId);
        if (entrada == null || !entrada.getUsuario().getId().equals(usuario.getId())) {
            return ResponseEntity.notFound().build();
        }
        List<ValoresCampo> valores = dailyEntryService.getValoresByEntrada(entryId);
        return ResponseEntity.ok(valores);
    }

    @PostMapping("/save")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> saveEntry(@RequestBody DailyEntryRequest request, @AuthenticationPrincipal Usuario usuario) {
        logger.info("saveEntry called for user: {}", usuario != null ? usuario.getEmail() : "null");
        if (usuario == null) {
            logger.warn("Usuario no autenticado");
            return ResponseEntity.status(401).body("No autenticado");
        }

        LocalDate fecha = request.getFecha() != null ? LocalDate.parse(request.getFecha()) : LocalDate.now();
        logger.info("Procesando guardado para usuario {} en fecha {}", usuario.getEmail(), fecha);

        try {
            // Obtener DiaMaestro para la fecha actual
            int anio = fecha.getYear();
            int mes = fecha.getMonthValue();
            int dia = fecha.getDayOfMonth();

            Optional<DiarioAnual> diarioOpt = diarioAnualRepository.findByAnio(anio);
            if (diarioOpt.isEmpty()) {
                logger.warn("Diario anual no encontrado para el año {}", anio);
                return ResponseEntity.badRequest().body("Diario anual no encontrado para el año " + anio);
            }
            DiarioAnual diario = diarioOpt.get();
            logger.info("Diario encontrado: {} (id: {})", diario.getTitulo(), diario.getId());

            Optional<MesMaestro> mesOpt = mesMaestroRepository.findByDiarioAnualIdAndMesNumero(diario.getId(), mes);
            if (mesOpt.isEmpty()) {
                logger.warn("Mes maestro no encontrado para diario {} mes {}", diario.getId(), mes);
                return ResponseEntity.badRequest().body("Mes maestro no encontrado para el mes " + mes);
            }
            MesMaestro mesMaestro = mesOpt.get();
            logger.info("MesMaestro encontrado: id {}", mesMaestro.getId());

            Optional<DiaMaestro> diaOpt = diaMaestroRepository.findByMesMaestroIdAndDiaNumero(mesMaestro.getId(), dia);
            if (diaOpt.isEmpty()) {
                logger.warn("Dia maestro no encontrado para mesMaestro {} dia {}", mesMaestro.getId(), dia);
                return ResponseEntity.badRequest().body("Dia maestro no encontrado para el día " + dia);
            }
            DiaMaestro diaMaestro = diaOpt.get();
            logger.info("DiaMaestro encontrado: id {}", diaMaestro.getId());

            // Verificar si ya existe una entrada para este usuario y diaMaestro
            logger.info("Validando existencia de EntradaDiaria: usuario={}, diaMaestro={}", usuario.getEmail(), diaMaestro.getId());
            Optional<EntradaDiaria> existingEntrada = entradaDiariaRepository.findByUsuarioAndDiaMaestro(usuario, diaMaestro);
            logger.info("Resultado de validación: entrada existente={}", existingEntrada.isPresent() ? "sí (id: " + existingEntrada.get().getId() + ")" : "no");

            EntradaDiaria entrada;

            if (existingEntrada.isPresent()) {
                logger.info("EntradaDiaria ya existe para usuario {} y diaMaestro {}, actualizando", usuario.getEmail(), diaMaestro.getId());
                entrada = existingEntrada.get();
                // Eliminar valores existentes para reemplazarlos
                List<ValoresCampo> existingValores = valoresCampoRepository.findByEntradaDiariaId(entrada.getId());
                logger.info("Encontrados {} ValoresCampo existentes para eliminar", existingValores.size());
                for (ValoresCampo vc : existingValores) {
                    valoresCampoRepository.delete(vc);
                    logger.info("Eliminado ValoresCampo id: {}", vc.getId());
                }
            } else {
                logger.info("Creando nueva EntradaDiaria para usuario {} y diaMaestro {}", usuario.getEmail(), diaMaestro.getId());
                entrada = new EntradaDiaria();
                entrada.setUsuario(usuario);
                entrada.setFechaEntrada(fecha);
                entrada.setDiario(diaMaestro.getMesMaestro().getDiarioAnual());
                entrada.setDiaMaestro(diaMaestro);
                logger.info("DiaMaestro asignado con id: {}", diaMaestro.getId());
            }

            entrada.setEstadoLlenado(BigDecimal.valueOf(100.0)); // Calcular basado en campos
            entrada.setCompletado(true);

            logger.info("Guardando EntradaDiaria en tabla entrada_diaria");
            EntradaDiaria savedEntrada = dailyEntryService.saveEntradaDiaria(entrada);
            logger.info("EntradaDiaria guardada/actualizada con id: {}", savedEntrada.getId());

            // Guardar ValoresCampo
            logger.info("Guardando {} ValoresCampo en tabla valores_campo", request.getValoresCampo().size());
            for (DailyEntryRequest.CampoValor cv : request.getValoresCampo()) {
                logger.info("Procesando CampoValor: campoDiarioId={}, valorTexto={}, valorAudioUrl={}",
                    cv.getCampoDiarioId(), cv.getValorTexto(), cv.getValorAudioUrl());
                ValoresCampo vc = new ValoresCampo();
                vc.setEntradaDiaria(savedEntrada);
                Optional<CamposDiario> campoOpt = camposDiarioRepository.findById(cv.getCampoDiarioId());
                if (campoOpt.isPresent()) {
                    vc.setCamposDiario(campoOpt.get());
                    logger.info("CampoDiario encontrado: {} (id: {})", campoOpt.get().getNombreCampo(), campoOpt.get().getId());
                } else {
                    logger.warn("Campo diario no encontrado: {}", cv.getCampoDiarioId());
                    return ResponseEntity.badRequest().body("Campo diario no encontrado: " + cv.getCampoDiarioId());
                }
                vc.setValorTexto(cv.getValorTexto());
                vc.setValorAudioUrl(cv.getValorAudioUrl());
                ValoresCampo savedVc = dailyEntryService.saveValoresCampo(vc);
                logger.info("ValoresCampo guardado con id: {}", savedVc.getId());
            }

            logger.info("saveEntry completado exitosamente para usuario {}", usuario.getEmail());
            return ResponseEntity.ok().build();

        } catch (Exception e) {
            logger.error("Error al guardar entrada diaria para usuario {}: {}", usuario.getEmail(), e.getMessage(), e);
            return ResponseEntity.status(500).body("Error interno del servidor al guardar la entrada diaria");
        }
    }
}