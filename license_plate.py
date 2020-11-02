#!/usr/bin/env python3

import psycopg2
import sys
import os
import base64
from datetime import datetime

now = datetime.now()
if os.name == "nt":
    path = os.getcwd() + "\\LPR_images_" + now.strftime("%Y-%m-%d_%H-%M-%S")
else:
    path = "./LPR_images_" + now.strftime("%Y-%m-%d-%H:%M:%S")


try:
    os.mkdir(path)
except OSError:
    print ("Creation of the directory %s failed" % path)
    sys.exit(1)
os.chdir(path)
user = 'jbl'
password = 'jbl'
host = '127.0.0.1'
port = '5432'
in_ts = int(sys.argv[1])
fin_ts = int(sys.argv[2])
camera_list = tuple(sys.argv[3:])
query_cam = 'SELECT peripheral_id FROM jps_authenticated_device WHERE id IN (SELECT jps_authenticated_device_id FROM lpr_cameras WHERE uuid = %s)'
query_img = 'SELECT creation_date_ts, image_base_64, confidence, original_licence_plate, uuid FROM lpr_camera_recognitions WHERE creation_date_ts BETWEEN %s AND %s AND uuid IN %s'

def create_images():
        try:
            conn = psycopg2.connect(user=user, password=password, host=host, port=port, database='jbl')
            cur = conn.cursor()
            cur.execute(query_img, (in_ts, fin_ts, camera_list,))
            for row in cur:
                #print(row[1])
                s = int(row[0]) / 1000
                date = datetime.fromtimestamp(s).strftime('%Y-%m-%d_%H-%M-%S')
                cur2 = conn.cursor()
                cur2.execute(query_cam, (row[4],))
                camera = cur2.fetchone()
                filename = "confidence_" + str(row[2]) + "_" + row[3] + "_date_" + date + "_camera_" + str(camera[0]) + ".jpg"
                try:
                    with open(filename, "wb" ) as image:
                        #print(result[1])
                        image.write(base64.b64decode(row[1]))
                except OSError:
                    print("The file \"" + filename + "\" could not be created (probably unallowed characters on name)")

                cur2.close()
            cur.close()
            conn.close()
        except (Exception, psycopg2.Error) as error :
            print ("Error while connecting to PostgreSQL", error)

create_images()
