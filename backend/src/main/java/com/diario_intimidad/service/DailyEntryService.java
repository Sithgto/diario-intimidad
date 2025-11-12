package com.diario_intimidad.service;

import com.diario_intimidad.entity.*;
import com.diario_intimidad.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class DailyEntryService {

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

    public Optional<DiaMaestro> getDiaMaestroForToday() {
        // Asumir que hay un diario anual activo, por simplicidad tomar el primero
        Optional<DiarioAnual> diario = diarioAnualRepository.findAll().stream().findFirst();
        if (diario.isEmpty()) return Optional.empty();

        LocalDate today = LocalDate.now();
        // Asumir que mes_id corresponde al mes, dia_numero al día
        int mes = today.getMonthValue();
        int dia = today.getDayOfMonth();

        return diaMaestroRepository.findByMesMaestroIdAndDiaNumero((long) mes, dia);
    }

    public List<CamposDiario> getCamposDiario() {
        // Asumir diario_id = 1
        return camposDiarioRepository.findByDiarioAnualId(1L);
    }

    public EntradaDiaria saveEntradaDiaria(EntradaDiaria entrada) {
        return entradaDiariaRepository.save(entrada);
    }

    public ValoresCampo saveValoresCampo(ValoresCampo valoresCampo) {
        return valoresCampoRepository.save(valoresCampo);
    }
}