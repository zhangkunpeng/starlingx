#!/bin/python
# Loop run the medels

import os
import time
import signal

def check_usb(usb_id):
    get_usb = 'lsusb'
    usb_info = ''
    for line in os.popen(get_usb):
        usb_info += str(line)
    if usb_id in usb_info:
        return True
    return False

def check_new_disk(disk_id):
    get_disk = 'lsblk'
    disk_info = ''
    for line in os.popen(get_disk):
	    disk_info += str(line)
    if disk_id in disk_info:
	    return True
    return False

def change_params(disk_id):
    global EMOTION
    global AGE
    if check_new_disk(disk_id):
        new_dir = '/home/ubuntu/' + disk_id
        if not os.path.isdir(new_dir):
            os.mkdir(new_dir)
        mount = 'sudo mount /dev/' + disk_id + '1' + ' ' + new_dir
        os.system(mount)
        for file_name in os.listdir(new_dir):
            if 'emotions' in file_name:
	        EMOTION = True
                if not os.path.isdir(model_path + file_name):
                    copy = 'sudo cp -r' + ' ' + new_dir + os.sep + file_name + ' '+ model_path
                    os.system(copy)        
            if 'age' in file_name:
	        AGE = True
                if not os.path.isdir(model_path + file_name):
                    copy = 'sudo cp -r' + ' ' + new_dir + os.sep + file_name + ' '+ model_path
                    os.system(copy)


MYRIAD = False
EMOTION = False
AGE = False

model_path = '/opt/intel/computer_vision_sdk/deployment_tools/intel_models/'

params = ['b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k']
for letter in params: 
    change_params('vd%s'%letter)
         
MYRIAD = check_usb('03e7')

os.environ['MODEL'] = '/opt/intel/computer_vision_sdk/deployment_tools/intel_models'

source = 'source /opt/intel/computer_vision_sdk/bin/setupvars.sh'

os.system(source)

os.environ['PYTHONPATH'] = "${PYTHONPATH}:/opt/movidius/caffe/python"

run = '/home/ubuntu/inference_engine_samples/intel64/Release/interactive_face_detection_demo'

fp = 'FP32'
add_info = ''
if MYRIAD:
    fp = 'FP16'

run_ads = '-m /opt/intel/computer_vision_sdk/deployment_tools/intel_models/face-detection-adas-0001/%s/face-detection-adas-0001.xml'%fp

run_emotion = '-m_em /opt/intel/computer_vision_sdk/deployment_tools/intel_models/emotions-recognition-retail-0003/%s/emotions-recognition-retail-0003.xml'%fp

run_age = '-m_ag /opt/intel/computer_vision_sdk/deployment_tools/intel_models/age-gender-recognition-retail-0013/%s/age-gender-recognition-retail-0013.xml'%fp

final_run = run + ' ' + run_ads
if MYRIAD:
    add_info += ' -d MYRIAD' 

if EMOTION: 
    final_run += ' ' + run_emotion
    if MYRIAD:
        add_info += ' -d_em MYRIAD'

if AGE:
    final_run += ' ' + run_age
    if MYRIAD:
        add_info += ' -d_ag MYRIAD'


final_run += add_info

os.system(final_run)

#time.sleep(3)
