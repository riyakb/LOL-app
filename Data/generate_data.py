import mysql.connector
import sys
import string 
import random 
from datetime import datetime  
from datetime import timedelta  

if(len(sys.argv)!=5):
    print("Usage: python3 generate_data.py <db_name> <no_of_users> <no_of_memes> <no_of_topics>")
    exit()

db_name=sys.argv[1]
no_of_users=int(sys.argv[2])
no_of_memes=int(sys.argv[3])
no_of_topics=int(sys.argv[4])
reactions=['dislike','like','rofl']

connection_params=dict(entry.split('=') for entry in open('connection_details').read().split(','))
connection_params['database']=db_name

connection=mysql.connector.connect(**connection_params)
cursor = connection.cursor()

sqlfile_commands=open('lol_app_schema.sql').read().split(';')
for command in sqlfile_commands:
    cursor.execute(command)


topics=[]
for _ in range(no_of_topics): 
    topic=''.join(random.choices(string.ascii_letters,k=20))
    topics.append(topic)

for i in range(no_of_users):
    name=''.join(random.choices(string.ascii_letters, k = 15)) 
    email_id=''.join(random.choices(string.ascii_letters + string.digits, k = 15)) 
    password=''.join(random.choices(string.ascii_letters + string.digits, k = 15)) 
    signup_time=str(datetime.now()+timedelta(days=random.randint(0,30)))
    cursor.execute("INSERT INTO `users` (`name`,`email_id`,`password`,`signup_time`) VALUES (%s,%s,%s,%s);" , (name, email_id, password, signup_time))

    for topic in topics:
        if random.randint(0,1):
            cursor.execute("INSERT INTO `user_topics` (`user_id`,`topic`) VALUES (%s,%s);" , (str(i+1),topic))

for i in range(no_of_memes): 
    upload_time=str(datetime.now()+timedelta(days=random.randint(0,30)))
    data=''.join(random.choices(string.ascii_letters + string.digits, k = 30)) 
    upload_userid=str(random.randint(1,no_of_users))
    cursor.execute("INSERT INTO `memes` (`upload_time`,`data`,`upload_user_id`) VALUES (%s,%s,%s);" , (upload_time,data,upload_userid))

    for topic in topics:
        if random.randint(0,1):
            cursor.execute("INSERT INTO `meme_topics` (`meme_id`,`topic`) VALUES (%s,%s);" , (str(i+1),topic))
    
    for j in range(no_of_users):
        if random.randint(0,1):
            reaction=random.choice(reactions)
            cursor.execute("INSERT INTO `user_meme_interaction` (`user_id`,`meme_id`,`reaction`) VALUES (%s,%s,%s);" , (str(j+1),str(i+1),reaction))



connection.commit()
connection.close()