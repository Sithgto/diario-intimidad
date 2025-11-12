package com.diario_intimidad.service;

import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.repository.DiarioAnualRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DiarioAnualService {

    @Autowired
    private DiarioAnualRepository diarioAnualRepository;

    public List<DiarioAnual> findAll() {
        return diarioAnualRepository.findAll();
    }

    public Optional<DiarioAnual> findById(Long id) {
        return diarioAnualRepository.findById(id);
    }

    public DiarioAnual save(DiarioAnual diarioAnual) {
        return diarioAnualRepository.save(diarioAnual);
    }

    public void deleteById(Long id) {
        diarioAnualRepository.deleteById(id);
    }

}