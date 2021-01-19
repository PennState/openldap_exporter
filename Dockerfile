FROM golang:alpine AS builder

WORKDIR /build

ENV GO111MODULE=on
ENV CGO_ENABLED=0

ENV USER=appuser
ENV UID=1000
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

RUN apk update && apk add make git
COPY . .
RUN make build


FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /build/target/openldap_exporter-linux /openldap_exporter

USER appuser:appuser

ENTRYPOINT ["/openldap_exporter"]