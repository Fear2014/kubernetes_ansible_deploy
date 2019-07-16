ansible 一键部署 kubernetes高可用框架（kube-router版）
========

框架说明
----
> OS:Ubuntu 

> kubernetes1.13.1+etcd3.3.10+kube-router+coredns+descheduler0.9.0 全部采用二进制离线安装，无网络需求。

> 环境基础：已安装了python、ansible、docker、chrony、keepalived,配置好了主节点到其他节点的免密登陆。/offlinePackage中提供了chrony与keepalived的离线包

> 案例为4台服务器，组成双master和3worker的高可用集群


关于网络的说明
----
> 正常情况下，一台服务器一个网卡&一个网关，但是当遇到特殊情况，如2个网卡2个网关的时候，需要对router进行操作了，/route 提供了添加route永久生效的方法


为何使用kube-router
----
> 1、部署方便，kube-router, 它可以不仅仅作为 CNI 提供 pod 所需的网络, 以及提供 networkPolicy, 还能运行为 service proxy 替代 kube-proxy 来实现 k8s 下的 Service

> 2、flannel不支持Network Policy

> 3、kube-router使用ipvs性能损失最小，时延最小，其他网络插件性能差距不大  kube-router > calico > canal = flannel = romana

![Image text](https://github.com/Fear2014/kubernetes_ansible_deploy/blob/master/images/Kubernetes_kube-router.png)

![Image text](https://github.com/Fear2014/kubernetes_ansible_deploy/blob/master/images/kubernetes%20%E7%BB%84%E7%BB%87%E5%9B%BE_kube-routrer.png)



使用说明
-----
> 运行startup.sh,通过ansible在master节点去部署4台服务器
	
> 框架目录结构：
>               /etc/ansible/ |-bin
>                             |-down
>                             |-roles	
>                             |-0x.xxx.yml
>                             |-ansible.cfg
>                             |-hosts
>               /k8s/ |-etcd/ |-ssl
>                             |-cfg
>                     |-kubernetes/ |-ssl
>                                   |-cfg
>                                   |-yml
>              /data/etcd
>              /etc/cni/net.d
>              /opt/cni/bin								   

> 使用了coredns与descheduler插件，分别保证域名访问与pod重调度功能，descheduler的周期建议改为一天一次，默认设置为在每日凌晨2点时启动排查


> 使用 ansible/99.clean.yml 可直接清理etcd、k8s，方便重新搭建





配置文件说明
-----
> 1、coredns的配置文件coredns.yml.j2
>  Corefile: |
>    .:53 {
>        errors
>        health
>        kubernetes cluster.local  {{ SERVICE_CIDR }} {
>          pods insecure
>          upstream
>          fallthrough in-addr.arpa ip6.arpa
>        }
>        prometheus :9153
>        forward . 8.8.8.8:53    #修改为自定义的DNS地址，省去修改resolv.conf的麻烦
>        cache 30
>        loop
>        reload
>        loadbalance

> 2、api-server配置文件说明：
>	--bind-address=0.0.0.0 \		#此为设置安全端口监听的ip，选择监听所有
>	--advertise-address={{ MASTER_IP }} \	#此为发布给集群的api-server的地址，设置为api-server-VIP

> 2、controller-manager/kube-schduler配置文件说明：
>	--address=127.0.0.1	\					#设置为本地地址
>   --master=127.0.0.1:8080 \				#设置本地的api地址，保证3个组件都在同一个服务器上运行
