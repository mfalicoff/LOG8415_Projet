import datetime
import random
import paramiko
import ping3
import pymysql
from sshtunnel import SSHTunnelForwarder
from dotenv import load_dotenv
import os
from flask import Flask, request, jsonify
import logging
from logging.handlers import RotatingFileHandler

app = Flask(__name__)

# Configure the logger
handler = RotatingFileHandler('logs/app.log', maxBytes=10000, backupCount=1)
formatter = logging.Formatter('%(asctime)s [%(levelname)s] - %(message)s')
handler.setFormatter(formatter)
app.logger.addHandler(handler)

# Set the logging level (you can adjust this based on your needs)
app.logger.setLevel(logging.INFO)

# Load environment variables from the .env file
app.logger.info(f"Loading environment variables from .env file {os.getenv('ENVIRONMENT')}")
if os.getenv("ENVIRONMENT") == "production":
    load_dotenv(".env.remote")
else:
    load_dotenv(".env.local")

# Access environment variables
proxy_ip = os.getenv("PROXY_PUBLIC_IP")

app.logger.info(
    f'''
    Starting proxy server with the following configuration:
    Proxy IP: {proxy_ip}
    ''')


@app.before_request
def log_request_info():
    timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    app.logger.info(
        '%s %s %s %s %s',
        timestamp,
        request.remote_addr,
        request.method,
        request.scheme,
        request.full_path
    )


@app.after_request
def after_request(response):
    timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    app.logger.info(
        '%s %s %s %s %s %s',
        timestamp,
        request.remote_addr,
        request.method,
        request.scheme,
        request.full_path,
        response.status
    )
    return response

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
