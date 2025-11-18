package com.diario_intimidad.controller;

import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.service.DiarioAnualService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

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
        Optional<DiarioAnual> optionalDiarioAnual = diarioAnualService.findById(id);
        if (optionalDiarioAnual.isPresent()) {
            DiarioAnual existingDiarioAnual = optionalDiarioAnual.get();

            // Actualizar solo campos no nulos
            if (diarioAnualDetails.getAnio() != null) {
                existingDiarioAnual.setAnio(diarioAnualDetails.getAnio());
            }
            if (diarioAnualDetails.getTitulo() != null) {
                existingDiarioAnual.setTitulo(diarioAnualDetails.getTitulo());
            }
            if (diarioAnualDetails.getPortadaUrl() != null) {
                existingDiarioAnual.setPortadaUrl(diarioAnualDetails.getPortadaUrl());
            }
            if (diarioAnualDetails.getLogoUrl() != null) {
                existingDiarioAnual.setLogoUrl(diarioAnualDetails.getLogoUrl());
            }
            if (diarioAnualDetails.getTemaPrincipal() != null) {
                existingDiarioAnual.setTemaPrincipal(diarioAnualDetails.getTemaPrincipal());
            }

            return ResponseEntity.ok(diarioAnualService.save(existingDiarioAnual));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDiarioAnual(@PathVariable Long id) {
        diarioAnualService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/upload")
    public ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("Archivo vacío");
            }
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String uniqueName = UUID.randomUUID().toString() + extension;
            Path uploadDir = Paths.get("uploads/images/");
            Files.createDirectories(uploadDir);
            Path filePath = uploadDir.resolve(uniqueName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            String relativeUrl = "/uploads/images/" + uniqueName;
            return ResponseEntity.ok(relativeUrl);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al subir el archivo");
        }
    }

}