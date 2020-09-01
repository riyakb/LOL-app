from apscheduler.schedulers.blocking import BlockingScheduler
from read_and_write_db import read_and_write_db

scheduler = BlockingScheduler()
scheduler.add_job(read_and_write_db, 'interval', minutes=20)
scheduler.start()