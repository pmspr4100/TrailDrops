# Affichage propre des accents dans la console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================================================================================
# CONFIGURATION
# =========================================================================================
# Dossier racine contenant tes dossiers
$AnimeRootFolder = "V:\" # Pense à vérifier que ce chemin est le bon

# Chemin absolu direct vers l'exécutable FFmpeg
$FFmpegPath      = "C:\Tools\ffmpeg\bin\ffmpeg.exe"

# --- PARAMÈTRES TRAILERS (Multi-extraits) ---
$ClipDuration   = 25    # Durée de chaque extrait
$T_Clip1        = 300   # Extrait 1 : 5ème minute
$T_Clip2        = 600   # Extrait 2 : 10ème minute
$T_Clip3        = 900   # Extrait 3 : 15ème minute

# --- PARAMÈTRES BACKDROPS (Boucle) ---
$BackdropOffset   = 600  # Début à la 10ème minute
$BackdropDuration = 30   # Durée de 30 secondes

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
    $InputFile = $FirstEpisode.FullName

    # 1. DOSSIER TRAILERS (Dynamique : 3 extraits fusionnés)
    if (-not (Test-Path $ThemeMkvTrailerPath)) {
        if (-not (Test-Path $TrailersDir)) { 
            New-Item -Path $TrailersDir -ItemType Directory | Out-Null 
        }
        Write-Host "-> Génération du trailer multi-extraits (3x${ClipDuration}s)..." -ForegroundColor Green
        
        # Commande FFmpeg complexe pour couper 3 morceaux d'une SEULE source et les coller ensemble
        # Note : On ré-encode ici (sans spécifier de codec lourd pour aller vite) car la concaténation de flux stream copy (-c copy) issus de timestamps différents d'un même fichier pose souvent des problèmes de synchronisation audio/vidéo.
        $FilterArgs = "-ss $T_Clip1 -t $ClipDuration -i `"$InputFile`" " +
                      "-ss $T_Clip2 -t $ClipDuration -i `"$InputFile`" " +
                      "-ss $T_Clip3 -t $ClipDuration -i `"$InputFile`" " +
                      "-filter_complex `"[0:v][0:a][1:v][1:a][2:v][2:a] concat=n=3:v=1:a=1 [v][a]`" " +
                      "-map `"[v]`" -map `"[a]`" -y `"$ThemeMkvTrailerPath`""
        
        Start-Process -FilePath $FFmpegPath -ArgumentList $FilterArgs -NoNewWindow -Wait 2>$null
    }

    # 2. DOSSIER BACKDROPS (Simple et rapide)
    if (-not (Test-Path $ThemeMkvBackdropPath)) {
        if (-not (Test-Path $BackdropsDir)) { 
            New-Item -Path $BackdropsDir -ItemType Directory | Out-Null 
        }
        Write-Host "-> Extraction du backdrop (${BackdropDuration}s)..." -ForegroundColor Green
        # Ici on garde le "-c copy" car c'est un seul bloc continu, ultra rapide.
        & $FFmpegPath -ss $BackdropOffset -t $BackdropDuration -i "$InputFile" -c copy -y "$ThemeMkvBackdropPath" 2>$null
    }
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Traitement terminé avec succès !" -ForegroundColor Green