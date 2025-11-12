package com.diario_intimidad.controller;

import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.service.DiarioAnualService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/diarios-anuales")
@CrossOrigin(origins = "http://localhost:3005")
public class DiarioAnualController {

    @Autowired
    private DiarioAnualService diarioAnualService;

    @GetMapping
    public List<DiarioAnual> getAllDiariosAnuales() {
        return diarioAnualService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<DiarioAnual> getDiarioAnualById(@PathVariable Long id) {
        Optional<DiarioAnual> diarioAnual = diarioAnualService.findById(id);
        return diarioAnual.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public DiarioAnual createDiarioAnual(@RequestBody DiarioAnual diarioAnual) {
        return diarioAnualService.save(diarioAnual);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DiarioAnual> updateDiarioAnual(@PathVariable Long id, @RequestBody DiarioAnual diarioAnualDetails) {
        Optional<DiarioAnual> diarioAnual = diarioAnualService.findById(id);
        if (diarioAnual.isPresent()) {
            diarioAnualDetails.setId(id);
            return ResponseEntity.ok(diarioAnualService.save(diarioAnualDetails));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDiarioAnual(@PathVariable Long id) {
        diarioAnualService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

}