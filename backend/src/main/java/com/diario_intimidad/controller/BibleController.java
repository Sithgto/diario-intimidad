package com.diario_intimidad.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bible")
@CrossOrigin(origins = "http://localhost:3005")
public class BibleController {

    private final WebClient webClient;

    @Autowired
    public BibleController(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.build();
    }

    @GetMapping("/verse/{reference}")
    public Mono<ResponseEntity<Map>> getVerse(
            @PathVariable String reference,
            @RequestParam(defaultValue = "rv1960") String translation,
            @RequestParam(defaultValue = "true") boolean includeNumbers) {

        System.out.println("Received reference: " + reference + ", translation: " + translation);

        // If reference contains ":", it's a Bible reference
        if (reference.contains(":")) {
            // Use bible-api.deno.dev API for all translations
            String[] parts = parseReference(reference);
            if (parts != null) {
                String bookCode = getBookCode(parts[0]);
                String url = "https://bible-api.deno.dev/api/read/" + translation + "/" + bookCode + "/" + parts[1] + "/" + parts[2];
                System.out.println("Calling Bible API: " + url);
                return webClient.get()
                        .uri(url)
                        .retrieve()
                        .bodyToMono(List.class)
                        .map(response -> {
                             // Debug: print response
                             System.out.println("API Response: " + response);
                             // Response is a list of verse objects
                             List<Map<String, Object>> verses = (List<Map<String, Object>>) response;
                             StringBuilder textBuilder = new StringBuilder();
                             if (verses != null) {
                                 for (Map<String, Object> verse : verses) {
                                     Integer number = (Integer) verse.get("number");
                                     String verseText = (String) verse.get("verse");
                                     if (verseText != null) {
                                         if (includeNumbers && number != null) {
                                             textBuilder.append(number).append(" ").append(verseText).append(" ");
                                         } else {
                                             textBuilder.append(verseText).append(" ");
                                         }
                                     }
                                 }
                             }
                             String text = textBuilder.toString().trim();
                             Map transformed = Map.of(
                                 "reference", reference,
                                 "text", !text.isEmpty() ? text : "Texto no encontrado",
                                 "translation_id", translation,
                                 "translation_name", getTranslationName(translation)
                             );
                             return ResponseEntity.ok(transformed);
                         })
                         .onErrorResume(e -> {
                             // Log the error
                             System.err.println("Error calling Bible API: " + e.getMessage());
                             // Fallback to mock
                             String fallbackText = getBibleText(reference, translation);
                             Map mockResponse = Map.of(
                                 "reference", reference,
                                 "text", fallbackText,
                                 "translation_id", translation,
                                 "translation_name", getTranslationName(translation)
                             );
                             return Mono.just(ResponseEntity.ok(mockResponse));
                         });
            } else {
                // Fallback to mock
                String text = getBibleText(reference, translation);
                Map mockResponse = Map.of(
                    "reference", reference,
                    "text", text,
                    "translation_id", translation,
                    "translation_name", getTranslationName(translation)
                );
                return Mono.just(ResponseEntity.ok(mockResponse));
            }
        } else {
            // If no ":", it's reading text, return as mock
            Map<String, Object> mockResponse = Map.of(
                "reference", "Lectura Bíblica",
                "text", reference,
                "translation_id", "es",
                "translation_name", "Lectura Diaria"
            );
            return Mono.just(ResponseEntity.ok(mockResponse));
        }
    }

    private String getTranslationName(String id) {
        switch (id) {
            case "rv1960": return "Reina Valera 1960";
            case "rv1995": return "Reina Valera 1995";
            case "nvi": return "Nueva version internacional";
            case "dhh": return "Dios habla hoy";
            case "pdt": return "Palabra de Dios para todos";
            case "kjv": return "King James Version";
            default: return "Desconocida";
        }
    }

    private String[] parseReference(String reference) {
        // Parse "Book Chapter:Verse" or "Book Chapter:Verse-Verse" to ["Book", "Chapter", "Verse"]
        int lastSpace = reference.lastIndexOf(" ");
        if (lastSpace == -1) return null;
        String book = reference.substring(0, lastSpace);
        String chapterVerse = reference.substring(lastSpace + 1);
        String[] cv = chapterVerse.split(":");
        if (cv.length == 2) {
            String verse = cv[1]; // Include range if present, e.g., "24-27"
            return new String[]{book, cv[0], verse};
        }
        return null;
    }

