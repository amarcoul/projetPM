# Utiliser une image Flutter officielle
FROM cirrusci/flutter:stable

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de l'application
COPY . .

# Ajouter une ligne pour utiliser un utilisateur non-root
RUN useradd -m myuser

# Passer à l'utilisateur non-root
USER myuser

# Télécharger et installer Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /home/myuser/flutter

# Ajouter Flutter au PATH
ENV PATH="/home/myuser/flutter/bin:/home/myuser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Installer les dépendances
WORKDIR /app/frontend/ecep_frontend
 # Assurez-vous que ce répertoire contient le fichier pubspec.yaml
RUN flutter pub get

# Exposer le port 5000 (port par défaut pour le serveur de développement Flutter)
EXPOSE 5000

# Commande pour démarrer l'application Flutter
CMD ["flutter", "run", "--host", "0.0.0.0", "--port", "5000"]
