# Estágio de build: gera o Flutter web. Usa a tag "stable" (mesma do CI: canal stable;
# imagens versionadas 3.47.0 ainda não publicadas em ghcr.io/cirruslabs)
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

ARG API_URL=http://localhost:8000

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --dart-define=API_URL=$API_URL

# Estágio de serve: nginx entrega o build/web
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80