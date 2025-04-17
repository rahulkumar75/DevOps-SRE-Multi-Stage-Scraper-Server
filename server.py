from flask import Flask, jsonify
import json
import os

app = Flask(__name__)

DATA_FILE = 'scraped_data.json'

@app.route('/')
def home():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE) as f:
            data = json.load(f)
        return jsonify(data)
    else:
        return jsonify({"error": "Scraped data Not found"}), 404

@app.route('/health')
def health_check():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
