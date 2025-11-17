package com.diario_intimidad.repository;

import com.diario_intimidad.entity.CamposDiario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CamposDiarioRepository extends JpaRepository<CamposDiario, Long> {
    List<CamposDiario> findByDiarioAnualIdOrderByOrdenAsc(Long diarioAnualId);
}