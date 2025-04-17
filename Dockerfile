# --- Scraper Stage ---
FROM node:18-slim AS scraper

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY scrape.js ./

ENV SCRAPE_URL=https://rahulkumar.online
RUN mkdir -p /output
RUN node scrape.js

# --- Python Web Server Stage ---
FROM python:3.10-slim AS server

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY --from=scraper /output/scraped_data.json ./
COPY server.py ./

EXPOSE 5000
CMD ["python", "server.py"]