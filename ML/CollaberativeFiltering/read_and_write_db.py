import pandas as pd
import sqlalchemy
import datetime
from algorithm import modified_hot_ranking_computation
from collab import get_collab_score

connection_params = dict(entry.split('=') for entry in open('connection_details.txt').read().split(','))

db_user = connection_params['username']
db_pass = connection_params['password']
db_name = connection_params['database']
db_socket = connection_params['unix_socket']
db_host = connection_params['host']

def single_collab_score(df, user_id, meme_id, score_list):

	df1=df[df['user_id'] == user_id]
	idx=df1[df1['meme_id'] == meme_id].index[0]

	return score_list[idx]

def read_and_write_db():

	print("begin rw_db")
	
	db = sqlalchemy.create_engine(
			sqlalchemy.engine.url.URL(
					drivername="mysql+pymysql",
					username=db_user,  
					password=db_pass, 
					database=db_name,  
					host=db_host
			)
	)

	with db.connect() as conn:

		conn.execute("DROP TABLE IF EXISTS `dislikes`")
		conn.execute("DROP TABLE IF EXISTS `likes`")
		conn.execute("DROP TABLE IF EXISTS `rofls`")
		conn.execute("DROP VIEW IF EXISTS `dislikes`")
		conn.execute("DROP VIEW IF EXISTS `likes`")
		conn.execute("DROP VIEW IF EXISTS `rofls`")
		conn.execute("CREATE VIEW `dislikes` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=3 GROUP BY meme_id;")
		conn.execute("CREATE VIEW `likes` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=2 GROUP BY meme_id;")
		conn.execute("CREATE VIEW `rofls` AS SELECT meme_id, count(*) AS c FROM user_meme_interaction WHERE reaction=1 GROUP BY meme_id;")

		rows = conn.execute("SELECT user_id, meme_id, reaction FROM user_meme_interaction;").fetchall()
		#rows1 = conn.execute("SELECT user_id, meme_id, reaction FROM user_meme_interaction;").fetchall()

		df = pd.DataFrame(rows)
		df.columns=["user_id", "meme_id", "rating"]
		score_list = get_collab_score(df)


		for row in rows:
			user_id=row[0]
			user_topics_rows = conn.execute("SELECT topic FROM user_topics WHERE user_id=%s;",(user_id)).fetchall()
			user_topics=[]
			for urow in user_topics_rows:
				user_topics.append(urow[0])

			meme_id=row[1]
			meme_topics_rows = conn.execute("SELECT topic FROM meme_topics WHERE meme_id=%s;",(meme_id)).fetchall()
			meme_topics=[]
			for mrow in meme_topics_rows:
				meme_topics.append(mrow[0])

			reactions=[]
			
			cur_res = conn.execute("SELECT c FROM dislikes WHERE meme_id=%s;",(meme_id)).fetchone()
			if (cur_res != None):
				reactions.append(cur_res[0])
			else:
				reactions.append(0)
			
			cur_res = conn.execute("SELECT c FROM likes WHERE meme_id=%s;",(meme_id)).fetchone()
			if (cur_res != None):
				reactions.append(cur_res[0])
			else:
				reactions.append(0)
			
			
			cur_res = conn.execute("SELECT c FROM rofls WHERE meme_id=%s;",(meme_id)).fetchone()
			if (cur_res != None):
				reactions.append(cur_res[0])
			else:
				reactions.append(0)
			

			timestamp=(conn.execute("SELECT upload_time FROM memes WHERE id=%s;",(meme_id)).fetchone())[0]

			# score2=single_collab_score(df, user_id, meme_id, score_list)

			score1=modified_hot_ranking_computation(reactions, timestamp, user_topics, meme_topics)
			# print(score2)

			

			# weights=[1,1]
			# score=score1*weights[0]+score2*weights[1]
			conn.execute("UPDATE user_meme_interaction SET score=%s WHERE user_id=%s and meme_id=%s;",(score1,user_id,meme_id))