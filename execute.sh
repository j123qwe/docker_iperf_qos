#!/bin/sh

MODE=$(echo ${MODE} | tr '[:lower:]' '[:upper:]')
if [ ${MODE} == "SERVER" ]; then
    iperf3 -s
fi

sleep ${TIMEOUT} #Timeout to wait for iPerf server to become available

capsh --print | grep "Current" | grep "!cap_net_admin" > /dev/null
if [ $? -ne 0 ]; then
    iptables -t mangle -A OUTPUT -p udp -m udp --dport ${PORT} -j DSCP --set-dscp-class ${DSCP}
else
    echo "--cap-add=NET_ADMIN not present."
fi

UDP=$(echo ${UDP} | tr '[:lower:]' '[:upper:]')
DIRECTION=$(echo ${DIRECTION} | tr '[:lower:]' '[:upper:]')
OUTPUT=$(echo ${OUTPUT} | tr '[:lower:]' '[:upper:]')

if [ ${OUTPUT} == "JSON" ]; then
    OUTPUT="--json"
else
    OUTPUT=""
fi

if [ ${DIRECTION} == "DOWN" ]; then
    DIRECTION="--reverse"
elif [ ${DIRECTION} == "UP" ]; then
    DIRECTION=""
else
    echo "Invalid direction variable set. Exiting"
    exit
fi

if [ ${PROTO} == "UDP" ]; then
    iperf3 -u -b ${SPEED}mbps -p ${PORT} -t ${TIME}s -i ${INTERVAL}s ${DIRECTION} ${OUTPUT} -c ${HOST}
elif [ ${PROTO} == "TCP" ]; then
    iperf3 -p ${PORT} -t ${TIME}s -i ${INTERVAL}s ${DIRECTION} ${OUTPUT} -c ${HOST}
else
    echo "Invalid protocol specified. Exiting"
    exit
fi

while true; do echo "iPerf test complete."; sleep 86400; done