    private String getBookCode(String bookName) {
        // Map book names to the exact names used by bible-api.deno.dev
        switch (bookName.toLowerCase()) {
            case "génesis": return "genesis";
            case "éxodo": return "exodo";
            case "levítico": return "levitico";
            case "números": return "numeros";
            case "deuteronomio": return "deuteronomio";
            case "josué": return "josue";
            case "jueces": return "jueces";
            case "rut": return "rut";
            case "1 samuel": return "1-samuel";
            case "2 samuel": return "2-samuel";
            case "1 reyes": return "1-reyes";
            case "2 reyes": return "2-reyes";
            case "1 crónicas": return "1-cronicas";
            case "2 crónicas": return "2-cronicas";
            case "esdras": return "esdras";
            case "nehemías": return "nehemias";
            case "ester": return "ester";
            case "job": return "job";
            case "salmos": return "salmos";
            case "proverbios": return "proverbios";
            case "eclesiastés": return "eclesiastes";
            case "cantares": return "cantares";
            case "isaías": return "isaias";
            case "jeremías": return "jeremias";
            case "lamentaciones": return "lamentaciones";
            case "ezequiel": return "ezequiel";
            case "daniel": return "daniel";
            case "oseas": return "oseas";
            case "joel": return "joel";
            case "amós": return "amos";
            case "abdías": return "abdias";
            case "jonás": return "jonas";
            case "miqueas": return "miqueas";
            case "nahúm": return "nahum";
            case "habacuc": return "habacuc";
            case "sofónías": return "sofonias";
            case "hageo": return "hageo";
            case "zacarias": return "zacarias";
            case "malaquías": return "malaquias";
            case "mateo": return "mateo";
            case "marcos": return "marcos";
            case "lucas": return "lucas";
            case "juan": return "juan";
            case "hechos": return "hechos";
            case "romanos": return "romanos";
            case "1 corintios": return "1-corintios";
            case "2 corintios": return "2-corintios";
            case "gálatas": return "galatas";
            case "efesios": return "efesios";
            case "filipenses": return "filipenses";
            case "colosenses": return "colosenses";
            case "1 tesalonicenses": return "1-tesalonicenses";
            case "2 tesalonicenses": return "2-tesalonicenses";
            case "1 timoteo": return "1-timoteo";
            case "2 timoteo": return "2-timoteo";
            case "tito": return "tito";
            case "filemón": return "filemon";
            case "hebreos": return "hebreos";
            case "santiago": return "santiago";
            case "1 pedro": return "1-pedro";
            case "2 pedro": return "2-pedro";
            case "1 juan": return "1-juan";
            case "2 juan": return "2-juan";
            case "3 juan": return "3-juan";
            case "judas": return "judas";
            case "apocalipsis": return "apocalipsis";
            default: return bookName.replace(" ", "-").toLowerCase();
        }
    }

    private String getBibleText(String reference, String translation) {
        // Mock with real Bible texts for known references
        if (reference.equals("Juan 3:16")) {
            return "Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.";
        } else if (reference.equals("Salmos 23:1")) {
            return "Jehová es mi pastor; nada me faltará.";
        } else if (reference.equals("1 Corintios 9:24-27")) {
            return "24 ¿No sabéis que los que corren en el estadio, todos a la verdad corren, mas uno solo lleva el premio? Corred de tal manera que lo obtengáis. 25 Todo aquel que lucha, de todo se abstiene; ellos, a la verdad, para recibir una corona corruptible; mas nosotros, una incorruptible. 26 Así que, yo de esta manera corro, no como a cosa incierta; de esta manera peleo, no como quien golpea el aire; 27 sino que golpeo mi cuerpo, y lo pongo en servidumbre, no sea que habiendo predicado a otros, yo mismo venga a ser reprobado.";
        } else {
            return "Texto bíblico para " + reference + " en traducción " + getTranslationName(translation) + ".";
        }
    }

    @GetMapping("/translations")
    public ResponseEntity<Map[]> getTranslations() {
        // Lista de traducciones disponibles según la API
        Map[] translations = new Map[]{
            Map.of("name", "Reina Valera 1960", "language", "es", "id", "rv1960"),
            Map.of("name", "Reina Valera 1995", "language", "es", "id", "rv1995"),
            Map.of("name", "Nueva version internacional", "language", "es", "id", "nvi"),
            Map.of("name", "Dios habla hoy", "language", "es", "id", "dhh"),
            Map.of("name", "Palabra de Dios para todos", "language", "es", "id", "pdt"),
            Map.of("name", "King James Version", "language", "en", "id", "kjv")
        };
        return ResponseEntity.ok(translations);
    }
}