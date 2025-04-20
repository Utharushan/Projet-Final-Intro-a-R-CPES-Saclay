rm(list = ls())

# Chargement des bibliothèques
library(ggplot2)
library(dplyr)
library(lubridate)

# Lecture des données
data <- read.csv("Projet_partie_A.csv", sep = ",", header = TRUE)

# Renommage des colonnes pour éviter les caractères spéciaux
colnames(data) <- c("Date", "Conso", "Temp_moy", "Temp_ref")

# Conversion de la date au bon format
data$Date <- as.Date(data$Date)

# Graphique : Évolution du pic journalier de consommation
png("graphique_conso.png", width = 800, height = 500)
ggplot(data, aes(x = Date, y = Conso)) +
  geom_line(color = "steelblue", linewidth = 1) +
  labs(title = "Évolution du pic journalier de consommation électrique",
       x = "Date", y = "Consommation (MW)") +
  theme_minimal()
dev.off()

# Graphique : Température moyenne vs température de référence au fil du temps
png("graphique_temps.png", width = 800, height = 500)
ggplot(data) +
  geom_line(aes(x = Date, y = Temp_moy, color = "Température moyenne"), linewidth = 1) +
  geom_line(aes(x = Date, y = Temp_ref, color = "Température référence"), linewidth = 1) +
  labs(title = "Évolution des températures", x = "Date", y = "Température (°C)") +
  scale_color_manual(name = "Légende", values = c("Température moyenne" = "orange", "Température référence" = "darkgreen")) +
  theme_minimal()
dev.off()

# Ajout d'une colonne mois
data$Mois <- month(data$Date, label = TRUE, abbr = TRUE)  # ex: Jan, Feb...

# Calcul de la moyenne de consommation par mois
moyennes_mensuelles <- data %>%
  group_by(Mois) %>%
  summarise(Conso_moy = mean(Conso, na.rm = TRUE))

# Graphique : Moyenne de consommation par mois
png("conso_moyenne_par_mois.png", width = 800, height = 500)
ggplot(moyennes_mensuelles, aes(x = Mois, y = Conso_moy)) +
  geom_col(fill = "skyblue") +
  labs(title = "Consommation électrique moyenne par mois",
       x = "Mois", y = "Consommation moyenne (MW)") +
  theme_minimal()
dev.off()

# Régression linéaire
modele <- lm(Conso ~ Temp_moy, data = data)
summary(modele)

png("regression_temp_vs_conso.png", width = 800, height = 500)
ggplot(data, aes(x = Temp_moy, y = Conso)) +
  geom_point(color = "darkorange", size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "blue", linewidth = 1) +
  labs(title = "Régression linéaire : Température moyenne vs Consommation",
       x = "Température moyenne (°C)", y = "Consommation (MW)") +
  theme_minimal()
dev.off()

# Corrélation entre température moyenne et consommation
cor_temp <- cor(data$Temp_moy, data$Conso, use = "complete.obs")
print(paste("Corrélation entre température moyenne et consommation:", round(cor_temp, 3)))

