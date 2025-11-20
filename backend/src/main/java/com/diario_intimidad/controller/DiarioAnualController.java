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

            // Validar que las imágenes existen en el filesystem
            try {
                List<Path> files = Files.list(Paths.get(uploadDir, "images")).filter(Files::isRegularFile).collect(Collectors.toList());
                logger.info("Files in images directory after update: {}", files.stream().map(Path::getFileName).collect(Collectors.toList()));
            } catch (Exception e) {
                logger.error("Error listing files after update", e);
            }
            if (saved.getPortadaUrl() != null && saved.getPortadaUrl().startsWith("/uploads/images/")) {
                String fileName = saved.getPortadaUrl().substring("/uploads/images/".length());
                Path imagePath = Paths.get(uploadDir, "images", fileName);
                logger.info("Validating portada image: {} -> exists={}, isRegularFile={}, isReadable={}",
                    imagePath.toAbsolutePath(), Files.exists(imagePath), Files.isRegularFile(imagePath), Files.isReadable(imagePath));
            }
            if (saved.getLogoUrl() != null && saved.getLogoUrl().startsWith("/uploads/images/")) {
                String fileName = saved.getLogoUrl().substring("/uploads/images/".length());
                Path imagePath = Paths.get(uploadDir, "images", fileName);
                logger.info("Validating logo image: {} -> exists={}, isRegularFile={}, isReadable={}",
                    imagePath.toAbsolutePath(), Files.exists(imagePath), Files.isRegularFile(imagePath), Files.isReadable(imagePath));
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
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String fileName = UUID.randomUUID().toString() + extension;
            Path uploadDirPath = Paths.get(uploadDir, "images");
            logger.info("Upload directory path: {}", uploadDirPath.toAbsolutePath());
            Files.createDirectories(uploadDirPath);
            logger.info("Directories created: {}", Files.exists(uploadDirPath));
            Path filePath = uploadDirPath.resolve(fileName);
            logger.info("File path: {}", filePath.toAbsolutePath());
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            logger.info("File copied successfully. Exists: {}", Files.exists(filePath));
            try {
                List<Path> files = Files.list(Paths.get(uploadDir, "images")).filter(Files::isRegularFile).collect(Collectors.toList());
                logger.info("Files in images directory after upload: {}", files.stream().map(Path::getFileName).collect(Collectors.toList()));
            } catch (Exception e) {
                logger.error("Error listing files after upload", e);
            }
            String relativeUrl = "/uploads/images/" + fileName;
            logger.info("Returning URL: {}", relativeUrl);
            return ResponseEntity.ok(relativeUrl);
        } catch (Exception e) {
            logger.error("Error uploading file", e);
            return ResponseEntity.internalServerError().body("Error al subir el archivo");
        }
    }

}