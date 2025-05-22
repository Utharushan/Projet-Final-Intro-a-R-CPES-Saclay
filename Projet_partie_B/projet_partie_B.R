# Nettoyage de l'espace de travail
rm(list = ls())

# Chargement des bibliothèques
library(tidyverse)      # manipulation et visualisation
library(lubridate)      # gestion des dates
library(scales)         # échelles et formatage
library(sf)             # gestion géométries
library(viridis)        # palettes de couleurs

# Lecture du fichier CSV
# Le fichier "Projet_partie_B.csv" doit être placé dans le même répertoire que ce script
data_raw <- read_csv("Projet_partie_B.csv", locale = locale(encoding = "UTF-8"))

# Aperçu et nettoyage
glimpse(data_raw)

# Conversion et renommage des colonnes
data <- data_raw %>%
  rename(
    Annee             = annee,
    Patho1            = patho_niv1,
    Patho2            = patho_niv2,
    Patho3            = patho_niv3,
    Code_top          = top,
    Cls_age_5         = cla_age_5,
    Sexe_code         = sexe,
    Code_region       = region,
    Code_dept         = dept,
    N_patients        = Ntop,
    Pop_total         = Npop,
    Prevalence_pct    = prev,
    Prioritaire       = Niveau.prioritaire,
    Cls_age_lib       = libelle_classe_age,
    Sexe_lib          = libelle_sexe
  ) %>%
  mutate(
    Annee           = as.integer(Annee),
    Cls_age_lib     = factor(Cls_age_lib, levels = unique(Cls_age_lib)),
    Sexe_lib        = factor(Sexe_lib, levels = c("hommes", "femmes", "tous sexes")),
    Patho1          = fct_lump(Patho1, n = 10),     # regrouper les pathologies principales
    Prevalence_pct  = as.numeric(Prevalence_pct),
    N_patients      = as.numeric(N_patients)
  ) %>%
  filter(!is.na(Prevalence_pct))  # exclure les non-significatifs

# Création d'un dossier pour les graphiques
if (!dir.exists("figures")) dir.create("figures")

# 1) Évolution du nombre total de patients pris en charge par année
png("figures/01_total_patients_par_annee.png", width = 800, height = 500)
fig1 <- data %>%
  group_by(Annee) %>%
  summarise(Total_patients = sum(N_patients, na.rm = TRUE)) %>%
  ggplot(aes(x = Annee, y = Total_patients)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "Évolution du nombre total de patients par année",
    x     = "Année", y = "Nombre de patients"
  ) +
  theme_minimal()
print(fig1)
dev.off()

# 2) Répartition des pathologies de niveau 1 pour la dernière année disponible
png("figures/02_top10_patho1.png", width = 800, height = 600)
derniere_annee <- max(data$Annee)
fig2 <- data %>%
  filter(Annee == derniere_annee) %>%
  count(Patho1, wt = N_patients, name = "Total") %>%
  arrange(desc(Total)) %>%
  top_n(10, Total) %>%
  ggplot(aes(x = fct_reorder(Patho1, Total), y = Total)) +
  geom_col(fill = viridis(10)) +
  coord_flip() +
  labs(
    title = paste0("Top 10 des pathologies (niveau 1) en ", derniere_annee),
    x     = "Pathologie niveau 1", y = "Nombre de patients"
  ) +
  theme_minimal()
print(fig2)
dev.off()

# 3) Carte de la prévalence moyenne par région pour une pathologie donnée (ex: maladies cardioneurovasculaires)

# Lecture du shapefile des régions
regions_sf <- st_read("shapefile/regions_shapefile.shp",
                      options = "ENCODING=UTF-8",
                      quiet = TRUE) %>%
  # On ne garde que la métropole (exclut DOM-TOM 971, 972, 973, 974, 976)
  filter(!CdRegion %in% c("971", "972", "973", "974", "976")) %>%
  mutate(CdRegion = as.character(CdRegion))

# S'assurer que les identifiants région sont bien au format character dans les deux jeux de données
data <- data %>%
  mutate(Code_region = as.character(Code_region))

# Supposons que la bonne colonne est "INSEE_REG" ou "code" ou similaire, sinon adapter ici
# Par exemple :
# regions_sf <- regions_sf %>%
#   rename(CdRegion = INSEE_REG)

# On transforme aussi cette colonne au format character
regions_sf <- regions_sf %>%
  mutate(CdRegion = as.character(CdRegion)) # remplacer CdRegion si nécessaire

# Calcul de la prévalence moyenne par région pour la pathologie ciblée
prevalence_reg <- data %>%
  filter(Patho1 == "Maladies cardioneurovasculaires") %>%
  group_by(Code_region) %>%
  summarise(Prevalence = mean(Prevalence_pct, na.rm = TRUE), .groups = "drop")

# Fusion des données géographiques avec les données de prévalence
regions_map <- regions_sf %>%
  left_join(prevalence_reg, by = c("CdRegion" = "Code_region"))

