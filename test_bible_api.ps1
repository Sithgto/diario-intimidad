# Lista de libros basada en los datos proporcionados
$books = @(
  "genesis",
  "exodo",
  "levitico",
  "numeros",
  "deuteronomio",
  "josue",
  "jueces",
  "rut",
  "1-samuel",
  "2-samuel",
  "1-reyes",
  "2-reyes",
  "1-cronicas",
  "2-cronicas",
  "esdras",
  "nehemias",
  "ester",
  "job",
  "salmos",
  "proverbios",
  "eclesiastes",
  "cantares",
  "isaias",
  "jeremias",
  "lamentaciones",
  "ezequiel",
  "daniel",
  "oseas",
  "joel",
  "amos",
  "abdias",
  "jonas",
  "miqueas",
  "nahum",
  "habacuc",
  "sofonias",
  "hageo",
  "zacarias",
  "malaquias",
  "mateo",
  "marcos",
  "lucas",
  "juan",
  "hechos",
  "romanos",
  "1-corintios",
  "2-corintios",
  "galatas",
  "efesios",
  "filipenses",
  "colosenses",
  "1-tesalonicenses",
  "2-tesalonicenses",
  "1-timoteo",
  "2-timoteo",
  "tito",
  "filemon",
  "hebreos",
  "santiago",
  "1-pedro",
  "2-pedro",
  "1-juan",
  "2-juan",
  "3-juan",
  "judas",
  "apocalipsis"
)

$output = "Consultando el primer capítulo de cada libro de la Biblia (Reina Valera 1960):`n=================================================================================`n"

foreach ($book in $books) {
  $output += "`nLibro: $book`n"
  $url = "https://bible-api.deno.dev/api/read/rv1960/$book/1"
  $output += "URL: $url`n"
  try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    if ($response.vers) {
      $text = ""
      foreach ($verse in $response.vers) {
        if ($verse.verse) {
          $text += $verse.verse + " "
        }
      }
      $text = $text.Trim()
      if ($text) {
        $output += "Texto: $text`n"
      } else {
        $output += "Texto no encontrado en vers`n"
      }
    } else {
      $output += "Vers no encontrado en la respuesta`n"
    }
  } catch {
    $output += "Error al consultar: $($_.Exception.Message)`n"
  }
  $output += "---------------------------------------------------------------------------------`n"
}

$output | Out-File -FilePath "bible_texts.txt" -Encoding UTF8
Write-Host "Resultados guardados en bible_texts.txt"