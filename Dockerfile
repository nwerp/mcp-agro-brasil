# Imagem Docker do mcp-agro-brasil (mesmo molde do mcp-fiscal-brasil).
#
# Run (stdio):     docker run --rm -i mcp-agro-brasil
# Run (MCP HTTP):  docker run --rm -p 8000:8000 -e FASTMCP_TRANSPORT=http mcp-agro-brasil
#
# Credenciais AgroAPI opcionais: AGROAPI_TOKEN ou AGROAPI_CLIENT_ID + AGROAPI_CLIENT_SECRET.

# ---- Build stage ----
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

COPY pyproject.toml README.md LICENSE ./
COPY src/ ./src/

RUN pip install --no-cache-dir hatchling build && \
    python -m build --wheel

# ---- Runtime stage ----
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    HOST=0.0.0.0

WORKDIR /app

COPY --from=builder /build/dist/*.whl ./

RUN pip install --no-cache-dir *.whl && \
    rm -f *.whl && \
    groupadd -r app && useradd -r -g app -d /app -s /usr/sbin/nologin app && \
    chown -R app:app /app

USER app

EXPOSE 8000

CMD ["mcp-agro-brasil"]
