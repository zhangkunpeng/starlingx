import openstack
import os, time, threading
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello, World!"

@app.route('/openvino/<name>')
def update_data(name):
    timer = threading.Timer(1, update_image, [name])
    timer.start()
    return "ok"

def update_image(name):
    conn = openstack.connect(cloud='central')
    for i in range(10):
        t = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        filename = name+"/"+str(t)+'.png'
        obj = conn.create_object("openvino",filename, filename="demo.png")
        print("upload file:"+filename)
        time.sleep(3)

if __name__ == '__main__':
    app.run(debug=True,port=8305,host='0.0.0.0')