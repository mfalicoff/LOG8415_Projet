import datetime
from urllib.parse import quote

import requests
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
trusted_host_ip = os.getenv("TRUSTED_HOST_PUBLIC_IP")

app.logger.info(
    f'''
    Starting proxy server with the following configuration:
    Proxy IP: {trusted_host_ip}
    ''')


def sanitize(value):
    print(value)
    pass


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
    request_args = request.args.to_dict()
    for key, value in request_args.items():
        request_args[key] = sanitize(value)


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


@app.route('/')
def home():
    return "Welcome to the gatekeeper!"


@app.route('/film')
def list_movies():
    # Code to fetch and return all movies from the database
    query = "SELECT * FROM film"
    res = execute_query("direct", query, "GET")
    print(res)
    return res


@app.route('/movie/<int:movie_id>')
def movie_details(movie_id):
    # Code to fetch and return details of the specified movie
    query = f"SELECT * FROM movies WHERE id={movie_id}"
    execute_query("direct", query, "GET")
    return f"Details of movie {movie_id}"


@app.route('/actors')
def list_actors():
    # Code to fetch and return all actors from the database
    query = "SELECT * FROM actors"
    execute_query("direct", query, "GET")
    return "List of all actors"


@app.route('/actor/<int:actor_id>')
def actor_details(actor_id):
    # Code to fetch and return details of the specified actor
    query = f"SELECT * FROM actor WHERE actor_id={actor_id}"
    res = execute_query("direct", query, "GET")
    return f"Details of actor {res}"


@app.route('/search')
def search():
    # Code to perform search based on query parameters
    query = request.args.get('query')
    execute_query("direct", query, "GET")
    return "Search results"


@app.route('/customer/<int:customer_id>/rentals')
def customer_rentals(customer_id):
    # Code to fetch and list rentals for the specified customer
    query = f"SELECT * FROM rentals WHERE customer_id={customer_id}"
    execute_query("direct", query, "GET")
    return f"Rentals for customer {customer_id}"


@app.route('/add_film', methods=['POST'])
def add_movie():
    # Code to add a new movie to the database
    query = request.args.get('query')
    print(query)
    # test_query = "INSERT INTO film (title, language_id) VALUES ('test3', '1')"
    res = execute_query("direct", query, "POST")
    print(query, f"res:{res}")
    return res


@app.route('/raw', methods=['GET', 'POST', 'PUT', 'DELETE'])
def raw():
    # Code to send a raw request to the trusted host
    query = request.args.get('query')
    query.sanitize()
    execute_query("direct", query, "GET")
    return "Raw request"


def execute_query(method_type, query, method):
    try:
        encoded_query = quote(query)
        url = f'http://{trusted_host_ip}/new_request?method_type={method_type}&query={encoded_query}'
        print(url, encoded_query)

        headers = {'Content-Type': 'application/json'}

        response = requests.request(method, url, headers=headers)
        return response.json()
    except Exception as e:
        app.logger.error(f'Error executing query: {e}')
        return jsonify({'message': f'Error executing query: {e}'})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
