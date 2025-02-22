import subprocess
import pathlib
import os

images = [16, 32, 64, 128, 256, 512, 1024]

for i in images:
    subprocess.call(["qlmanage", '-t', '-s', str(i), '-o', '.', 'cursor.svg'])

    os.rename('cursor.svg.png', 'cursor_%dx.png' %(i))
