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

book_authors = {}
book_categories = {}

# Insert in DB
cursor = conn.cursor()
for book in booksList:
    insert_query = """
    INSERT INTO books (name, code, cover_url, synopsis)
    VALUES (%s, %s, %s, %s);
    """

    # INSERT book
    cursor.execute(insert_query, (book['name'], book['code'], book['coverUrl'], book['synopsis']))
    generated_id = cursor.lastrowid

    for author in book['authors']:
        if not author in book_authors.keys():
            book_authors[author] = set()
        
        book_authors[author].add(generated_id)

    for category in book['categories']:
        if not author in book_categories.keys():
            book_categories[category] = set()
        
        book_categories[category].add(generated_id)


for author in book_authors.keys():
    insert_query = """
    INSERT INTO authors (name)
    VALUES (%s);
    """

    cursor.execute(insert_query, [author])
    generated_id = cursor.lastrowid

    for book_id in book_authors[author]:
        insert_query = """
        INSERT INTO book_authors (book_id, author_id)
        VALUES (%s,%s);
        """

        cursor.execute(insert_query, [book_id, generated_id])

for category in book_categories.keys():
    insert_query = """
    INSERT INTO categories (name)
    VALUES (%s);
    """

    cursor.execute(insert_query, [category])
    generated_id = cursor.lastrowid

    for category_id in book_categories[category]:
        insert_query = """
        INSERT INTO book_categories (book_id, category_id)
        VALUES (%s,%s);
        """

        cursor.execute(insert_query, [category_id, generated_id])

#conn.commit()
conn.close()