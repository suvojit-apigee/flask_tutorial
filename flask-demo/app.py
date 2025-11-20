from flask import Flask
from flask import render_template
from datetime import datetime

app = Flask(__name__)

@app.route('/api/time')
def homepage():
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return render_template('index.html', time=current_time)
    #return {'current_time': current_time}

if __name__ == '__main__':
    app.run(debug=True)