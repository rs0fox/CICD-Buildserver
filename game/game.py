import psycopg2
import sys

def get_username():
    return input("Enter your username: ")

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
    username = get_username()
    store_username(username)
    print("Username stored successfully!")

if __name__ == "__main__":
    main()
