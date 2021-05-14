from flask import Flask, json, request, abort, make_response, jsonify
from datetime import datetime, date
import os.path
from flask.json import JSONEncoder
from shutil import copyfile
from flask_cors import CORS, cross_origin

class CustomJSONEncoder(JSONEncoder):
    def default(self, obj):
        try:
            if isinstance(obj, date):
                return obj.isoformat(timespec='seconds')
            iterable = iter(obj)
        except TypeError:
            pass
        else:
            return list(iterable)
        return JSONEncoder.default(self, obj)


api = Flask(__name__)
cors = CORS(api)
api.config['CORS_HEADERS'] = 'Content-Type'
api.json_encoder = CustomJSONEncoder
series = []

@api.route("/series", methods = ["GET"])
@cross_origin()
def get_series():
    return jsonify(series)

@api.route("/series", methods = ["POST"])
@cross_origin()
def post_series():
    print(request.json)

    if not request.json:
        abort(404)

    serie = {
        'ID': 1 if series == [] else series[-1]['ID'] + 1,
        'Comment': request.json.get('Comment', ''),
        'Episode': request.json.get('Episode', 0),
        'Link': request.json.get('Link', ''),
        'Name': request.json.get('Name', ''),
        'Paused': request.json.get('Paused', False),
        'Season': request.json.get('Season', 1),
        'Time': request.json.get('Time', datetime.now().isoformat(timespec='seconds')),
        'Tor': request.json.get('Tor', True),
        'Changed': datetime.now().isoformat(timespec='seconds')
    }

    series.append(serie)
    updateFile()

    return jsonify({'ID': serie['ID'], 'Changed': serie['Changed']}), 201

@api.route("/series/<int:id>", methods = ["PUT"])
@cross_origin()
def put_series(id):
    if not request.json or id < 1 or len(series) == 0 or not 'Changed' in request.json:
        abort(404)

    serie = [serie for serie in series if serie['ID'] == id][0]
    print(series)
    print(serie)
    print(datetime.fromisoformat(request.json['Changed']))
    print(datetime.fromisoformat(serie['Changed']))

    if datetime.fromisoformat(request.json['Changed']) < datetime.fromisoformat(serie['Changed']):
        return jsonify({'error', 'First merge, than update'}), 400

    serie['Comment'] = request.json.get('Comment', '')
    serie['Episode'] = request.json.get('Episode', 0)
    serie['Link'] = request.json.get('Link', '')
    serie['Name'] = request.json.get('Name', '')
    serie['Paused'] = request.json.get('Paused', False)
    serie['Season'] = request.json.get('Season', 1)
    serie['Time'] = request.json.get('Time', datetime.strptime('00:00:00', '%H:%M:%S'))
    serie['Tor'] = request.json.get('Tor', True)
    serie['Changed'] = datetime.now().isoformat(timespec='seconds')

    updateFile()

    return jsonify({'Changed': serie['Changed']}), 200

@api.route("/series/<int:id>", methods = ["DELETE"])
@cross_origin()
def delete_series(id):
    if id < 1 or len(series) == 0:
        abort(404)

    #series.remove()

    serie = [serie for serie in series if serie['ID'] == id][0]
    print(serie)
    series.remove(serie)
    updateFile()
    
    return "", 200

@api.errorhandler(404)
@cross_origin()
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

def updateFile():
    if os.path.isfile("series.json"):
        copyfile("series.json", "series.json.bak")

    with open("series.json", "w+") as f:
        f.write(json.dumps(series))

if __name__ == '__main__':
    if os.path.isfile("series.json"):
        with open("series.json", "r") as f:
            series = json.loads(f.readline())

    api.run(host= '0.0.0.0')
