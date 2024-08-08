# Dockerfile for ARM64 architecture
# Use the ARM64 base image for Python
FROM python:3.9-slim-arm64

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY webapp.py .

CMD ["python", "webapp.py"]
