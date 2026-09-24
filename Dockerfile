FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

COPY package*.json ./
RUN npm ci

COPY src ./src
RUN npm run build

FROM public.ecr.aws/lambda/nodejs:20

WORKDIR ${LAMBDA_TASK_ROOT}

COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/dist/handler.js

CMD ["dist/handler.handler"]
