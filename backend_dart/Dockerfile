# Usamos la imagen oficial de Dart
FROM dart:stable AS build

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos los archivos del proyecto al contenedor
COPY . .

# Instalamos las dependencias
RUN dart pub get

# Exponemos el puerto 8080
EXPOSE 8080

# Comando para ejecutar la aplicación Dart
CMD ["dart", "run"]


