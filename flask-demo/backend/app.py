from flask import Flask
from flask import request
from flask import jsonify
import os
from dotenv import load_dotenv
import pymongo
from urllib.parse import quote_plus
from http import HTTPStatus
import json

load_dotenv()
mongo_uri = os.getenv("MONGO_URI")

# Parse and encode username and password if they contain special characters
if "@" in mongo_uri and "://" in mongo_uri:
    protocol, rest = mongo_uri.split("://", 1)
    if "@" in rest:
        credentials, host_part = rest.rsplit("@", 1)
        if "" in credentials:
            username, password = credentials.split(":", 1)
            mongo_uri = f"{protocol}://{quote_plus(username)}:{quote_plus(password)}@{host_part}"

print(f"Mongo URI: {mongo_uri}")

client = pymongo.MongoClient(mongo_uri)
db = client.user_management_db
collection = db['users']

app = Flask(__name__)

@app.route('/api/register', methods=['POST'])
def create_user():
    name = request.json.get('username')
    password = request.json.get('password')
    email = request.json.get('email')
    phone = request.json.get('phoneNumber')
    print(f"Received username: {name}, password: {password}, email: {email}, phoneNumber: {phone}")
    form_data = dict(request.json)
    print(f"Form data to insert: {form_data}")

    try:
        existing_user = collection.find_one({"username": name})
        if existing_user:
            response = {"username": name, "status": HTTPStatus.CONFLICT.value, "message": "User already exists"}
            print(f"Response Object: {json.dumps(response, indent=2)}")
        else:
            collection.insert_one(form_data)
            response = {"username": name, "status": HTTPStatus.OK.value, "message": "User created successfully"}
            print(f"Response Object: {json.dumps(response, indent=2)}")
    except Exception as e:
        print(f"Error occurred: {e}")
    return jsonify(response)

@app.route('/api/users', methods=['GET'])
def view_data():

    try:
        data = collection.find()
        list_data = list(data)
        for item in list_data:
            del item['_id']  # Remove ObjectId for cleaner display
        response = {"status": HTTPStatus.OK.value, "message": "Data retrieved successfully", "data": list_data}
        print(f"Response Object: {json.dumps(response, indent=2)}")
    except Exception as e:
        print(f"Error occurred: {e}")
        response = {"status": HTTPStatus.INTERNAL_SERVER_ERROR.value, "message": "An error occurred"}
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)