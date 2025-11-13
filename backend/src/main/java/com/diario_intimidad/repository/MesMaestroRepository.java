package com.diario_intimidad.repository;

import com.diario_intimidad.entity.MesMaestro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MesMaestroRepository extends JpaRepository<MesMaestro, Long> {
    Optional<MesMaestro> findByDiarioAnualIdAndMesNumero(Long diarioAnualId, Integer mesNumero);
}