# 1) Construire la bounding-box métropole
bbox_metropole <- st_bbox(c(xmin = -20, ymin = 40, xmax = 20, ymax = 90),
                          crs = st_crs(regions_map))

# 2) Rogner la carte
regions_map_metro <- st_crop(regions_map, bbox_metropole)

# 3) Tracer
png("figures/03_carte_prevalence_region_metro.png", width = 800, height = 600)
ggplot(regions_map_metro) +
  geom_sf(aes(fill = Prevalence), color = "white", size = 0.2) +
  scale_fill_viridis_c(option = "magma", na.value = "grey90") +
  labs(
    title = "Prévalence moyenne des maladies cardioneurovasculaires\n(France métropolitaine)",
    fill  = "% Prévalence"
  ) +
  coord_sf(expand = FALSE) +
  theme_minimal()
dev.off()



# 4) Heatmap de la prévalence selon classe d'âge et sexe pour la dernière année
png("figures/04_heatmap_age_sexe.png", width = 800, height = 500)
fig4 <- data %>%
  filter(Annee == derniere_annee) %>%
  group_by(Cls_age_lib, Sexe_lib) %>%
  summarise(Prev = mean(Prevalence_pct, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = Cls_age_lib, y = Sexe_lib, fill = Prev)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(
    title = paste0("Heatmap de prévalence par âge et sexe en ", derniere_annee),
    x     = "Classe d'âge", y = "Sexe",
    fill  = "% Prevalence"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(fig4)
dev.off()

# 5) Évolution de la prévalence des 5 pathologies principales au fil des années
png("figures/05_evol_prev_top5.png", width = 800, height = 500)
top5 <- data %>%
  filter(Annee == derniere_annee) %>%
  count(Patho1, wt = Prevalence_pct, name = "MeanPrev") %>%
  top_n(5, MeanPrev) %>%
  pull(Patho1)
fig5 <- data %>%
  filter(Patho1 %in% top5) %>%
  group_by(Annee, Patho1) %>%
  summarise(Prev = mean(Prevalence_pct, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = Annee, y = Prev, color = Patho1)) +
  geom_line(size = 1) +
  labs(
    title = "Évolution de la prévalence des 5 principales pathologies",
    x     = "Année", y = "En % de Prevalence",
    color = "Pathologie"
  ) +
  theme_minimal()
print(fig5)
dev.off()

# 6) Distribution de la prévalence par département (boxplot)
png("figures/06_boxplot_departement.png", width = 800, height = 500)
fig6 <- data %>%
  group_by(Code_dept) %>%
  summarise(Prev = mean(Prevalence_pct, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(y = Prev)) +
  geom_boxplot() +
  labs(
    title = "Distribution de la prévalence moyenne par département",
    y     = "% Prevalence"
  ) +
  theme_minimal()
print(fig6)
dev.off()

# 7) Diagramme circulaire : répartition des sexes pour la pathologie la plus fréquente
png("figures/07_pie_sexe_patho.png", width = 800, height = 500)
fig7 <- data %>%
  filter(Patho1 == top5[1]) %>%
  count(Sexe_lib, wt = N_patients, name = "Total") %>%
  ggplot(aes(x = "", y = Total, fill = Sexe_lib)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  labs(
    title = paste0("Répartition par sexe : ", top5[1]),
    fill  = "Sexe"
  ) +
  theme_void()
print(fig7)
dev.off()

# 8) Scatter plot : population vs nombre de patients pour la pathologie la plus fréquente
png("figures/08_scatter_pop_vs_patients.png", width = 800, height = 500)
fig8 <- data %>%
  filter(Patho1 == top5[1]) %>%
  ggplot(aes(x = Pop_total, y = N_patients)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = paste0("Pop. totale vs N. patients pour ", top5[1]),
    x     = "Population totale", y = "Nombre de patients"
  ) +
  theme_minimal()
print(fig8)
dev.off()

# 9) Boxplot de la prévalence par pathologie de niveau 1
png("figures/09_boxplot_patho1.png", width = 800, height = 500)
fig9 <- data %>%
  ggplot(aes(x = Patho1, y = Prevalence_pct)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "Prévalence par pathologie de niveau 1",
    x     = "Pathologie", y = "% Prevalence"
  ) +
  theme_minimal()
print(fig9)
dev.off()

# 10) Heatmap temporelle : prévalence des pathologies sur les années
png("figures/10_heatmap_patho_temps.png", width = 800, height = 500)
fig10 <- data %>%
  group_by(Annee, Patho1) %>%
  summarise(Prev = mean(Prevalence_pct, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = Annee, y = Patho1, fill = Prev)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(
    title = "Prévalence des pathologies (niv.1) dans le temps",
    x     = "Année", y = "Pathologie",
    fill  = "% Prevalence"
  ) +
  theme_minimal()
print(fig10)
dev.off()
