# Utilise l'image officielle Python 3.9
FROM arm64v8/python:3.10-bullseye

# Définit le répertoire de travail dans le conteneur
WORKDIR /app

# Copie le contenu du répertoire container dans le conteneur
COPY ./ /app

# Installe les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# L'application écoute sur le port 8080
EXPOSE 8080

# Commande pour exécuter l'application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080", "--log-level", "info", "--ssl-keyfile", "/app/data/.ssl/privkey1.pem", "--ssl-certfile", "/app/data/.ssl/fullchain1.pem","--log-config","log_conf.yaml"]
