package com.diario_intimidad.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
@RequestMapping("/api/bible")
@CrossOrigin(origins = "http://localhost:3005")
public class BibleController {

    private final WebClient webClient;

    @Autowired
    public BibleController(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl("https://bible-api.com").build();
    }

    @GetMapping("/verse/{reference}")
    public Mono<ResponseEntity<Map>> getVerse(
            @PathVariable String reference,
            @RequestParam(defaultValue = "rvr1960") String translation) {

        // Respuesta mock para testing, ya que la API externa no soporta traducciones en español
        Map<String, Object> mockResponse = Map.of(
            "reference", reference,
            "text", "Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.",
            "translation_id", translation,
            "translation_name", "Reina Valera 1960"
        );

        return Mono.just(ResponseEntity.ok(mockResponse));
    }

    @GetMapping("/translations")
    public ResponseEntity<Map[]> getTranslations() {
        // Lista de traducciones disponibles en español
        Map[] translations = new Map[]{
            Map.of("id", "rvr1960", "name", "Reina Valera 1960", "language", "es"),
            Map.of("id", "rv", "name", "Reina Valera Antigua", "language", "es"),
            Map.of("id", "nvi", "name", "Nueva Versión Internacional", "language", "es"),
            Map.of("id", "lbla", "name", "La Biblia de las Américas", "language", "es"),
            Map.of("id", "kjv", "name", "King James Version", "language", "en"),
            Map.of("id", "esv", "name", "English Standard Version", "language", "en")
        };
        return ResponseEntity.ok(translations);
    }
}