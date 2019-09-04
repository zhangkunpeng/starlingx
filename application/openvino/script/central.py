import openstack,time

version="v0.0"
conn = openstack.connect(cloud='central')

def __screen_cut():
    os.system("gnome-screenshot -w -B --file=demo1.png")

def upload_image(dirname=None):
    __screen_cut()
    dirname = version
    t = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
    filename = dirname+"/"+str(t)+'.png'
    obj = conn.create_object("openvino",filename, filename="demo1.png")
    print("upload file:"+filename)

def get_version():
    obj_version = conn.get_object("openvino", "models/version.txt")
    return obj_version[1]

def check_version():
    new_version = get_version()
    if version != new_version:
        return new_version

if __name__ == "__main__":
    print(get_version()[:2])
    print(check_version())