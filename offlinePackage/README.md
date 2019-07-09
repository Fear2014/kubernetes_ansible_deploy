chrony说明
========

> 时间采用chrony代替ntp，相比较于ntp，启动服务后chrony同步更快，稳定性更好，更易使用与测试。

> 安装服务后需要修改 /etc/chrony/chrony.conf ,注释掉原来的时间服务器。如果是server端，添加国内时间源地址，如果是clinet端，添加server端地址+本机地址。添加allow 0.0.0.0/0 ，也可指定限制某网段可同步

测试
-----
> chronyc sources  查看使用了哪个时间服务器同步，星号的为正在同步的时间服务器

> ntpdate -d  测试是否可以同步的上server端，如果连不上根据返回的结果推断错误