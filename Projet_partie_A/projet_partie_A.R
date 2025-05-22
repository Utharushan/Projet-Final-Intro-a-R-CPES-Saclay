# Nettoyer l’espace de travail pour éviter les interférences
rm(list = ls())

# Chargement des bibliothèques nécessaires
library(ggplot2)   # visualisation
library(dplyr)     # manipulation de données
library(lubridate) # gestion des dates
library(scales)    # fonctions d’échelle et formatage (comma(), sec_axis())

# Lecture du fichier CSV
data <- read.csv("Projet_partie_A.csv", sep = ",", header = TRUE)

# Renommer les colonnes pour simplifier leur usage dans R
colnames(data) <- c("Date", "Conso", "Temp_moy", "Temp_ref")

# Conversion de la colonne Date en type Date R
data$Date <- as.Date(data$Date)

# 1) Tracer l’évolution du pic journalier de consommation
png("graphique_conso.png", width = 800, height = 500)
ggplot(data, aes(x = Date, y = Conso)) +
  geom_line(color = "steelblue", linewidth = 1) +             # ligne bleue
  labs(title = "Évolution du pic journalier de consommation électrique",
       x = "Date", y = "Consommation (MW)") +
  theme_minimal()                                              # thème épuré
dev.off()

# 2) Tracer la Température moyenne et de référence dans le temps
png("graphique_temps.png", width = 800, height = 500)
ggplot(data) +
  geom_line(aes(x = Date, y = Temp_moy,   color = "Température moyenne"),   linewidth = 1) +
  geom_line(aes(x = Date, y = Temp_ref,   color = "Température référence"), linewidth = 1) +
  labs(title = "Évolution des températures", x = "Date", y = "Température (°C)") +
  scale_color_manual(name = "Légende",
                     values = c("Température moyenne" = "orange",
                                "Température référence" = "darkgreen")) +
  theme_minimal()
dev.off()

# 3) Calcul des moyennes mensuelles de consommation
data$Mois <- month(data$Date, label = TRUE, abbr = TRUE)   # extraire le mois (étiquettes Jan–Déc)
moyennes_mensuelles <- data %>%
  group_by(Mois) %>%                                       # par mois
  summarise(Conso_moy = mean(Conso, na.rm = TRUE))         # moyenne de Conso

# Tracer un barplot des moyennes mensuelles
png("conso_moyenne_par_mois.png", width = 800, height = 500)
ggplot(moyennes_mensuelles, aes(x = Mois, y = Conso_moy)) +
  geom_col(fill = "skyblue") +
  labs(title = "Consommation électrique moyenne par mois",
       x = "Mois", y = "Consommation moyenne (MW)") +
  theme_minimal()
dev.off()

# 4) Ajustement d’un modèle de régression linéaire simple
modele <- lm(Conso ~ Temp_moy, data = data)
summary(modele)  # affiche les estimations, R², tests t, etc.

# Visualiser la droite de régression
png("regression_temp_vs_conso.png", width = 800, height = 500)
ggplot(data, aes(x = Temp_moy, y = Conso)) +
  geom_point(color = "darkorange", size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "blue", linewidth = 1) +
  labs(title = "Régression linéaire : Température moyenne vs Consommation",
       x = "Température moyenne (°C)", y = "Consommation (MW)") +
  theme_minimal()
dev.off()

# 5) Calcul de la corrélation linéaire
cor_temp <- cor(data$Temp_moy, data$Conso, use = "complete.obs")
print(paste("Corrélation Tempér./Consommation :", round(cor_temp, 3)))

# 6) Fusionner consommation et température sur le même graphique
#    – on met la température sur un axe secondaire via mise à l'échelle
facteur <- max(data$Conso, na.rm = TRUE) / max(data$Temp_moy, na.rm = TRUE)

png("conso_vs_temp_superpose.png", width = 800, height = 500)
ggplot(data, aes(x = Date)) +
  geom_line(aes(y = Conso, color = "Consommation"), linewidth = 1) +
  geom_line(aes(y = Temp_moy * facteur, color = "Température"), linewidth = 1) +
  scale_y_continuous(
    name = "Consommation (MW)",
    labels = comma,
    sec.axis = sec_axis(~ . / facteur, name = "Température moyenne (°C)")
  ) +
  scale_color_manual(
    name = "",
    values = c("Consommation" = "steelblue", "Température" = "orange")
  ) +
  labs(title = "Consommation électrique et température moyenne", x = "Date") +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.title.y.right = element_text(color = "orange"),
    axis.text.y.right  = element_text(color = "orange")
  )
dev.off()
