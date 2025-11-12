package com.diario_intimidad.repository;

import com.diario_intimidad.entity.DiaMaestro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DiaMaestroRepository extends JpaRepository<DiaMaestro, Long> {

}