import datetime
import logging
import os
import re
from logging.handlers import RotatingFileHandler
from urllib.parse import quote

import requests
from dotenv import load_dotenv
from flask import Flask, request, jsonify

app = Flask(__name__)

# Configure the logger
handler = RotatingFileHandler('logs/app.log', maxBytes=10000, backupCount=1)
formatter = logging.Formatter('%(asctime)s [%(levelname)s] - %(message)s')
handler.setFormatter(formatter)
app.logger.addHandler(handler)

app.logger.setLevel(logging.INFO)

app.logger.info(f"Loading environment variables from .env file {os.getenv('ENVIRONMENT')}")
load_dotenv(".env")

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
        if not is_safe_sql(query):
            app.logger.error(f'Forbidden query: {query}')
            return jsonify({'message': f'Forbidden query: {query}'})

        method_type_url = f"?method_type={method_type}&" if method_type else "?"
        url = f'http://{proxy_ip}{method_type_url}query={quote(query)}'
        app.logger.info(f'Executing query: {url}')
        headers = {'Content-Type': 'application/json'}

        response = requests.request(method, url, headers=headers)
        app.logger.info(f'Received response: {response}')
        return response.json()
    except Exception as e:
        app.logger.error(f'Error executing query: {e}')
        return jsonify({'message': f'Error executing query: {e}'})


def is_safe_sql(query):
    # List of allowed tables for INSERT, UPDATE, and DELETE operations
    allowed_tables = [
        "actor", "address", "category", "city", "country",
        "customer", "film", "film_actor", "film_category",
        "film_text", "inventory", "language", "payment",
        "rental", "staff", "store"
    ]

    query_lower = query.lower()

    # Check for forbidden keywords except for INSERT, UPDATE, and DELETE
    forbidden_keywords = ["drop", "exec", "execute", "create", "alter", "grant", "revoke", "truncate"]

    for keyword in forbidden_keywords:
        if keyword in query_lower:
            return False

    # Check if the operation is for an allowed table
    if any(keyword in query_lower for keyword in ["insert", "update", "delete"]):
        table_name_pattern = r'(insert into|update|delete from)\s+(\w+)'
        match = re.search(table_name_pattern, query_lower)
        if not match or match.group(2) not in allowed_tables:
            return False

    # Basic check for SQL injection patterns
    sql_injection_patterns = [
        r'--',
        r';',
        r'\/\*',
        r'\bOR\b',
        r'\bAND\b',
    ]

    for pattern in sql_injection_patterns:
        if re.search(pattern, query_lower):
            return False

    return True


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
