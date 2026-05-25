FROM node:18-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances (seulement celles de production)
RUN npm ci --only=production

# Copier le reste du code source
COPY . .

# Exposer le port de l'API
EXPOSE 3000

# Démarrer le serveur
CMD ["node", "server.js"]