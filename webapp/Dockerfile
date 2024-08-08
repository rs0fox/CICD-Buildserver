# Use a base image with Python 3.11
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY webapp.py .

# Expose port 80 for the web application
EXPOSE 80

# Command to run the application
CMD ["python", "webapp.py"]
