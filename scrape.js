const puppeteer = require('puppeteer');
const fs = require('fs');

// Getting the URL from environment variable
const url = process.env.SCRAPE_URL;

if (!url) {
  console.error("SCRAPE_URL environment variable is not set.");
  process.exit(1);
}

async function scrapeWebsite () {
  try {
    console.log(`Launching headless browser to scrape: ${url}`);
    
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'domcontentloaded' });

    // Extracted page title and first Heading tag
    const scrapedContent = await page.evaluate(() => {
      const pageTitle = document.title || "Untitled Page";
      const mainHeading = document.querySelector('h1')?.textContent || "No heading found";
      const metaDescription = document.querySelector('meta[name="description"]')?.content || 'No meta description';
      
      return { 
        pageTitle, 
        mainHeading, 
        metaDescription 
      };
    });

    await browser.close();

    // Save scraped data in JSON file
    fs.writeFileSync('scraped_data.json', JSON.stringify(scrapedContent, null, 2));
    console.log('Scraping complete! Data saved to scraped_data.json');
    
  } catch (error) {
    console.error("Error during scraping:", error);
    process.exit(1);
  }
}

// Run the main function
scrapeWebsite();
