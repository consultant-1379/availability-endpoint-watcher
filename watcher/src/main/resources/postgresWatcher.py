#!/usr/bin/python3

from aduLoggerConfig import initLogger
from datetime import datetime
import subprocess
import time
import sys
import os

logger = initLogger('postgresWatcher.py')
fmt = "%Y%m%d%H%M%S"

#Read pg-pass
pfile = open('/secret/super-pwd')
pwd = pfile.read()
os.environ['PGPASSWORD'] = pwd


def upgrade_running():
    return True


while upgrade_running():
    try:
        online = False
        command = "/usr/bin/pg_isready -h postgres -t 2"
        output = os.popen(command)
        status = output.read()
        if "accepting" in status:
            recovery_check = "psql -h postgres -U postgres -c 'select pg_is_in_recovery();'"
            recovery_output = os.popen(recovery_check)
            recovery_status = recovery_output.read()
            if " f\n" in recovery_status:
                online = True
            else:
                logger.info("postgres is in recovery, status: {}".format(recovery_status))
                online = False
        else:
            logger.warning("postgres error: " + status)

        if online:
            printCmd = "echo \"{time}, ONLINE\" >> /var/adu/data/postgres.csv".format(time=datetime.now().strftime(fmt))
            subprocess.call(printCmd, stderr=subprocess.STDOUT, shell=True)
        else:
            printCmd = "echo \"{time}, OFFLINE\" >> /var/adu/data/postgres.csv".format(time=datetime.now().strftime(fmt))
            subprocess.call(printCmd, stderr=subprocess.STDOUT, shell=True)
    except:
        exc_type, exc_obj, exc_tb = sys.exc_info()
        logger.warning("Generic Exception : %s, %s, @Line : %s", exc_type, exc_obj, exc_tb.tb_lineno)
    time.sleep(2)



