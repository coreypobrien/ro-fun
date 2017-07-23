'''Reeeeally basic get/set redis app'''
from flask import Flask, Blueprint, request
import redis


BP = Blueprint('flaskr', __name__)
DB = redis.StrictRedis(host='redis', port=6379, db=0)


@BP.route('/')
def list_keys():
    '''list keys'''
    keys = DB.keys()
    return bytes.join(b'\n', keys).decode('utf-8') + '\n'


@BP.route('/<key>', methods=['GET', 'POST'])
def key_op(key):
    '''set/get specific key'''
    if request.method == 'POST':
        DB.set(key, request.get_data(as_text=False))
        return 'Roger Roger\n'
    else:
        val = DB.get(key)
        return 'Sorry, no key found ¯\_(ツ)_/¯\n' if val is None else val.decode('utf-8')


app = Flask('demo')
app.register_blueprint(BP)
