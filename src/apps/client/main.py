import os

import requests
import json

from dotenv import load_dotenv

# Base URL of the server
load_dotenv(".env")

# Access environment variables
gatekeeper_ip = os.getenv("GATEKEEPER_PUBLIC_IP")
base_url = f'http://{gatekeeper_ip}/raw'  # Replace with your server's address


# Function to send a query to the server
def send_query(query):
    params = {'query': query}
    response = requests.get(base_url, params=params)
    print(response.text)
    return response.json()


# Example queries
queries = [
    "select * from actor where first_name = 'Scarlett'",
    "select * from actor where last_name like 'Johansson'",
    "select count(distinct last_name) from actor",
    "select last_name from actor group by last_name having count(*) = 1",
    "select last_name from actor group by last_name having count(*) > 1",
    "select actor.actor_id, actor.first_name, actor.last_name, count(actor_id) as film_count from actor join film_actor using (actor_id) group by actor_id order by film_count desc limit 1",
]

# Sending each query and printing the response
for query in queries:
    result = send_query(query)
    print(f"Query: {query}\nResult: {json.dumps(result, indent=4)}\n")
