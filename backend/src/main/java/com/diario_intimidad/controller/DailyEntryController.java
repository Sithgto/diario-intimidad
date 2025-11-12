package com.diario_intimidad.controller;

import com.diario_intimidad.dto.DailyEntryRequest;
import com.diario_intimidad.dto.DailyEntryResponse;
import com.diario_intimidad.entity.*;
import com.diario_intimidad.service.DailyEntryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/daily-entry")
@CrossOrigin(origins = "http://localhost:3005")
public class DailyEntryController {

    @Autowired
    private DailyEntryService dailyEntryService;

    @GetMapping("/today")
    public ResponseEntity<DailyEntryResponse> getTodayEntry(Authentication authentication) {
        Usuario usuario = (Usuario) authentication.getPrincipal();

        Optional<DiaMaestro> diaMaestro = dailyEntryService.getDiaMaestroForToday();
        if (diaMaestro.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DiarioAnual diarioAnual = diaMaestro.get().getMesMaestro().getDiarioAnual();

        List<CamposDiario> camposDiario = dailyEntryService.getCamposDiario();

        DailyEntryResponse response = new DailyEntryResponse();
        response.setFecha(LocalDate.now());
        response.setTipoDia(diaMaestro.get().getTipoDia().name());
        response.setLecturaBiblica(diaMaestro.get().getLecturaBiblica());
        response.setVersiculoDiario(diaMaestro.get().getVersiculoDiario());
        response.setDiarioAnual(diarioAnual);
        response.setCamposDiario(camposDiario);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveEntry(@RequestBody DailyEntryRequest request, Authentication authentication) {
        Usuario usuario = (Usuario) authentication.getPrincipal();

        // Crear EntradaDiaria
        EntradaDiaria entrada = new EntradaDiaria();
        entrada.setUsuario(usuario);
        entrada.setFechaEntrada(LocalDate.now());
        // Asumir diario_id = 1
        // entrada.setDiario(...);
        // entrada.setDiaMaestro(...);
        entrada.setEstadoLlenado(BigDecimal.valueOf(100.0)); // Calcular basado en campos
        entrada.setCompletado(true);

        EntradaDiaria savedEntrada = dailyEntryService.saveEntradaDiaria(entrada);

        // Guardar ValoresCampo
        for (DailyEntryRequest.CampoValor cv : request.getValoresCampo()) {
            ValoresCampo vc = new ValoresCampo();
            vc.setEntradaDiaria(savedEntrada);
            // vc.setCampoDiario(...);
            vc.setValorTexto(cv.getValorTexto());
            vc.setValorAudioUrl(cv.getValorAudioUrl());
            dailyEntryService.saveValoresCampo(vc);
        }

        return ResponseEntity.ok().build();
    }
}