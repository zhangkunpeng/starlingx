import os, requests, re, sys

TARGET_DIRNAME="outputs/"
ROOT_URL="http://mirror.starlingx.cengn.ca/mirror/starlingx/"
env_dist = os.environ


def read_remote_file_list(url):
    content = requests.get(url).content.decode("utf-8")
    #print(content)
    file_list = re.findall('<a href="(.*?)">',content,re.S)
    #[print(a) for a in rpm_list]
    return file_list

def get_remote_url(branch):

    def _findout_final_url(url):
        item_list = read_remote_file_list(url)
        if TARGET_DIRNAME in item_list:
            return url+TARGET_DIRNAME
        else:
            for item in item_list:
                if item == "../":
                    continue
                elif item[-1] == "/":
                    return _findout_final_url(url+item)
    
    if branch == "master":
        return ROOT_URL+"master/centos/latest_build/"+TARGET_DIRNAME
    else:
        release_url = ROOT_URL+"release/"
        item_list = read_remote_file_list(release_url)
        branch_list = [item[:-1] for item in item_list if item[-1] == "/" and item != "../"]
        if branch in branch_list:
            return _findout_final_url(release_url + branch+"/centos/")
        else:
            print("请输入正确的版本号，版本列表：", branch_list)

def get_workspace():
    workspace = os.getenv("MY_WORKSPACE")
    if workspace and os.path.exists(workspace):
        return workspace
    
    homepath=os.getenv("HOME")
    user = os.getenv("USER")
    workspace = "localdisk/loadbuild/"+user+"starlingx/"
    workspace = os.path.join(homepath, "starlingx/workspace/", workspace)
    if workspace and os.path.exists(workspace):
        return workspace
    print("找不到工作目录")
    exit(1)

def get_specs_build_list(rpm_class):
    return os.path.join(get_workspace(), rpm_class+"/rpmbuild/SPECS/")

def get_rpm_dir_list(dirpath):
    if os.path.exists(dirpath):
        return os.listdir(dirpath)
    return []



def get_rpm_name(fullname):
    #print( re.findall(r'(.*)-(\d*\.\d.*)', "ceph-adfa-mamang1-10.2.6-0.el7.tis.2.src.rpm",re.S))
    pass

def findout_build_output_list(buildpath, rpm_full_name):
    path = os.path.join(buildpath, rpm_full_name+"/BUILD/")
    if os.path.exists(path):
        return os.listdir(path)
    return []

def findout_remote_file_list(filelist, remote_url):
    remote_list = read_remote_file_list(remote_url)
    remote_file_list = []
    for filename in filelist:
        for remotename in remote_list:
            if remotename.startswith(filename):
                remote_file_list.append(remote_url+remotename)
    return remote_file_list


if __name__ == "__main__":
    branch = None
    rpm_class = None
    rpm_name = None
    if len(sys.argv) >= 3:
        branch = sys.argv[1]
        rpm_class = sys.argv[2]
    if len(sys.argv) >= 4:
        rpm_name = sys.argv[3]
    else:
        print("请输入构建分支，比如master")
        print("请输入需要下载的类型，比如 rt/std")
    
    print(get_remote_url(branch))
    print(rpm_name)
    print(read_remote_file_list(get_remote_url(branch)))