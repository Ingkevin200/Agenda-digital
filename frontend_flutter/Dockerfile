# Etapa 1: construir la app Flutter Web
FROM cirrusci/flutter:latest AS build

WORKDIR /app
COPY . .

RUN flutter build web

# Etapa 2: servir con nginx
FROM nginx:1.25-alpine

# Copiar archivos compilados del build a nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer puerto
EXPOSE 5000

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]

