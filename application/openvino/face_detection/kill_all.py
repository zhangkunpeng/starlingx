#!/bin/python
# kill all process

import os
import signal

kill_pids = []

python_info = os.popen('pgrep -f python')

model_info = os.popen('pgrep -f intel')

for single_pid in python_info:
    if single_pid:
        kill_pids.append(int(single_pid))
for single_pid in model_info:
    if single_pid:
        kill_pids.append(int(single_pid))


if len(kill_pids) > 1:
    for pid in kill_pids:
        print pid
        try:
            if pid != os.getpid():
                os.kill(pid, signal.SIGKILL)
        except Exception:
            continue
