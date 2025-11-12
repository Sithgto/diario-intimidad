package com.diario_intimidad.controller;

import com.diario_intimidad.entity.EntradaDiaria;
import com.diario_intimidad.service.EntradaDiariaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/entradas-diarias")
@CrossOrigin(origins = "http://localhost:3005")
public class EntradaDiariaController {

    @Autowired
    private EntradaDiariaService entradaDiariaService;

    @GetMapping
    public List<EntradaDiaria> getAllEntradasDiarias() {
        return entradaDiariaService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<EntradaDiaria> getEntradaDiariaById(@PathVariable Long id) {
        Optional<EntradaDiaria> entradaDiaria = entradaDiariaService.findById(id);
        return entradaDiaria.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/usuario/{usuarioId}/diario/{diarioId}")
    public List<EntradaDiaria> getEntradasDiariasByUsuarioAndDiario(@PathVariable Long usuarioId, @PathVariable Long diarioId) {
        return entradaDiariaService.findByUsuarioIdAndDiarioId(usuarioId, diarioId);
    }

    @PostMapping
    public EntradaDiaria createEntradaDiaria(@RequestBody EntradaDiaria entradaDiaria) {
        return entradaDiariaService.save(entradaDiaria);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EntradaDiaria> updateEntradaDiaria(@PathVariable Long id, @RequestBody EntradaDiaria entradaDiariaDetails) {
        Optional<EntradaDiaria> entradaDiaria = entradaDiariaService.findById(id);
        if (entradaDiaria.isPresent()) {
            entradaDiariaDetails.setId(id);
            return ResponseEntity.ok(entradaDiariaService.save(entradaDiariaDetails));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEntradaDiaria(@PathVariable Long id) {
        entradaDiariaService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

}