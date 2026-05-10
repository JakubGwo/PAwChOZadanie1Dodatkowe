## Zadanie 1 Dodatkowe, część 3. Zrzuty ekranowe potiwerdzające wykonane polecenia znajdują sie w folderze screenshots, token zabezpieczony za pomocą .gitignore nie wysłany do repozytorium

### 1. Plik Dockerfile (BuildKit, Cache, mount=secret)
Zastosowano rozszerzony BuildKit. Kod pobierany jest bezpośrednio z repozytorium GitHub za pomocą wstrzykiwania poświadczeń (secret).

## Fragment zmian z Dockerfile
RUN apk add --no-cache git ca-certificates
RUN --mount=type=secret,id=github_token \
    TOKEN=$(cat /run/secrets/github_token) && \
    git clone https://${TOKEN}@github.com/JakubGwo/PAwChOZadanie1Dodatkowe.git .
RUN go mod init weatherapp && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o weatherapp main.go

### 2. Potwierdzenie deklaracji platform sprzętowych w manifeście

Name:      docker.io/jakgwo/pogoda-app:dodatkowe
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:d40432b1c7df2c9c7166963d2c30a1e2626eab040e4237c7545c8210362af577

Manifests:
  Name:        docker.io/jakgwo/pogoda-app:dodatkowe@sha256:77f98ecacdc5864cc6f90188339e2ff9a10f5b2f5c1901dcb02ea1153cdc96fd
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/amd64

  Name:        docker.io/jakgwo/pogoda-app:dodatkowe@sha256:0c9f084e23d0686bfa176960b2dd90006121c74e9d020df7f0739bfe961db440
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/arm64


### 3. Zagrożenia znajdujące się w obrazie

Zastosowana w projekcie warstwa bazowa scratch jest całkowicie wolna od podatności na poziomie systemu operacyjnego. Skaner wykrył podatności wyłącznie wewnątrz pliku binarnego (w standardowej bibliotece języka Go stdlib w wersji 1.21), dlatego w Dockerfile zmieniłem golang:1.21-alpine na golang:alpine. Dzięki pustej wartstwie scratch i najnowszej wersji kompilatora Docker Scout wykazał brak podatności.