import psycopg2
import os

def get_username():
    # Read username from environment variable
    username = os.getenv("GAME_USERNAME")
    if not username:
        raise ValueError("No username provided. Set the GAME_USERNAME environment variable.")
    return username

def store_username(username):
    try:
        connection = psycopg2.connect(
            user="admin",
            password="admin",
            host="postgres-service",
            port="5432",
            database="mydatabase"
        )
        cursor = connection.cursor()
        cursor.execute("INSERT INTO users (username) VALUES (%s)", (username,))
        connection.commit()
    except Exception as error:
        print(f"Error storing username: {error}")
    finally:
        if connection:
            cursor.close()
            connection.close()

def main():
    try:
        username = get_username()
        store_username(username)
        print("Username stored successfully!")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
