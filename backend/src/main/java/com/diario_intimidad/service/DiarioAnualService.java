package com.diario_intimidad.service;

import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.repository.DiarioAnualRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DiarioAnualService {

    private static final Logger logger = LoggerFactory.getLogger(DiarioAnualService.class);

    @Autowired
    private DiarioAnualRepository diarioAnualRepository;

    public List<DiarioAnual> findAll() {
        logger.info("Finding all DiarioAnual entities");
        List<DiarioAnual> diarios = diarioAnualRepository.findAll();
        logger.info("Found {} DiarioAnual entities", diarios.size());
        return diarios;
    }

    public Optional<DiarioAnual> findById(Long id) {
        logger.info("Finding DiarioAnual by id: {}", id);
        Optional<DiarioAnual> diario = diarioAnualRepository.findById(id);
        if (diario.isPresent()) {
            logger.info("DiarioAnual found: id={}, anio={}", diario.get().getId(), diario.get().getAnio());
        } else {
            logger.warn("DiarioAnual not found for id: {}", id);
        }
        return diario;
    }

    public DiarioAnual save(DiarioAnual diarioAnual) {
        logger.info("Attempting to save DiarioAnual: id={}, anio={}, titulo={}", diarioAnual.getId(), diarioAnual.getAnio(), diarioAnual.getTitulo());
        try {
            DiarioAnual saved = diarioAnualRepository.save(diarioAnual);
            logger.info("Successfully saved DiarioAnual: id={}, anio={}", saved.getId(), saved.getAnio());
            return saved;
        } catch (Exception e) {
            logger.error("Error saving DiarioAnual: id={}, anio={}, error={}", diarioAnual.getId(), diarioAnual.getAnio(), e.getMessage(), e);
            throw e;
        }
    }

    public void deleteById(Long id) {
        logger.info("Deleting DiarioAnual by id: {}", id);
        diarioAnualRepository.deleteById(id);
        logger.info("Deleted DiarioAnual with id: {}", id);
    }

}