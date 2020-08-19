from threading import Thread, Lock
import psycopg2
import sys
import logging
from time import sleep

class DatabaseWorker(Thread):
    __lock = Lock()

    def __init__(self, db, query, result_queue):
        Thread.__init__(self)
        self.db = db
        self.query = query
        self.result_queue = result_queue

    def run(self):
        result = None
        logging.info("Connecting to database...")
        try:
            conn = psycopg2.connect(user='postgres', password='SsaRpeDP', host='172.29.0.160', port='5432', database=self.db)
            curs = conn.cursor()
            curs.execute(self.query)
            result = curs
            curs.close()
            conn.close()
        except Exception as e:
            logging.error("Unable to access database %s" % str(e))
        self.result_queue.append(result)

delay = 1
result_queue = []

for i in range(int(sys.argv[2])):
    worker = DatabaseWorker(sys.argv[1], "SELECT pg_sleep(180)", result_queue)
    worker.start()

# Wait for the job to be done
while len(result_queue) < 2:
    sleep(delay)
job_done = True
worker.join()
