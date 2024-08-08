# Dockerfile for ARM64 architecture
# Use the appropriate base image for ARM64
FROM python:3.11-slim-arm64

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Command to run the application
CMD ["python", "app.py"]
