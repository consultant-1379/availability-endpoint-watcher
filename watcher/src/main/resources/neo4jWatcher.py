#!/usr/bin/python3

from datetime import datetime
from aduLoggerConfig import initLogger
import subprocess
import sys
import time

logger = initLogger('neo4jWatcher.py')

timeout_seconds = 5
fmt = "%Y%m%d%H%M%S"
neo_pod = sys.argv[1]
neo_ip = sys.argv[2]


def upgrade_running():
    return True


while upgrade_running():
    try:
        rStatusR = ''
        wStatusW = ''
        try:
            rStatusR = subprocess.check_output('curl -s --user neo4j:Neo4jadmin123 -m 2 "http://{ipn}:7474/db/dps/cluster/available"'.format(ipn=neo_ip), stderr=subprocess.STDOUT, shell=True)
            rStatusR = str(rStatusR, 'utf-8')
        except subprocess.CalledProcessError as rre:
            rStatusR = str(rre.returncode)
            logger.warning("Exception in neo4j-read, output: %s, errorCode: %s", str(rre.output, 'utf-8'), rStatusR)
        try:
            wStatusW = subprocess.check_output('curl -s --user neo4j:Neo4jadmin123 -m 2 "http://{ipn}:7474/db/dps/cluster/writable"'.format(ipn=neo_ip), stderr=subprocess.STDOUT, shell=True)
            wStatusW = str(wStatusW, 'utf-8')
        except subprocess.CalledProcessError as wwe:
            wStatusW = str(wwe.returncode)
            logger.warning("Exception in neo4j-write, output: %s, errorCode: %s", str(wwe.output, 'utf-8'), wStatusW)

        if rStatusR is None or wStatusW is None or rStatusR == '' or wStatusW == '':
            logger.warning("POD: " + neo_pod + " is not ready, Status is empty.")
            rStatusR = "7"
            wStatusW = "7"
        elif not (rStatusR == "true" or rStatusR == "false"):
            logger.warning("POD: " + neo_pod + " is not ready, Status : " + rStatusR)

        printCmd = "echo \"{time},{ip},{status}\" >> /var/adu/data/{depedency}_readonly.csv".format(time=datetime.now().strftime(fmt), depedency=neo_pod, status=rStatusR, ip=neo_ip)
        subprocess.call(printCmd, stderr=subprocess.STDOUT, shell=True)
        printCmd = "echo \"{time},{ip},{status}\" >> /var/adu/data/{depedency}_writeonly.csv".format(time=datetime.now().strftime(fmt), depedency=neo_pod, status=wStatusW, ip=neo_ip)
        subprocess.call(printCmd, stderr=subprocess.STDOUT, shell=True)

        current_ip = subprocess.check_output(['bash', '/usr/local/adu/getNeo4jPodIp.sh', neo_pod])
        current_ip = str(current_ip,'utf-8').rstrip()
        if 'fail' in current_ip:
            logger.info("POD: " + neo_pod + " current_ip : " + current_ip)
            logger.warning("POD: " + neo_pod + " IP is not available.")
        elif neo_ip == current_ip:
            pass
        else:
            logger.info("IP of neo4j host: " + neo_pod + " has changed from " + neo_ip + " to " + current_ip.rstrip())
            logger.info("Using new IP: " + current_ip.rstrip() + " for host: " + neo_pod)
            neo_ip = current_ip

    except Exception as e:
        exc_type, exc_obj, exc_tb = sys.exc_info()
        logger.warning("Neo4j Exception : %s, @Line : %s", e, exc_tb.tb_lineno)

    time.sleep(2)
