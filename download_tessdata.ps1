$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$tessdataDir = Join-Path $projectRoot "assets\tessdata"

New-Item -ItemType Directory -Force -Path $tessdataDir | Out-Null

$files = @{
  "ukr.traineddata" = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/ukr.traineddata"
  "eng.traineddata" = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/eng.traineddata"
  "rus.traineddata" = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/rus.traineddata"
  "osd.traineddata" = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/osd.traineddata"
}

foreach ($name in $files.Keys) {
  $url = $files[$name]
  $out = Join-Path $tessdataDir $name
  Write-Host "Downloading $name ..."
  Invoke-WebRequest -Uri $url -OutFile $out
}

Write-Host ""
Write-Host "Done. OCR language files are ready:"
Get-ChildItem $tessdataDir | Select-Object Name, Length
