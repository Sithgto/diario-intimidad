package com.diario_intimidad.controller;

import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.service.DiarioAnualService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
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

    private static final Logger logger = LoggerFactory.getLogger(DiarioAnualController.class);

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
        DiarioAnual saved = diarioAnualService.save(diarioAnual);
        logger.info("Saved diario: id={}, status={}", saved.getId(), saved.getStatus());
        return saved;
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DiarioAnual> updateDiarioAnual(@PathVariable Long id, @RequestBody DiarioAnual diarioAnualDetails) {
        Optional<DiarioAnual> optionalDiarioAnual = diarioAnualService.findById(id);
        if (optionalDiarioAnual.isPresent()) {
            DiarioAnual existingDiarioAnual = optionalDiarioAnual.get();

            // Log valores antes de la actualización
            logger.info("Valores antes de la actualización: id={}, anio={}, titulo={}, portadaUrl={}, logoUrl={}, temaPrincipal={}, status={}",
                existingDiarioAnual.getId(), existingDiarioAnual.getAnio(), existingDiarioAnual.getTitulo(),
                existingDiarioAnual.getPortadaUrl(), existingDiarioAnual.getLogoUrl(), existingDiarioAnual.getTemaPrincipal(), existingDiarioAnual.getStatus());

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
            if (diarioAnualDetails.getStatus() != null) {
                existingDiarioAnual.setStatus(diarioAnualDetails.getStatus());
            }

            // Log del estado de actualización
            logger.info("Updating diario {} with status {}", id, diarioAnualDetails.getStatus());

            // Log valores después de la actualización
            logger.info("Valores después de la actualización: id={}, anio={}, titulo={}, portadaUrl={}, logoUrl={}, temaPrincipal={}, status={}",
                existingDiarioAnual.getId(), existingDiarioAnual.getAnio(), existingDiarioAnual.getTitulo(),
                existingDiarioAnual.getPortadaUrl(), existingDiarioAnual.getLogoUrl(), existingDiarioAnual.getTemaPrincipal(), existingDiarioAnual.getStatus());

            DiarioAnual saved = diarioAnualService.save(existingDiarioAnual);

            // Confirmar que se guardó correctamente
            logger.info("Updated diario saved with id {} and status {}", saved.getId(), saved.getStatus());

            return ResponseEntity.ok(saved);
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
            String fileName = UUID.randomUUID().toString() + extension;
            Path uploadDir = Paths.get("uploads/images/");
            Files.createDirectories(uploadDir);
            Path filePath = uploadDir.resolve(fileName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            logger.info("File uploaded successfully: {}", fileName);
            String relativeUrl = "/uploads/images/" + fileName;
            logger.info("Returning path: /uploads/images/{}", fileName);
            return ResponseEntity.ok(relativeUrl);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al subir el archivo");
        }
    }

}