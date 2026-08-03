FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

COPY app/requirements.txt ./requirements.txt

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY app/ /app/

FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app

COPY --from=builder /install/lib/python3.11/site-packages /usr/lib/python3.11/site-packages
COPY --from=builder /app /app

ENV PYTHONPATH=/usr/lib/python3.11/site-packages \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER nonroot

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/usr/bin/python3.11", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/buscar')"]

EXPOSE 8080

CMD ["app.py"]