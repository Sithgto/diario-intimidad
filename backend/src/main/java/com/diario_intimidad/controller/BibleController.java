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
        this.webClient = webClientBuilder.build();
    }

    @GetMapping("/verse/{reference}")
    public Mono<ResponseEntity<Map>> getVerse(
            @PathVariable String reference,
            @RequestParam(defaultValue = "rv1960") String translation) {

        // If reference contains ":", it's a Bible reference
        if (reference.contains(":")) {
            // For Spanish translations, use bible-api.deno.dev API
            if (translation.equals("rv1960") || translation.equals("rv1995") || translation.equals("nvi") || translation.equals("dhh") || translation.equals("pdt")) {
                String[] parts = parseReference(reference);
                if (parts != null) {
                    String bookCode = getBookCode(parts[0]);
                    String url = "https://bible-api.deno.dev/api/read/" + translation + "/" + bookCode + "/" + parts[1] + "/" + parts[2];
                    System.out.println("Calling Bible API: " + url);
                    return webClient.get()
                            .uri(url)
                            .retrieve()
                            .bodyToMono(Map.class)
                            .map(response -> {
                                // Debug: print response
                                System.out.println("API Response: " + response);
                                // Transform response to match expected format
                                String text = (String) response.get("text");
                                Map transformed = Map.of(
                                    "reference", reference,
                                    "text", text != null ? text : "Texto no encontrado",
                                    "translation_id", translation,
                                    "translation_name", getTranslationName(translation)
                                );
                                return ResponseEntity.ok(transformed);
                            })
                            .onErrorResume(e -> {
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
                // Use API for other translations
                String url = UriComponentsBuilder.fromUriString("https://bible-api.com")
                        .path("/{reference}")
                        .queryParam("translation", translation)
                        .buildAndExpand(reference)
                        .toUriString();

                return webClient.get()
                        .uri(url)
                        .retrieve()
                        .bodyToMono(Map.class)
                        .map(response -> ResponseEntity.ok(response))
                        .onErrorResume(e -> {
                            // Fallback a mock si falla
                            Map<String, Object> mockResponse = Map.of(
                                "reference", reference,
                                "text", "Error al obtener el versículo. Por favor, intenta con otra traducción.",
                                "translation_id", translation,
                                "translation_name", "Error"
                            );
                            return Mono.just(ResponseEntity.ok(mockResponse));
                        });
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
        // Map common book names to codes used by bible-api.deno.dev
        switch (bookName.toLowerCase()) {
            case "1 corintios": return "1co";
            case "juan": return "joh";
            case "salmos": return "psa";
            case "genesis": return "gen";
            case "éxodo": return "exo";
            case "levítico": return "lev";
            case "números": return "num";
            case "deuteronomio": return "deu";
            case "josué": return "jos";
            case "jueces": return "jdg";
            case "rut": return "rut";
            case "1 samuel": return "1sa";
            case "2 samuel": return "2sa";
            case "1 reyes": return "1ki";
            case "2 reyes": return "2ki";
            case "1 crónicas": return "1ch";
            case "2 crónicas": return "2ch";
            case "esdras": return "ezr";
            case "nehemías": return "neh";
            case "ester": return "est";
            case "job": return "job";
            case "proverbios": return "pro";
            case "eclesiastés": return "ecc";
            case "cantares": return "sng";
            case "isaías": return "isa";
            case "jeremías": return "jer";
            case "lamentaciones": return "lam";
            case "ezequiel": return "ezk";
            case "daniel": return "dan";
            case "oseas": return "hos";
            case "joel": return "jol";
            case "amós": return "amo";
            case "abdías": return "oba";
            case "jonás": return "jon";
            case "miqueas": return "mic";
            case "nahúm": return "nam";
            case "habacuc": return "hab";
            case "sofónías": return "zep";
            case "hageo": return "hag";
            case "zacarias": return "zec";
            case "malaquías": return "mal";
            case "mateo": return "mat";
            case "marcos": return "mrk";
            case "lucas": return "luk";
            case "hechos": return "act";
            case "romanos": return "rom";
            case "2 corintios": return "2co";
            case "gálatas": return "gal";
            case "efesios": return "eph";
            case "filipenses": return "php";
            case "colosenses": return "col";
            case "1 tesalonicenses": return "1th";
            case "2 tesalonicenses": return "2th";
            case "1 timoteo": return "1ti";
            case "2 timoteo": return "2ti";
            case "tito": return "tit";
            case "filemón": return "phm";
            case "hebreos": return "heb";
            case "santiago": return "jas";
            case "1 pedro": return "1pe";
            case "2 pedro": return "2pe";
            case "1 juan": return "1jn";
            case "2 juan": return "2jn";
            case "3 juan": return "3jn";
            case "judas": return "jud";
            case "apocalipsis": return "rev";
            default: return bookName.replace(" ", "").toLowerCase();
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