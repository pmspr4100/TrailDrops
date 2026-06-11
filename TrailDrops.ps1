# Affichage propre des accents dans la console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================================================================================
# CONFIGURATION
# =========================================================================================
# Dossier racine contenant tes dossiers
$AnimeRootFolder = "V:\" # Pense à vérifier que ce chemin est le bon

# Chemin absolu direct vers l'exécutable FFmpeg
$FFmpegPath      = "C:\Tools\ffmpeg\bin\ffmpeg.exe"

# Paramètres d'extraction (en secondes)
$StartOffset     = 5   
$Duration        = 90  

# =========================================================================================
# TRAITEMENT
# =========================================================================================

$SeriesFolders = Get-ChildItem -Path $AnimeRootFolder -Directory

foreach ($Series in $SeriesFolders) {
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Analyse de la série : $($Series.Name)" -ForegroundColor White
    
    # Chemins des dossiers trailers et backdrops
    $TrailersDir  = Join-Path $Series.FullName "trailers"
    $BackdropsDir = Join-Path $Series.FullName "backdrops"

    # Chemins des fichiers de destination
    $ThemeMkvTrailerPath  = Join-Path $TrailersDir "theme.mkv"
    $ThemeMkvBackdropPath = Join-Path $BackdropsDir "theme.mkv"
    
    # Si les deux fichiers existent déjà, on passe à la série suivante
    if ((Test-Path $ThemeMkvTrailerPath) -and (Test-Path $ThemeMkvBackdropPath)) {
        Write-Host "-> Les fichiers trailers et backdrops existent déjà. Passage." -ForegroundColor Yellow
        continue
    }

    # Recherche du premier épisode MKV (Saison 1 de préférence)
    $FirstEpisode = Get-ChildItem -Path $Series.FullName -Filter "*.mkv" -Recurse | 
                    Where-Object { $_.FullName -match "S01|Season 01|Saison 1" } | 
                    Select-Object -First 1

    if (-not $FirstEpisode) {
        $FirstEpisode = Get-ChildItem -Path $Series.FullName -Filter "*.mkv" -Recurse | Select-Object -First 1
    }

    if (-not $FirstEpisode) {
        Write-Host "-> Aucun fichier MKV source trouvé pour cette série." -ForegroundColor Red
        continue
    }

    Write-Host "-> Épisode source identifié : $($FirstEpisode.Name)" -ForegroundColor Gray

    # 1. DOSSIER TRAILERS
    if (-not (Test-Path $ThemeMkvTrailerPath)) {
        if (-not (Test-Path $TrailersDir)) { 
            New-Item -Path $TrailersDir -ItemType Directory | Out-Null 
        }
        Write-Host "-> Extraction de trailers/theme.mkv (Vidéo + Audio)..." -ForegroundColor Green
        & $FFmpegPath -ss $StartOffset -t $Duration -i "$($FirstEpisode.FullName)" -c copy -y "$ThemeMkvTrailerPath" 2>$null
    }

    # 2. DOSSIER BACKDROPS
    if (-not (Test-Path $ThemeMkvBackdropPath)) {
        if (-not (Test-Path $BackdropsDir)) { 
            New-Item -Path $BackdropsDir -ItemType Directory | Out-Null 
        }
        Write-Host "-> Extraction de backdrops/theme.mkv (Vidéo + Audio)..." -ForegroundColor Green
        & $FFmpegPath -ss $StartOffset -t $Duration -i "$($FirstEpisode.FullName)" -c copy -y "$ThemeMkvBackdropPath" 2>$null
    }
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Traitement terminé avec succès !" -ForegroundColor Green