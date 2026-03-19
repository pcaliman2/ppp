# ---------- Build stage ----------
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# ---------- Run stage ----------
FROM caddy:2-alpine

# Caddyfile usa el PORT que Railway inyecta
COPY Caddyfile /etc/caddy/Caddyfile

# Copiamos el build web
COPY --from=build /app/build/web /srv

EXPOSE 8080