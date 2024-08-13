import requests
import os
from dotenv import load_dotenv
import json
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

# DB
connection_config = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'port': os.getenv('DB_PORT')
}

conn = mysql.connector.connect(**connection_config)

api_key = os.getenv('API_KEY')

def loadBooks(name):
    url = "http://localhost:443/scrapper/manganelo/explore?name=" + name

    payload = {}
    headers = {
    'api-key': api_key
    }

    response = requests.request("GET", url, headers=headers, data=payload)

    return json.loads(response.text)['books']

def fetchBookInfo(code):
    url = "http://localhost:443/scrapper/manganelo/manga/" + code + "/info"

    payload = {}
    headers = {
    'api-key': api_key
    }

    response = requests.request("GET", url, headers=headers, data=payload)

    return json.loads(response.text)

books = ["Death note", "Made in abyss"]

booksList = []

for book in books:
    responseBooks = loadBooks(book)
    for responseBook in responseBooks:
        booksList.append(fetchBookInfo(responseBook['code']))

# Insert in DB
cursor = conn.cursor()
for book in booksList:
    insert_query = """
    INSERT INTO books (name, code, cover_url, synopsis)
    VALUES (%s, %s, %s, %s)
    """

    # Execute the INSERT statement
    cursor.execute(insert_query, (book['name'], book['code'], book['coverUrl'], book['synopsis']))

conn.commit()

print(booksList)