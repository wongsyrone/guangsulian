#!/bin/sh
#__参数初始化__
CURL_TIMEOUT=10
Name="手机号"
Password="密码的32位md5值的小写"
LOGIN_DATA="{\"userName\":\"${Name}\",\"userPassword\":\"${Password}\"}"
USER_DATA="{\"userName\":\"${Name}\"}"
#Server酱
SCKEY=""
#COOLPUSH
COOLKEY=""
#
#__json解析__
parse_json(){
echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}


#__登陆__
echo "----登陆中----"
loginInfo=`curl -s -H "Content-Type: application/json" -X POST -d ${LOGIN_DATA} "https://www.fangyb.com:2039/biz/user/login.do"`
loginCode=$(parse_json ${loginInfo} "code")
Auth=$(parse_json ${loginInfo} "data")
if [ 0 == ${loginCode} ]
then
    echo "----登陆成功----"
elif [ 12 == ${loginCode} ]
then
    echo "----用户名或密码错误----"
    exit 0
elif [ 11 == ${loginCode} ]
then
    echo "----未注册，请检查手机号是否正确或前往注册后再次运行----"
    exit 0
else
    echo "----登录失败，请重试----"
    exit 0
fi

#__当前提速状态__
myOrderInfo=`curl -s -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${USER_DATA} "https://www.fangyb.com:2039/biz/common/myOrder.action"`
stateCode=`echo "${myOrderInfo}" | awk -F  '"' '{print $(NF-1)}'`
className=`echo "${myOrderInfo}" | awk -F  '"' '{print $38}'`
orderId=`echo "${myOrderInfo}" | awk -F  '"' '{print $82}'`
SPEED_DATA="{\"userName\":\"${Name}\",\"className\":\"${className}\",\"orderId\":\"${orderId}\"}"

sleep 1
#__不是每次运行都能成功，所以多次执行__
result=0
while(( 0 == ${result} ))
do
    if [ "true" == ${stateCode} ]
    then
        echo "----提速状态：提速中----"
        echo "----正在重新开始提速----"
    #__关闭提速__
        curl -s -o /dev/null -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${SPEED_DATA} "https://www.fangyb.com:2039/biz/common/closeSpeed.action"
        sleep 2
    else
        echo "----提速状态：未提速----"
        echo "----正在开始提速----"
    fi
    
    #__开始提速__
    curl -s -o /dev/null -m ${CURL_TIMEOUT} -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${SPEED_DATA} "https://www.fangyb.com:2039/biz/common/openSpeed.action"
    sleep 2
    #__提速结果__
    #访问两次是为了刷新
    
    curl -s -o /dev/null -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${USER_DATA} "https://www.fangyb.com:2039/biz/common/speedQuery.do"
    sleep 1
    speedQuery=`curl -s -H "Content-Type: application/json" -H "Authorization: ${Auth}" -X POST -d ${USER_DATA} "https://www.fangyb.com:2039/biz/common/speedQuery.do"`
    resultCode=`echo "${speedQuery}" | awk -F  '"' '{print $(NF-1)}'`
    echo "${resultCode}"
    if [ "true" == ${resultCode} ]
    then
        echo "----提速成功----"
        echo "`echo "${speedQuery}" | awk -F  ',' '{for (i=6;i<=10;i++){print $i}}'`"
        if [ -n "SCKEY" ]
        then
            curl -s -o /dev/null -X POST "https://sc.ftqq.com/${SCKEY}.send?text=提速成功"
        fi
        
        if [ -n "COOLKEY" ]
        then
            curl -s -o /dev/null -X POST "https://push.xuthus.cc/send/${COOLKEY}?c=提速成功"
        fi
        result=1
    else
        echo "----提速失败，开始重试"
    fi
done
    