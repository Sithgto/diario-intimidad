package com.diario_intimidad.repository;

import com.diario_intimidad.entity.DiarioAnual;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DiarioAnualRepository extends JpaRepository<DiarioAnual, Long> {
    Optional<DiarioAnual> findByAnio(Integer anio);
}