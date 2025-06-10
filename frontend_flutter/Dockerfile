# Etapa 1: construir la app Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.19 AS build


WORKDIR /app
COPY . .

RUN flutter build web

# Etapa 2: servir con nginx
FROM nginx:1.25-alpine

# Copiar archivos compilados del build a nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer puerto
EXPOSE 80

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]

