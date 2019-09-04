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

MYRIAD = False
EMOTION = False
AGE = False

model_path = '/opt/intel/computer_vision_sdk/deployment_tools/intel_models/'
         
MYRIAD = check_usb('03e7')

version = os.environ["MODELVERSION"]
if version[:2] == "v2":
    AGE = True
if version[:2] == "v3":
    EMOTION = True
    AGE = True

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
