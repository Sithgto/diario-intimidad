package com.diario_intimidad.service;

import com.diario_intimidad.entity.DiaMaestro;
import com.diario_intimidad.repository.DiaMaestroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DiaMaestroService {

    @Autowired
    private DiaMaestroRepository diaMaestroRepository;

    public List<DiaMaestro> findAll() {
        return diaMaestroRepository.findAll();
    }

    public List<DiaMaestro> findByDiarioAnualId(Long diarioId) {
        return diaMaestroRepository.findByMesMaestro_DiarioAnual_Id(diarioId);
    }

    public Optional<DiaMaestro> findById(Long id) {
        return diaMaestroRepository.findById(id);
    }

    public DiaMaestro save(DiaMaestro diaMaestro) {
        return diaMaestroRepository.save(diaMaestro);
    }

    public void deleteById(Long id) {
        diaMaestroRepository.deleteById(id);
    }

}