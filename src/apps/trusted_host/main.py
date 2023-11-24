import datetime
import random
import paramiko
import ping3
import pymysql
import requests
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
load_dotenv(".env")

# Access environment variables
proxy_ip = os.getenv("PROXY_PRIVATE_IP")

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


@app.route('/new_request', methods=['GET', 'POST', 'PUT', 'DELETE'])
def new_request():
    method_type = request.args.get('method_type')
    query = request.args.get('query')
    return execute_query(method_type, query, request.method)


def execute_query(method_type, query, method):
    try:
        url = f'http://{proxy_ip}/?method_type={method_type}&query={query}'
        headers = {'Content-Type': 'application/json'}

        response = requests.request(method, url, headers=headers)
        return response.json()
    except Exception as e:
        app.logger.error(f'Error executing query: {e}')
        return jsonify({'message': f'Error executing query: {e}'})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
