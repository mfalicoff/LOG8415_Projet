import datetime
import random
from urllib.parse import unquote

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
app.logger.setLevel(logging.DEBUG)

# Load environment variables from the .env file
app.logger.info(f"Loading environment variables from .env file {os.getenv('ENVIRONMENT')}")
if os.getenv("ENVIRONMENT") == "production":
    load_dotenv(".env.remote")
else:
    load_dotenv(".env.local")

# Define constants
MYSQL_DEFAULT_PORT = 3306

# Access environment variables
proxy_ip = os.getenv("PROXY_PUBLIC_IP")
manager_ip = os.getenv("MANAGER_PRIVATE_IP")
worker1_ip = os.getenv("WORKER1_PUBLIC_IP")
worker2_ip = os.getenv("WORKER2_PUBLIC_IP")
worker3_ip = os.getenv("WORKER3_PUBLIC_IP")
ssh_key_path = os.getenv("SSH_KEY_LOCATION")

# Manager node MySQL information
MYSQL_USER = "ubuntu"
MYSQL_PASSWORD = "root"
MYSQL_DB = "sakila"

all_ips = [manager_ip, worker1_ip, worker2_ip, worker3_ip]

app.logger.info(
    f'''
    Starting proxy server with the following configuration:
    Proxy IP: {proxy_ip}
    Manager IP: {manager_ip}
    Worker 1 IP: {worker1_ip}
    Worker 2 IP: {worker2_ip}
    Worker 3 IP: {worker3_ip}
    SSH Key Path: {ssh_key_path}
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


def create_mysql_connection(ssh_ip, mysql_host, query):
    print(f"Connecting to {ssh_ip} and forwarding to {mysql_host}")
    try:
        with SSHTunnelForwarder(
                ssh_ip,
                ssh_username=MYSQL_USER,
                ssh_pkey=paramiko.RSAKey.from_private_key_file(ssh_key_path),
                remote_bind_address=(manager_ip, MYSQL_DEFAULT_PORT)
        ) as tunnel:
            app.logger.debug("SSH tunnel established successfully.")

            conn = pymysql.connect(
                host=manager_ip,
                port=MYSQL_DEFAULT_PORT,
                user=MYSQL_USER,
                password=MYSQL_PASSWORD,
                database=MYSQL_DB,
            )
            if conn is None:
                app.logger.error("Failed to establish MySQL connection.")
                return

            app.logger.debug("MySQL connection successful.")
            app.logger.debug(query)
            cursor = conn.cursor()
            cursor.execute(query)

            conn.commit()
            results = cursor.fetchall()
            if results is None:
                app.logger.error("Query returned no results.")
                return

            app.logger.debug(f"Results fetched: {results}")

            if cursor.description is not None:
                app.logger.error("Cursor description is None.")
                columns = [column[0] for column in cursor.description]
                return [dict(zip(columns, row)) for row in results]

            return []

    except pymysql.Error as e:
        app.logger.error(f"Error: {str(e)}")


@app.route('/', methods=['GET'])
def process_query_get():
    method_type = request.args.get('method_type')
    query = request.args.get('query')
    return execute_query(method_type, query)


@app.route('/', methods=['POST'])
def process_query_post():
    method_type = request.args.get('method_type')
    query = request.args.get('query')
    return execute_query(method_type, query)


@app.route('/', methods=['DELETE'])
def process_query_delete():
    method_type = request.args.get('method_type')
    query = request.args.get('query')
    return execute_query(method_type, query)


@app.route('/', methods=['PUT'])
def process_query_put():
    method_type = request.args.get('method_type')
    query = request.args.get('query')
    return execute_query(method_type, query)


def execute_query(method_type, query):
    try:
        if method_type == 'direct':
            result = direct_mysql_connection(unquote(query))
        elif method_type == 'random':
            result = random_node(unquote(query))
        elif method_type == 'custom':
            result = customized_hit(unquote(query))
        else:
            return jsonify({'error': f'Invalid method type: {method_type}'})

        return jsonify({'result': result})
    except Exception as e:
        app.logger.error(f"Error: {str(e)}")
        return jsonify({'error': f'Error: {str(e)}'})


def direct_mysql_connection(query):
    # Use the direct connection function to execute the query and return the results.
    result = create_mysql_connection(manager_ip, manager_ip, query)
    return {
        f'Query': f'{query} executed with direct_mysql_connection',
        f'Result': result
    }


def random_node(query):
    # Use the SSH tunnel worker connection function to execute the query and return the results.
    result = create_mysql_connection(all_ips[random.randrange(0, 3)], manager_ip, query)
    return {
        f'Query': f'{query} executed with random_node',
        f'Result': result
    }


def customized_hit(query):
    # Use the function that selects the best node based on latency to execute the query
    # and return the results.
    lowest_ping_time = float('inf')
    best_node = None

    for worker_ip in all_ips:
        ping_time = ping3.ping(worker_ip, timeout=1)
        print(f"Ping time for {worker_ip}: {ping_time}")
        if ping_time is not None and ping_time < lowest_ping_time:
            lowest_ping_time = ping_time
            best_node = worker_ip
    app.logger.debug(f"The node with the lowest ping time is {best_node}")
    result = create_mysql_connection(best_node, manager_ip, query)
    return {
        f'Query': f'{query} executed with customized_hit',
        f'Result': result
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
