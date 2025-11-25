package com.diario_intimidad.controller;

import com.diario_intimidad.entity.MesMaestro;
import com.diario_intimidad.service.MesMaestroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/meses-maestro")
@CrossOrigin(origins = "http://localhost:3005")
public class MesMaestroController {

    @Autowired
    private MesMaestroService mesMaestroService;

    @GetMapping
    public List<MesMaestro> getAllMesesMaestro() {
        return mesMaestroService.findAll();
    }

    @GetMapping("/diario/{diarioId}")
    public List<MesMaestro> getMesesMaestroByDiarioAnual(@PathVariable Long diarioId) {
        return mesMaestroService.findByDiarioAnualId(diarioId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MesMaestro> getMesMaestroById(@PathVariable Long id) {
        Optional<MesMaestro> mesMaestro = mesMaestroService.findById(id);
        return mesMaestro.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public MesMaestro createMesMaestro(@RequestBody MesMaestro mesMaestro) {
        return mesMaestroService.save(mesMaestro);
    }

    @PutMapping("/{id}")
    public ResponseEntity<MesMaestro> updateMesMaestro(@PathVariable Long id, @RequestBody MesMaestro mesMaestroDetails) {
        Optional<MesMaestro> mesMaestro = mesMaestroService.findById(id);
        if (mesMaestro.isPresent()) {
            mesMaestroDetails.setId(id);
            return ResponseEntity.ok(mesMaestroService.save(mesMaestroDetails));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMesMaestro(@PathVariable Long id) {
        mesMaestroService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

}