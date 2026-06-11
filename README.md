# TrailDrops
Un script PowerShell automatisé utilisant **FFmpeg** pour générer du contenu d'ambiance et de prévisualisation pour tes séries et animés. Idéal pour enrichir l'interface de serveurs comme Plex, Emby ou Jellyfin.

## ✨ Fonctionnalités

* **Trailers Dynamiques (Multi-extraits) :** Analyse le premier épisode d'une série, extrait 3 moments clés configurables (ex: intro, milieu, tension) et les fusionne proprement en un seul trailer d'un minute et 15 secondes.
* **Arrière-plans animés (Backdrops) :** Extrait une séquence courte et propre (ex: 30 secondes), idéale pour tourner en boucle en fond d'écran sur ton interface.
* **Automatisation intelligente :** Scanne un dossier racine, détecte la Saison 1 en priorité, et passe automatiquement la série si les fichiers existent déjà.

## 🚀 Configuration rapide

Modifie simplement les variables en haut du script `.ps1` :
* `$AnimeRootFolder` : Ton dossier contenant toutes tes séries.
* `$FFmpegPath` : Le chemin vers ton exécutable FFmpeg.
* Ajuste les minutes et durées des extraits selon tes préférences !
