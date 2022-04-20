import os
import sys
import glob
from shutil import rmtree


def resourcePath(relative_path: str):  # Get a relative-based path, safe for final bundles
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)


def cleanPreviousTemps():  # Delete any previous temporary unpacks of the executable
    cwd = resourcePath('')
    for item in glob.glob(os.path.join(os.path.abspath(
            os.path.join(cwd, '..')), '_MEI*')):
        if item != cwd[:-1]:
            rmtree(item)
