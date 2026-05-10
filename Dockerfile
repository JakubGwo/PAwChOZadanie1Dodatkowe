# Builder
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Instalacja certyfikatów SSL i gita
RUN apk --no-cache git ca-certificates



# Bezpieczne wstrzyknięcie tokenu z pliku
RUN --mount=type=secret,id=github_token \
    TOKEN=$(cat /run/secrets/github_token) && \
    git clone https://${TOKEN}@[github.com/JakubGwo/docker-pogoda-app.git](https://github.com/JakubGwo/docker-pogoda-app.git) .

# Inicjalizacja modułu i statyczna kompilacja kodu w języku Go
# CGO_ENABLED=0 jest kluczowe dla działania aplikacji w warstwie scratch
RUN go mod init weatherapp && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o weatherapp main.go

# Docelowy obraz
FROM scratch

# Etykieta - autor obrazu
LABEL org.opencontainers.image.authors="Jakub Gwozdowski"

# Kopiowanie certyfikatów SSL z etapu buildera
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Kopiowanie skompilowanej aplikacji z etapu buildera
COPY --from=builder /app/weatherapp /weatherapp

# Deklaracja portu
EXPOSE 8080

# HEALTHCHECK dla warstwy scratch
# Zamiast curl, mechanizm z użyciem flagi '-health'.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/weatherapp", "-health"]

# Uruchomienie głównego procesu 
CMD ["/weatherapp"]