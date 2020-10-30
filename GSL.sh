#!/bin/sh
#__参数初始化__
CURL_TIMEOUT=10
Name="手机号"
Password="密码的32位md5值的小写"
LOGIN_DATA="{\"userName\":\"${Name}\",\"userPassword\":\"${Password}\"}"
USER_DATA="{\"userName\":\"${Name}\"}"
#Server酱（可选）
SCKEY=""
#COOLPUSH（可选）
COOLKEY=""
#

pushFun(){
    
    if [ -n "$1" ]
    then
        curl -s -o /dev/null -X POST "https://sc.ftqq.com/$1.send?text=$3"
    fi
        
    if [ -n "$2" ]
    then
        curl -s -o /dev/null -X POST "https://push.xuthus.cc/send/$2?c=$3"
    fi
}

#__json解析__
parse_json(){
echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}


#__登陆__
logger -t "【光速联提速脚本】" "————————登陆中————————"
loginInfo=`curl -s -H "Content-Type: application/json" -X POST -d ${LOGIN_DATA} "https://www.fangyb.com:2039/biz/user/login.do"`
loginCode=$(parse_json ${loginInfo} "code")
Auth=$(parse_json ${loginInfo} "data")
if [ 0 == ${loginCode} ]
then
    logger -t "【光速联提速脚本】" "————————登陆成功————————"
elif [ 12 == ${loginCode} ]
then
    logger -t "【光速联提速脚本】" "————————用户名或密码错误————————"
    exit 0
elif [ 11 == ${loginCode} ]
then
    logger -t "【光速联提速脚本】" "————————未注册，请检查手机号是否正确或前往注册后再次运行————————"
    exit 0
else
    logger -t "【光速联提速脚本】" "————————登录失败，请重试————————"
    exit 0
fi

#__不是每次运行都能成功，所以多次执行__
NUMBER=1
while true
do

#__当前提速状态__
myOrderInfo=`curl -s -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${USER_DATA} "https://www.fangyb.com:2039/biz/common/myOrder.action"`
stateCode=`echo "${myOrderInfo}" | awk -F  '"' '{print $(NF-1)}'`
className=`echo "${myOrderInfo}" | awk -F  '"' '{print $38}'`
orderId=`echo "${myOrderInfo}" | awk -F  '"' '{print $82}'`
validDate=`echo "${myOrderInfo}" | awk -F  '"' '{print $66}'`

#__判断购买是否到期
today=$(date "+%Y-%m-%d")
t1=`date -d "${validDate}" +%s`
t2=`date -d "${today}" +%s`
if [ ${t2} -gt ${t1} ]
then
	logger -t "【光速联提速脚本】" "————————购买已到期，请续费————————"
    pushFun ${SCKEY} ${COOLKEY} "购买已到期，请续费"
    break
fi

#__构建提速参数
SPEED_DATA="{\"userName\":\"${Name}\",\"className\":\"${className}\",\"orderId\":\"${orderId}\"}"


sleep 1

    if [ "true" == ${stateCode} ]
    then
        logger -t "【光速联提速脚本】" "————————提速状态：提速中————————"
        logger -t "【光速联提速脚本】" "————————正在重新开始提速————————"
    #__关闭提速__
        curl -s -o /dev/null -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${SPEED_DATA} "https://www.fangyb.com:2039/biz/common/closeSpeed.action"
        sleep 2
    else
        logger -t "【光速联提速脚本】" "————————提速状态：未提速————————"
        logger -t "【光速联提速脚本】" "————————正在开始提速————————"
    fi
    
    #__开始提速__
    curl -s -o /dev/null -m ${CURL_TIMEOUT} -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${SPEED_DATA} "https://www.fangyb.com:2039/biz/common/openSpeed.action"
    sleep 4

    #__提速结果__
    #访问两次是为了刷新
    
    curl -s -o /dev/null -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${USER_DATA} "https://www.fangyb.com:2039/biz/common/speedQuery.do"
    sleep 1
    speedQuery=`curl -s -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${USER_DATA} "https://www.fangyb.com:2039/biz/common/speedQuery.do"`
    resultCode=`echo "${speedQuery}" | awk -F  '"' '{print $(NF-1)}'`
    if [ "true" == ${resultCode} ]
    then
        logger -t "【光速联提速脚本】" "————————提速成功————————"
        echo "`echo "${speedQuery}" | awk -F  ',' '{for (i=6;i<=10;i++){print $i}}'`"
        pushFun ${SCKEY} ${COOLKEY} "提速成功"
        break
    else
        logger -t "【光速联提速脚本】" "————————提速失败，开始重试————————"
        let "NUMBER++"
        #重试次数超过10次，则退出
        if [ ${NUBMER} > 10 ]
        then
            logger -t "【光速联提速脚本】" "————————提速失败超过10次，退出————————"
        pushFun ${SCKEY} ${COOLKEY} "提速失败"
            break
        fi

    fi
done
    

