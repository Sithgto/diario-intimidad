package com.diario_intimidad.controller;

import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.service.DiarioAnualService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/diarios-anuales")
@CrossOrigin(origins = "http://localhost:3005")
public class DiarioAnualController {

    private static final Logger logger = LoggerFactory.getLogger(DiarioAnualController.class);

    @Value("${app.upload.dir}")
    private String uploadDir;

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
            logger.info("Valores antes de la actualización: id={}, anio={}, titulo={}, nombrePortada={}, nombreLogo={}, temaPrincipal={}, status={}",
                existingDiarioAnual.getId(), existingDiarioAnual.getAnio(), existingDiarioAnual.getTitulo(),
                existingDiarioAnual.getNombrePortada(), existingDiarioAnual.getNombreLogo(), existingDiarioAnual.getTemaPrincipal(), existingDiarioAnual.getStatus());

            // Actualizar solo campos no nulos
            if (diarioAnualDetails.getAnio() != null) {
                existingDiarioAnual.setAnio(diarioAnualDetails.getAnio());
            }
            if (diarioAnualDetails.getTitulo() != null) {
                existingDiarioAnual.setTitulo(diarioAnualDetails.getTitulo());
            }
            if (diarioAnualDetails.getNombrePortada() != null) {
                existingDiarioAnual.setNombrePortada(diarioAnualDetails.getNombrePortada());
            }
            if (diarioAnualDetails.getNombreLogo() != null) {
                existingDiarioAnual.setNombreLogo(diarioAnualDetails.getNombreLogo());
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
            logger.info("Valores después de la actualización: id={}, anio={}, titulo={}, nombrePortada={}, nombreLogo={}, temaPrincipal={}, status={}",
                existingDiarioAnual.getId(), existingDiarioAnual.getAnio(), existingDiarioAnual.getTitulo(),
                existingDiarioAnual.getNombrePortada(), existingDiarioAnual.getNombreLogo(), existingDiarioAnual.getTemaPrincipal(), existingDiarioAnual.getStatus());

            DiarioAnual saved = diarioAnualService.save(existingDiarioAnual);

            // Confirmar que se guardó correctamente
            logger.info("Updated diario saved with id {} and status {}", saved.getId(), saved.getStatus());

            // Validar que las imágenes existen en el filesystem
            try {
                List<Path> files = Files.list(Paths.get(uploadDir, "images")).filter(Files::isRegularFile).collect(Collectors.toList());
                logger.info("Files in images directory after update: {}", files.stream().map(Path::getFileName).collect(Collectors.toList()));
            } catch (Exception e) {
                logger.error("Error listing files after update", e);
            }
            if (saved.getNombrePortada() != null) {
                Path imagePath = Paths.get(uploadDir, "images", saved.getNombrePortada());
                try {
                    long size = Files.size(imagePath);
                    logger.info("Validating portada image: {} -> size={} bytes", imagePath.toAbsolutePath(), size);
                } catch (Exception e) {
                    logger.error("Error validating portada image: {}", imagePath.toAbsolutePath(), e);
                }
            }
            if (saved.getNombreLogo() != null) {
                Path imagePath = Paths.get(uploadDir, "images", saved.getNombreLogo());
                try {
                    long size = Files.size(imagePath);
                    logger.info("Validating logo image: {} -> size={} bytes", imagePath.toAbsolutePath(), size);
                } catch (Exception e) {
                    logger.error("Error validating logo image: {}", imagePath.toAbsolutePath(), e);
                }
            }

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
            logger.info("Upload request received. Upload dir: {}", uploadDir);
            if (file.isEmpty()) {
                logger.warn("File is empty");
                return ResponseEntity.badRequest().body("Archivo vacío");
            }
            String originalFilename = file.getOriginalFilename();
            logger.info("Original filename: {}", originalFilename);
            String fileName = originalFilename != null ? originalFilename : "unnamed.jpg";
            Path uploadDirPath = Paths.get(uploadDir, "images");
            logger.info("Upload directory path: {}", uploadDirPath.toAbsolutePath());
            Files.createDirectories(uploadDirPath);
            logger.info("Directories created: {}", Files.exists(uploadDirPath));
            Path filePath = uploadDirPath.resolve(fileName);
            logger.info("File path: {}", filePath.toAbsolutePath());
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            try {
                long size = Files.size(filePath);
                logger.info("File copied successfully. Size: {} bytes", size);
                List<Path> files = Files.list(Paths.get(uploadDir, "images")).filter(Files::isRegularFile).collect(Collectors.toList());
                logger.info("Files in images directory after upload: {}", files.stream().map(Path::getFileName).collect(Collectors.toList()));
            } catch (Exception e) {
                logger.error("Error validating file after upload", e);
            }
            logger.info("Returning filename: {}", fileName);
            return ResponseEntity.ok(fileName);
        } catch (Exception e) {
            logger.error("Error uploading file", e);
            return ResponseEntity.internalServerError().body("Error al subir el archivo");
        }
    }

}