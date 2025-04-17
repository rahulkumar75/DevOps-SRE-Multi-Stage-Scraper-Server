# --------- Stage 1: Scraping using Node.js ---------
FROM node:18-slim as scraper

# Set environment variable to skip downloading Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install dependencies for Chromium
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libnspr4 \
    libnss3 \
    lsb-release \
    xdg-utils \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy package.json and install Node dependencies
COPY package.json ./
RUN npm install

# Copy scraping script
COPY scrape.js ./

# Provide URL to scrape
ARG SCRAPE_URL
ENV SCRAPE_URL=${SCRAPE_URL}

# Run the scraper
RUN node scrape.js

# --------- Stage 2: Flask Server ---------
FROM python:3.10-slim as final

# Set working directory
WORKDIR /app

# Install Flask
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy scraped data and server script from previous stage
COPY --from=scraper /app/scraped_data.json ./scraped_data.json
COPY server.py ./

# Expose the server port
EXPOSE 5000

# Healthcheck for container orchestration tools
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:5000/health || exit 1

# Start the Flask server
CMD ["python", "server.py"]
