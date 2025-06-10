# Etapa 1: construir la app Flutter Web
FROM instrumentisto/flutter:3.32.2-androidsdk35-r0 AS build

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

