FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

COPY package*.json ./
RUN npm ci

COPY src ./src
RUN npm run build

FROM public.ecr.aws/lambda/nodejs:20

WORKDIR /var/task

COPY --from=build /build/dist/handler.js /var/task/dist/handler.js

CMD ["dist/handler.handler"]