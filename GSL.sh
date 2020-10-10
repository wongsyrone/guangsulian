#!/bin/sh
SCKEY="SCU92377T266186640b8cbe02c4754c90bd5901005e8693a9eab78"
COOLKEY="192a1e171efac76dcc219952d1909b18"
if [ -n "SCKEY" ]
then
    curl -s -o /dev/null -X POST "https://sc.ftqq.com/${SCKEY}.send?text=提速成功"
fi

if [ -n "COOLKEY" ]
then
    curl -s -o /dev/null -X POST "https://push.xuthus.cc/send/${COOLKEY}?c=提速成功"
fi
