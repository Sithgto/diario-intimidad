package com.diario_intimidad.repository;

import com.diario_intimidad.entity.DiaMaestro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DiaMaestroRepository extends JpaRepository<DiaMaestro, Long> {
    Optional<DiaMaestro> findByMesMaestroIdAndDiaNumero(Long mesMaestroId, Integer diaNumero);
    List<DiaMaestro> findByMesMaestro_DiarioAnual_Id(Long diarioId);
}