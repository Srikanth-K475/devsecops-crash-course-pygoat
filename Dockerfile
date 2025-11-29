FROM python:3.11-slim

# set work directory
WORKDIR /app

# Install system dependencies (psycopg2, DNS tools, build deps)
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Upgrade pip (no need to downgrade to 22)
RUN python -m pip install --no-cache-dir --upgrade pip

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copy project
COPY . /app/

# run migrations
RUN python manage.py migrate

# expose app port
EXPOSE 8000

# run gunicorn
WORKDIR /app/pygoat/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
