import paramiko
import ping3
import pymysql
from sshtunnel import SSHTunnelForwarder
from dotenv import load_dotenv
import os

# Load environment variables from the .env file
load_dotenv(".env.local")

# Access environment variables
proxy_ip = os.getenv("PROXY_PUBLIC_IP")
manager_ip = os.getenv("MANAGER_PUBLIC_IP")
worker1_ip = os.getenv("WORKER1_PUBLIC_IP")
worker2_ip = os.getenv("WORKER2_PUBLIC_IP")
worker3_ip = os.getenv("WORKER3_PUBLIC_IP")
ssh_key_path = os.getenv("SSH_KEY_LOCATION")

# Manager node MySQL information
manager_mysql_host = manager_ip
manager_mysql_port = 3306
manager_mysql_user = "ubuntu"
manager_mysql_password = "root"
manager_mysql_db = "sakila"

def direct_hit():
    try:
        with SSHTunnelForwarder(
                manager_ip,
                ssh_username="ubuntu",
                ssh_pkey=paramiko.RSAKey.from_private_key_file(ssh_key_path),
                remote_bind_address=(manager_ip, 3306)
        ):
            conn = pymysql.connect(
                host=manager_mysql_host,
                port=manager_mysql_port,
                user=manager_mysql_user,
                password=manager_mysql_password,
                database=manager_mysql_db,
            )
            print("Connection successful!")

            # Create a cursor object to interact with the database
            cursor = conn.cursor()

            # Execute the query
            query = "SHOW FULL TABLES"
            cursor.execute(query)

            # Fetch the results
            results = cursor.fetchall()

            # Display the results
            for result in results:
                print(result)

    except pymysql.Error as e:
        print(f"Error: {str(e)}")


def random():
    try:
        with SSHTunnelForwarder(
                worker3_ip,
                ssh_username="ubuntu",
                ssh_pkey=paramiko.RSAKey.from_private_key_file(ssh_key_path),
                remote_bind_address=(manager_ip, 3306)
        ):
            conn = pymysql.connect(
                host=manager_mysql_host,
                port=manager_mysql_port,
                user=manager_mysql_user,
                password=manager_mysql_password,
                database=manager_mysql_db,
            )
            print("Connection successful!")

            # Create a cursor object to interact with the database
            cursor = conn.cursor()

            # Execute the query
            query = "SHOW FULL TABLES"
            cursor.execute(query)

            # Fetch the results
            results = cursor.fetchall()

            # Display the results
            for result in results:
                print(result)

    except pymysql.Error as e:
        print(f"Error: {str(e)}")

def customized_hit():
    # Measure ping times and forward the request to the node with the least response time
    lowest_ping_time = float('inf')
    best_node = None

    ping_manager = ping3.ping(manager_ip, timeout=1)
    ping1 = ping3.ping(worker1_ip, timeout=1)
    ping2 = ping3.ping(worker2_ip, timeout=1)
    ping_3 = ping3.ping(worker3_ip, timeout=1)
    print(ping_manager, ping1, ping2, ping_3)


if __name__ == "__main__":
    direct_hit()
    random()
    customized_hit()
