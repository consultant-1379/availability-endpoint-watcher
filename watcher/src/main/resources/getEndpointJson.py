#!/usr/bin/python3

from kubernetes import client, config
from kubernetes.client.rest import ApiException
from jproperties import Properties
from aduLoggerConfig import initLogger
import sys

logger = initLogger('getEndpointJson.py')

properties = Properties()
with open("/var/adu/data/adu.properties", "rb") as p_file:
    properties.load(p_file, "utf-8")

namespace = properties.get("namespace").data

config.load_incluster_config()
api_instance = client.CoreV1Api()
timeout_seconds = 10

try:
    logger.info("Printing endpoint json ....")
    api_response = api_instance.list_namespaced_endpoints(namespace.rstrip(), timeout_seconds=timeout_seconds)
    file = open("/var/adu/data/endpoint.json", "w")
    file.write(str(api_response))
    file.close

except ApiException as e:
    logger.warning("Exception when calling CoreV1Api->list_endpoints_for_all_namespaces: %s", e)
except:
    e = sys.exc_info()
    logger.warning("Generic Exception : %s", e)


