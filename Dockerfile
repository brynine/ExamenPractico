# ==========================================
# ETAPA 1: Construcción, dependencias y tests
# ==========================================
FROM node:18-alpine AS builder

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar todas las dependencias (incluyendo devDependencies para los tests)
RUN npm ci

# Copiar el código fuente de la aplicación
COPY . .

# Ejecutar pruebas unitarias (el build fallará automáticamente si las pruebas fallan)
RUN npm test

# ==========================================
# ETAPA 2: Imagen final de producción mínima
# ==========================================
FROM node:18-alpine AS runner

# Definir directorio de trabajo
WORKDIR /app

# Configurar entorno de producción
ENV NODE_ENV=production

# Copiar solo el package.json y package-lock.json
COPY package*.json ./

# Instalar únicamente dependencias de producción para aligerar la imagen
RUN npm ci --only=production

# Copiar el código del servidor, base de datos y la carpeta public de la interfaz
COPY server.js db.js ./
COPY public/ ./public/
COPY data/ ./data/

# Puerto en el que escucha la aplicación
EXPOSE 3000

# Comando para ejecutar la aplicación
CMD ["node", "server.js"]