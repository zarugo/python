import sys
import re
from glob import glob
import os

repo = 'fidtocas_20191207_0446.sav'
with open(repo) as repo:
    matches = []
    pattern = re.compile(r'^PNAINAR_VA')
    for line in repo.readlines():
        with open('pnainar.txt', 'a') as f:
            if pattern.search(line):
                f.write(line)
