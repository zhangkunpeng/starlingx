
import os, requests, re

def read_stx_rpm_list(url):
    content = requests.get(url).content.decode("utf-8")
    rpm_list = re.findall('.rpm">(.*?)</a>',content,re.S)
    #[print(a) for a in rpm_list]
    return rpm_list

def read_exist_rpms(filename):
    f = open(filename, 'r')
    result = f.readlines()
    f.close()
    return result

count = 0
count_version = 0


def check_if_exist(rpm_list, rpm_name):
    rpm_name_tmp = rpm_name.replace(".el7", "#")
    rpm_with_version = ".".join(rpm_name_tmp.split("#")[:1])
    rpm_detail_list = rpm_with_version.split("-")[:-2]
    rpm_only_name = "-".join(rpm_detail_list)
    for rpm in rpm_list:
        rpm = rpm.replace("\n","").split('/')[-1]
        if rpm_with_version in rpm:
            #print("版本一致：stx: %s  ---  centos: %s" % (rpm_name.ljust(50," "), rpm))
            return
        if rpm_only_name in rpm[:len(rpm_only_name)] and rpm[len(rpm_only_name)] == "-" and rpm[len(rpm_only_name)+1].isdigit():
            #print("版本不一致：stx: %s  ---  centos: %s" % (rpm_name.ljust(50," "), rpm))
            global count_version
            count_version += 1
            return
    print("找不到  ： stx: %s " % rpm_name)
    global count
    count += 1

if __name__ == "__main__":
    count = 0
    count_version = 0
    stx_list = read_stx_rpm_list("http://mirror.starlingx.cengn.ca/mirror/starlingx/release/2.0.0/centos/inputs/RPMS/x86_64/")
    centos_list = read_exist_rpms("rpm-dvd1.txt")
    for rpm_name in stx_list:
        check_if_exist(centos_list, rpm_name)
    print("找不到：",count, "版本不一致：",count_version)
