# ---------- Build Stage ----------
FROM golang:1.18-alpine AS build

# Install build tools
RUN apk add --no-cache make git build-base

# Set working directory
WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build using the Makefile
RUN make build


# ---------- Runtime Stage ----------
FROM alpine:3.17 AS run

# Install runtime deps if needed
RUN apk add --no-cache ca-certificates

WORKDIR /app

# Copy binary from builder
COPY --from=build /app/bin/restapi ./bin/restapi

# Copy static resources the app needs
COPY --from=build /app/data ./data

# Run the binary
CMD ["./bin/restapi"]
