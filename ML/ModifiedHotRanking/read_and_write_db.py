import sqlalchemy
import datetime
from algorithm import modified_hot_ranking_computation

def read_and_write_db():

	db = sqlalchemy.create_engine(
	    sqlalchemy.engine.url.URL(
	        drivername="mysql+pymysql",
	        username=db_user,  # e.g. "my-database-user"
	        password=db_pass,  # e.g. "my-database-password"
	        database=db_name,  # e.g. "my-database-name"
	        query={
	            "unix_socket": db_socket
	        }
	    )
	)

	conn = db.connect()

	conn.execute("CREATE VIEW `dislikes` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=3 GROUP BY meme_id;")
	conn.execute("CREATE VIEW `likes` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=2 GROUP BY meme_id;")
	conn.execute("CREATE VIEW `rofls` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=1 GROUP BY meme_id;")

	conn.execute("SELECT user_id, meme_id FROM user_meme_interaction;")

	rows= conn.fetchall()

	for row in rows:
		user_id=row[0]
		conn.execute("SELECT topic FROM user_topics WHERE user_id=%s;",(user_id))
		user_topics_rows=conn.fetchall()
		user_topics=[]
		for urow in user_topics_rows:
			user_topics.append(urow[0])

		meme_id=row[1]
		conn.execute("SELECT topic FROM meme_topics WHERE meme_id=%s;",(meme_id))
		meme_topics_rows=conn.fetchall()
		meme_topics=[]
		for mrow in meme_topics_rows:
			meme_topics.append(mrow[0])

		reactions=[]
		conn.execute("SELECT c FROM dislikes WHERE meme_id=%s;",(meme_id))
		reactions.append(conn.fetchone()[0])
		conn.execute("SELECT c FROM likes WHERE meme_id=%s;",(meme_id))
		reactions.append(conn.fetchone()[0])
		conn.execute("SELECT c FROM rofls WHERE meme_id=%s;",(meme_id))
		reactions.append(conn.fetchone()[0])

		conn.execute("SELECT upload_time FROM memes WHERE id=%s",(meme_id))
		timestamp=conn.fetchone()[0]

		score=str(modified_hot_ranking_computation(reactions, timestamp, user_topics, meme_topics))

		conn.execute("UPDATE user_meme_interaction SET score=%s WHERE user_id=%s, meme_id=%s;",(score,user_id,meme_id))
		

	db.close()