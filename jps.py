import sys
import json
import requests
import paramiko
import shutil
import os
import re
from glob import glob

class JpsDevice(ip):
    def __init__(self):


    url = "http://" + device + ":65000/jps/api/status"
