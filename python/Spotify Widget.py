import time
import socket
import json
import os
import sys
import subprocess
import spotipy
import shutil
from threading import Timer
from spotipy.oauth2 import SpotifyOAuth

import comms
import utils

CLIENT_ID_PATH = 'credentials/id.txt'
CLIENT_SECRET_PATH = 'credentials/secret.txt'


def main():
    # Clean up previous extractions of bundle
    utils.cleanPreviousTemps()

    # Automatically extract important information
    if not os.path.exists('README.md'):
        shutil.copyfile(utils.resourcePath('extract/README.md'), 'README.md')
    if (not os.path.exists('LICENSE.txt')) and (not os.path.exists('LICENSE')):
        shutil.copyfile(utils.resourcePath('extract/LICENSE'), 'LICENSE.txt')

    # Automatically setup authentication filesystem
    if (not os.path.exists(CLIENT_ID_PATH)) or (not os.path.exists(CLIENT_SECRET_PATH)):
        try:
            os.makedirs('credentials/')
        except:
            print('\'credentials\' directory already existed')

        _id = open(CLIENT_ID_PATH, 'w')
        _id.write(
            'PASTE YOUR SPOTIFY DEVELOPER APP ID HERE (https://developer.spotify.com/dashboard/applications)')
        _id.close()

        _secret = open(CLIENT_SECRET_PATH, 'w')
        _secret.write(
            'PASTE YOUR SPOTIFY DEVELOPER APP SECRET HERE (https://developer.spotify.com/dashboard/applications)')
        _secret.close()

        sys.exit()

    with open(CLIENT_ID_PATH, 'r') as id, open(CLIENT_SECRET_PATH, 'r') as secret:
        # Attempt authentication with Spotify, without user interaction if possible
        try:
            sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=id.read(),
                                                           client_secret=secret.read(),
                                                           redirect_uri="http://localhost:8080",
                                                           scope="user-read-currently-playing user-read-playback-position",
                                                           cache_path='credentials/.cache',
                                                           ))

        except:
            os.remove('.cache')
            time.sleep(2)
            main()

        # Setup connection to Flutter application
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('127.0.0.1', 65535))
            s.listen()

            # Start Flutter application for auto-connection
            if len(sys.argv) < 2 or sys.argv[1] != 'manual':
                Timer(1, lambda: subprocess.run(
                    utils.resourcePath('app/spotify_music_widget.exe'))).start()

            conn, _ = s.accept()
            with conn:
                while True:
                    # Get formatted information from Spotify API
                    info = comms.getInfo(
                        sp.currently_playing())

                    # Send information as JSON to Flutter application via socket
                    conn.sendall(json.dumps(info).encode())

                    # Wait for appropriate amount of time until next API request
                    sleepable = ((info['timing']['duration'] -
                                  info['timing']['elapsed']) / 1000) if info != {} else 9
                    time.sleep((sleepable - 12) if (sleepable - 12 >= 0)
                               else (sleepable + 1))


if __name__ == '__main__':
    main()
