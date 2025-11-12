package com.diario_intimidad.controller;

import com.diario_intimidad.entity.DiaMaestro;
import com.diario_intimidad.service.DiaMaestroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/dias-maestro")
@CrossOrigin(origins = "http://localhost:3005")
public class DiaMaestroController {

    @Autowired
    private DiaMaestroService diaMaestroService;

    @GetMapping
    public List<DiaMaestro> getAllDiasMaestro() {
        return diaMaestroService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<DiaMaestro> getDiaMaestroById(@PathVariable Long id) {
        Optional<DiaMaestro> diaMaestro = diaMaestroService.findById(id);
        return diaMaestro.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public DiaMaestro createDiaMaestro(@RequestBody DiaMaestro diaMaestro) {
        return diaMaestroService.save(diaMaestro);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DiaMaestro> updateDiaMaestro(@PathVariable Long id, @RequestBody DiaMaestro diaMaestroDetails) {
        Optional<DiaMaestro> diaMaestro = diaMaestroService.findById(id);
        if (diaMaestro.isPresent()) {
            diaMaestroDetails.setId(id);
            return ResponseEntity.ok(diaMaestroService.save(diaMaestroDetails));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDiaMaestro(@PathVariable Long id) {
        diaMaestroService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

}