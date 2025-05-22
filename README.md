# Projet-Final-Intro-a-R-CPES-Saclay

Ce dépôt contient les analyses R et les rapports pour le projet « Introduction à R » de CPES2, composé de deux volets :

- **Partie A** : Influence de la température sur le pic journalier de consommation électrique (2012–2025).  
  - Script principal : `Projet_partie_A/projet_partie_A.R`  
  - Données : `Projet_partie_A/Projet_partie_A.csv`  
  - Graphiques générés :  
    - `graphique_conso.png`  
    - `graphique_temps.png`  
    - `conso_moyenne_par_mois.png`  
    - `temp_moyenne_par_mois.png`  
    - `conso_temp_moyennes_par_mois_superpose.png`  
    - `regression_temp_vs_conso.png`  
    - `conso_vs_temp_superpose.png`

- **Partie B** : Exploration des effectifs de patients par pathologie, âge, sexe et territoire (2019–2022).  
  - Script principal : `Projet_partie_B/projet_partie_B.R`  
  - Données : `Projet_partie_B/Projet_partie_B.csv`  
  - Shapefiles : `Projet_partie_B/shapefile/regions_shapefile.*`  
  - Graphiques générés dans `Projet_partie_B/figures/` (01_… à 10_…)

---

## Structure du dépôt

```

.
├── README.md
├── Partie_A/
│   ├── Projet_partie_A.csv
│   ├── projet_partie_A.R
│   └── \*.png
├── Partie_B/
│   ├── Projet_partie_B.csv
│   ├── projet_partie_B.R
│   ├── shapefile/
│   │   ├── regions_shapefile.shp
│   │   └── ...
│   └── figures/
│       ├── 01_total_patients_par_annee.png
│       └── ...
└── UTHAYAKUMAR_Tharushan_CPES2_2025_Rapport_Projet_R.pdf

````

---

## Installation et usage

1. **Cloner**  
   ```bash
   git clone https://github.com/Utharushan/Projet-Final-Intro-a-R-CPES-Saclay.git
   cd Projet-Final-Intro-a-R-CPES-Saclay


2. **Installer les packages R**

   ```r
   install.packages(c(
     "ggplot2","dplyr","lubridate","scales",
     "tidyverse","sf","viridis","readr"
   ))
   ```

3. **Exécuter les analyses**

   ```r
   # Partie A
   source("Projet_partie_A/projet_partie_A.R")

   # Partie B
   source("Projet_partie_B/projet_partie_B.R")
   ```

4. **Les graphiques PNG sont écrits dans les dossiers respectifs (`Projet_partie_A/` et `Projet_partie_B/figures/`).**

---

## Rapports PDF

* **UTHAYAKUMAR_Tharushan_CPES2_2025_Rapport_Projet_R.pdf**

---

## Sources de données

* **Partie A** : Pic journalier de consommation électrique –
  [https://www.data.gouv.fr/fr/datasets/pic-journalier-de-la-consommation-brute-delectricite/](https://www.data.gouv.fr/fr/datasets/pic-journalier-de-la-consommation-brute-delectricite/)
* **Partie B** : Effectifs hospitaliers par pathologie –
  [https://data.ameli.fr/explore/dataset/effectifs/information/](https://data.ameli.fr/explore/dataset/effectifs/information/)

---

## Auteur

Tharushan UTHAYAKUMAR \
tharushan.uthayakumar@hec.edu

---
