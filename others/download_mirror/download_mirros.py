import os, requests, re

remote_url = "http://mirror.starlingx.cengn.ca/mirror/starlingx/master/centos/latest_build/inputs/"
local_dir = os.path.abspath(os.path.dirname(__file__))
dirs_dict = {
    'downloads':"downloads",
    'SRPMS':"Source",
    "RPMS":"Binary"
}

def read_remote_file_list(url):
    content = requests.get(url).content.decode("utf-8")
    #print(content)
    rpm_list = re.findall('<a href="(.*?)">',content,re.S)
    #[print(a) for a in rpm_list]
    return rpm_list

def read_local_file_list(dirpath):
    if not os.path.exists(dirpath):
        os.mkdir(dirpath)
    return os.listdir(dirpath)

def download_new_file(remote_file, local_list, remote_url, local_dir):
    remote_file = remote_file.replace("%2B","+")
    if remote_file not in local_list:
        local_file_path = os.path.join(local_dir, remote_file)
        print("download "+ local_file_path)
        r =requests.get(remote_url)
        with open(local_file_path, "wb") as f:
            f.write(r.content)
    else:
        print("-> "+remote_file+"is exist in "+ local_dir)

def compare_remote_and_local(uri):
    global remote_url
    global local_dir
    global dirs_dict
    dirname=os.path.join(local_dir, uri)
    key = uri.split("/")[0]
    dir_url = remote_url + uri
    remote_file_list = read_remote_file_list(dir_url)
    if key in dirs_dict:
        dirname = os.path.join(local_dir, dirs_dict[key]+"/"+"/".join(uri.split("/")[1:]))
    local_file_list = read_local_file_list(dirname)
    for remote_file in remote_file_list:
        if remote_file == "../":
            continue
        elif remote_file[-1] == "/":
            compare_remote_and_local(uri+remote_file)
        else:
            download_new_file(remote_file, local_file_list, dir_url+remote_file, dirname)

if __name__ == "__main__":
    for key in dirs_dict.keys():
        compare_remote_and_local(key+"/")
