import mysql.connector
import datetime
from algorithm import modified_hot_ranking_computation

def read_and_write_db():

	connection_params=dict(entry.split('=') for entry in open('connection_details').read().split(','))
	connection_params['database']=db_name

	connection=mysql.connector.connect(**connection_params)
	cursor = connection.cursor()


	cursor.execute("CREATE VIEW `dislikes` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=3 GROUP BY meme_id;")
	cursor.execute("CREATE VIEW `likes` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=2 GROUP BY meme_id;")
	cursor.execute("CREATE VIEW `rofls` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=1 GROUP BY meme_id;")

	cursor.execute("SELECT user_id, meme_id FROM user_meme_interaction;")

	rows= cursor.fetchall()

	for row in rows:
		user_id=row[0]
		cursor.execute("SELECT topic FROM user_topics WHERE user_id=%s;",(user_id))
		user_topics_rows=cursor.fetchall()
		user_topics=[]
		for urow in user_topics_rows:
			user_topics.append(urow[0])

		meme_id=row[1]
		cursor.execute("SELECT topic FROM meme_topics WHERE meme_id=%s;",(meme_id))
		meme_topics_rows=cursor.fetchall()
		meme_topics=[]
		for mrow in meme_topics_rows:
			meme_topics.append(mrow[0])

		reactions=[]
		cursor.execute("SELECT c FROM dislikes WHERE meme_id=%s;",(meme_id))
		reactions.append(cursor.fetchone()[0])
		cursor.execute("SELECT c FROM likes WHERE meme_id=%s;",(meme_id))
		reactions.append(cursor.fetchone()[0])
		cursor.execute("SELECT c FROM rofls WHERE meme_id=%s;",(meme_id))
		reactions.append(cursor.fetchone()[0])

		cursor.execute("SELECT upload_time FROM memes WHERE id=%s",(meme_id))
		timestamp=cursor.fetchone()[0]

		score=str(modified_hot_ranking_computation(reactions, timestamp, user_topics, meme_topics))

		cursor.execute("UPDATE user_meme_interaction SET score=%s WHERE user_id=%s, meme_id=%s;",(score,user_id,meme_id))
		

	connection.commit()
	connection.close()