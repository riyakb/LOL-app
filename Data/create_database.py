import mysql.connector
import sys

if(len(sys.argv)!=2):
    print("Usage: python3 create_database.py <db_name>")
    exit()

db_name=sys.argv[1]

connection_params=dict(entry.split('=') for entry in open('connection_details').read().split(','))

connection = mysql.connector.connect(**connection_params)

cursor = connection.cursor()

cursor.execute("CREATE DATABASE "+db_name)

connection.commit()
connection.close()