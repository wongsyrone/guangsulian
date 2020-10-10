# 光速联提速脚本

#### 介绍
光速联提速脚本

#### 使用说明，以老毛子固件为例

1.  [下载脚本](https://gitee.com/caixiaodao/GuangSuLian/raw/master/GSL.sh)，然后按照自己的账号修改脚本
2.  用winscp或其他工具将GSL.sh上传到路由器，以/etc/storage/script/为例，权限全给
![输入图片说明](https://images.gitee.com/uploads/images/2020/1010/181403_6fac2c80_2295960.png "1.png")
3.  用浏览器登录路由器，找到“系统管理-服务-其他服务-计划任务（Crontab）”，将0 */7 * * * /etc/storage/script/GSL.sh
输入其中，此处任以/etc/storage/script/为例，具体位置请以个人喜好为准。0 */7 * * *表示每7小时执行一次。最后别忘了点击应用本页设置


