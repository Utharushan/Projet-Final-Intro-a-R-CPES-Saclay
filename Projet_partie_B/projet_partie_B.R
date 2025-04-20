rm(list = ls())

# Chargement des bibliothèques
library(ggplot2)
library(dplyr)
library(lubridate)

# Lecture des données
data <- read.csv("Projet_partie_B.csv", sep = ",", header = TRUE)

summary(data)

png("repartition_par_annee.png", width = 800, height = 500)
repartition_par_annee <- ggplot(data, aes(x = annee)) +
  geom_bar(fill = "steelblue") +
  theme_minimal() +
  labs(title = "Répartition des données par année", x = "Année", y = "Nombre d'observations")
dev.off()

png("repartition_des_pathologies.png", width = 800, height = 500)
ggplot(data, aes(x = patho_niv1)) +
  geom_bar(fill = "tomato") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Pathologies (niveau 1)", x = "Patho Niv 1", y = "Fréquence")
dev.off()

png("repartition_par_classe_age.png", width = 800, height = 500)
ggplot(data, aes(x = libelle_classe_age)) +
  geom_bar(fill = "darkorange") +
  theme_minimal() +
  labs(title = "Répartition par classe d'âge", x = "Classe d'âge", y = "Nombre")
dev.off()

png("repartition_par_sexe.png", width = 800, height = 500)
ggplot(data, aes(x = libelle_sexe)) +
  geom_bar(fill = "mediumseagreen") +
  theme_minimal() +
  labs(title = "Répartition par sexe", x = "Sexe", y = "Nombre")
dev.off()

png("repartition_par_region.png", width = 800, height = 500)
ggplot(data, aes(x = factor(region))) +
  geom_bar(fill = "mediumpurple") +
  theme_minimal() +
  labs(title = "Répartition par région", x = "Code région", y = "Nombre")
dev.off()

png("repartition_ntop.png", width = 800, height = 500)
suppressWarnings(
  ggplot(data, aes(x = Ntop)) +
    geom_histogram(binwidth = 100, fill = "skyblue", color = "black") +
    scale_x_log10() +
    theme_minimal() +
    labs(title = "Distribution du nombre de cas (Ntop)", x = "Ntop (log scale)", y = "Fréquence")
)
dev.off()

png("repartition_npop.png", width = 800, height = 500)
suppressWarnings(
  ggplot(data, aes(x = Npop)) +
    geom_histogram(binwidth = 1000, fill = "salmon", color = "black") +
    scale_x_log10() +
    theme_minimal() +
    labs(title = "Distribution de la population (Npop)", x = "Npop (log scale)", y = "Fréquence")
)
dev.off()

png("distribution_prevalence.png", width = 800, height = 500)
suppressWarnings(
  ggplot(data, aes(x = prev)) +
    geom_histogram(binwidth = 0.1, fill = "lightblue", color = "black") +
    theme_minimal() +
    labs(title = "Distribution de la prévalence", x = "Prévalence", y = "Fréquence")
)
dev.off()