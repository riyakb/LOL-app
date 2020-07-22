This folder contains all the data related files

1. lol_app_db_schema.png: The schema diagram

2. lol_app_schema.sql: sql commands to build the schema in diagram

3. connection_details: database connection details (host, user, password)

4. create_database.py: script that creates database with given name using connection details
    Usage: python3 create_database.py <db_name>

5. generate_data.py: script that generated random data with given parameters using connection details
    Usage: python3 generate_data.py <db_name> <no_of_users> <no_of_memes> <no_of_topics>

