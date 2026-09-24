# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# defecto 1 - corregido: usar la imagen de runtime de Lambda en la version correcta.
FROM public.ecr.aws/lambda/nodejs:20 AS build
WORKDIR /build

# defecto 2 - corregido: copiar solo el archivo de dependencias y luego el codigo fuente.
COPY package*.json ./
RUN npm ci

COPY src ./src
RUN npm run build

# defecto 4 - corregido: no dejar secretos en la imagen.
# defecto 5 - corregido: no instalar herramientas extra en la etapa final.

### NO TOCAR DE ACA EN ADELANTE, CONSIDEREN QUE EL WORKDIR DEBE SER /build
RUN npx esbuild src/handler.js \
      --bundle --platform=node --target=node20 \
      --outfile=dist/handler.js

# Etapa final: recibe unicamente el artefacto empaquetado.
# El arbol de node_modules se queda en la etapa anterior.
FROM public.ecr.aws/lambda/nodejs:20 AS runtime
WORKDIR ${LAMBDA_TASK_ROOT}
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/dist/handler.js
CMD ["dist/handler.handler"]