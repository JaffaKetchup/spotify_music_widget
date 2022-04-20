import random


_lastTrackId = None


def getInfo(resp):
    global _lastTrackId

    # Safely respond nothing if music is stopped - Flutter app deals with this
    if resp is None:
        return {}

    # Safely get properties for a track which may not exist if the track is local
    rawId = resp['item']['id']
    rawImages = resp['item']['album']['images']
    rawLinks = resp['item']['external_urls']

    # Calculate whether the last known playing track is the current track
    # A random ID is generated if the track is local
    id = rawId if rawId is not None else random.randint(0, 1000000000000)
    isNew = id != _lastTrackId
    _lastTrackId = id

    return {
        'new': isNew,
        'id': id,
        'name': resp['item']['name'],
        'artists': ', '.join(map(lambda artist: artist['name'], resp['item']['artists'])),
        'image': rawImages[0]['url'] if len(rawImages) >= 1 else '',
        'link': rawLinks['spotify'] if rawLinks != {} else '',
        'timing': {
            'elapsed': resp['progress_ms'],
            'duration': resp['item']['duration_ms'],
        },
    }
