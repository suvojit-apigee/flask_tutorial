from flask import Flask, render_template, request
import requests
import json
import os
from dotenv import load_dotenv

load_dotenv()


HOST_URL = os.getenv("HOST_URL", "http://localhost:5000")

app = Flask(__name__)

@app.route("/health")
def health():
    return "OK", 200

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/register', methods=['POST'])
def submit_form():
    name = request.form.get('username')
    password = request.form.get('password')
    email = request.form.get('email')
    phoneNumber = request.form.get('phone')

    print(f"Received username: {name}, password: {password}, email: {email}, phoneNumber: {phoneNumber}")
    form_data = dict(request.form)
    response = requests.post(f"{HOST_URL}/api/register", json=form_data)
    print(f"Received response: {json.dumps(response.json(), indent=2)}")
    return response.json()
    

@app.route('/api/users', methods=['GET'])
def view_data():
    response = requests.get(f"{HOST_URL}/api/users")
    data_list = response.json().get("data", [])
    message = response.json().get("message", "")
    httpStatus = response.json().get("status", "")
    print(f"Received data: {data_list}, message: {message}, status: {httpStatus}")
    return response.json()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)