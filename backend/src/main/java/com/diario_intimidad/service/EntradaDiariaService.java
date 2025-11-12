package com.diario_intimidad.service;

import com.diario_intimidad.entity.EntradaDiaria;
import com.diario_intimidad.repository.EntradaDiariaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class EntradaDiariaService {

    @Autowired
    private EntradaDiariaRepository entradaDiariaRepository;

    public List<EntradaDiaria> findAll() {
        return entradaDiariaRepository.findAll();
    }

    public Optional<EntradaDiaria> findById(Long id) {
        return entradaDiariaRepository.findById(id);
    }

    public EntradaDiaria save(EntradaDiaria entradaDiaria) {
        return entradaDiariaRepository.save(entradaDiaria);
    }

    public void deleteById(Long id) {
        entradaDiariaRepository.deleteById(id);
    }

    public List<EntradaDiaria> findByUsuarioIdAndDiarioId(Long usuarioId, Long diarioId) {
        return entradaDiariaRepository.findByUsuarioIdAndDiarioId(usuarioId, diarioId);
    }

}