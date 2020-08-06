#!/bin/python

import time
from datetime import datetime
import subprocess

def get_sec(time_str):
    """Get Seconds from time."""
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + int(s)

def count_charge(queue, node, slots, time):
    """Get ELSA charge"""
    if (queue == 'public'):
        return 5 * (int(node) * int(slots) * time * 0.05)
    elif (queue == 'gpu'):
        return 10 * (int(node) * int(slots) * time * 0.1)
    elif (queue == 'gpu'):
        return 30 * (int(node) * int(slots) * time * 0.3)

def elsa_charge(line):
    if ";E;" in lastLine:
        user  = line[line.index("user=")+5:line.index(" group")]
        queue = line[line.index("queue=")+6:line.index(" ctime")]
        node  = line[line.index("unique_node_count")+18:line.index(" end")]
        slots = line[line.index("total_execution_slots")+22:line.index(" unique_node_count")]
        time  = line[line.index("resources_used.walltime")+24:-1]

        return user + ';' + queue + ';' + slots + ';' + time + ';' + str(count_charge(queue, node, slots, get_sec(time)))

dirPath = '/var/lib/torque/server_priv/accounting/'
fileName = datetime.today().strftime('%Y%m%d')

lastLine = None
while True:
    filePath = dirPath + fileName

    while True:
        line = subprocess.check_output(['tail', '-1', filePath])
        if line != lastLine:
            lastLine = line
            charge = elsa_charge(lastLine)

            with open(fileName + '.elsa', 'w') as chareFile: 
                chareFile.write(charge + '\n')

        if datetime.today().strftime('%Y%m%d') != fileName:
            break

        time.sleep(0.1)
    
    filePath = dirPath + datetime.today().strftime('%Y%m%d')

