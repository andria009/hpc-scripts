#!/bin/python

import time
from datetime import datetime
import subprocess
import os.path
import json

def get_sec(time_str):
    """Get Seconds from time."""
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + int(s)

def count_charge(queue, node, slots, time):
    """Get ELSA charge"""
    if (queue == 'public'):
        return 5.0 * (int(node) * int(slots) * time * 0.05)
    elif (queue == 'gpu'):
        return 10.0 * (int(node) * int(slots) * time * 0.1)
    elif (queue == 'gpu'):
        return 30.0 * (int(node) * int(slots) * time * 0.3)
    elif (queue == 'free-cpu'):
        return 0.0
    elif (queue == 'free-cpu'):
        return 0.0

def elsa_charge(line):
    if ";E;" in line:
        if not "Error_Path" in line:
            ended = line[0:line.index(";E;")]
            user  = line[line.index("user=")+5:line.index(" group")]
            queue = line[line.index("queue=")+6:line.index(" ctime")]
            node  = line[line.index("unique_node_count")+18:line.index(" end")]
            slots = line[line.index("total_execution_slots")+22:line.index(" unique_node_count")]
            time  = line[line.index("resources_used.walltime")+24:line.index("resources_used.walltime")+32]

            # return user + ';' + queue + ';' + slots + ';' + time + ';' + str(count_charge(queue, node, slots, get_sec(time)))
            elsaC = dict()
            elsaC['user'] = user
            elsaC['queue'] = queue
            elsaC['slots'] = int(slots)
            elsaC['time'] = time
            elsaC['ended'] = ended
            elsaC['points'] = round(count_charge(queue, node, slots, get_sec(time)), 2)
            elsaC_json = json.dumps(elsaC)
            return  elsaC_json
    else:
        return ""

dirPath = '/var/lib/torque/server_priv/accounting/'
fileName = datetime.today().strftime('%Y%m%d')
outPath = '/var/log/elsa/'

lastLine = None
while True:
    filePath = dirPath + fileName

    while True:
        if os.path.isfile(filePath):
            line = subprocess.check_output(['tail', '-1', filePath])
            if line != lastLine:
                lastLine = line
                charge = elsa_charge(lastLine)

                if charge != "":
                    print charge
                    with open(outPath + fileName + '.elsa', 'a+') as chareFile: 
                        chareFile.write(charge + '\n')

            if datetime.today().strftime('%Y%m%d') != fileName:
                break

        time.sleep(1)
    
    fileName = datetime.today().strftime('%Y%m%d')
