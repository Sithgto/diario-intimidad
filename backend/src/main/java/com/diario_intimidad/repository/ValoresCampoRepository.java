package com.diario_intimidad.repository;

import com.diario_intimidad.entity.ValoresCampo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ValoresCampoRepository extends JpaRepository<ValoresCampo, Long> {
}