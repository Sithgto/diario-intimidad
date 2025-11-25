package com.diario_intimidad.service;

import com.diario_intimidad.entity.MesMaestro;
import com.diario_intimidad.repository.MesMaestroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class MesMaestroService {

    @Autowired
    private MesMaestroRepository mesMaestroRepository;

    public List<MesMaestro> findAll() {
        return mesMaestroRepository.findAll();
    }

    public List<MesMaestro> findByDiarioAnualId(Long diarioId) {
        return mesMaestroRepository.findByDiarioAnual_Id(diarioId);
    }

    public Optional<MesMaestro> findById(Long id) {
        return mesMaestroRepository.findById(id);
    }

    public MesMaestro save(MesMaestro mesMaestro) {
        return mesMaestroRepository.save(mesMaestro);
    }

    public void deleteById(Long id) {
        mesMaestroRepository.deleteById(id);
    }

}