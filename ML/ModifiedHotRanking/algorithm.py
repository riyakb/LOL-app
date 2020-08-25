import datetime
from math import log10

reaction_weights=[-1,1,5]
fixed_timestamp=datetime.datetime(2020,8,1)
time_weight=1/45000


def hot_ranking_computation(reactions, timestamp):
	s=reactions[0]*reaction_weights[0]+reactions[1]*reaction_weights[1]+reactions[2]*reaction_weights[2]
	order=log10(max(abs(s), 1))
	if s > 0:
		sign=1
	elif s < 0:
		sign=-1
	else:
		sign=0
	seconds=(timestamp-fixed_timestamp).total_seconds()
	return order+sign*seconds*time_weight

def modified_hot_ranking_computation(reactions, timestamp, user_topics, meme_topics):
	hot_ranking_score=hot_ranking_computation(reactions,timestamp)
	n=len(meme_topics)
	ni=len(set(meme_topics)&set(user_topics))
	nj=n-ni
	if n==0:
		return hot_ranking_score
	return hot_ranking_score*(ni+0.1*nj)/n

