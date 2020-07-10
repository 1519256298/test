#!/bin/bash
#新镜像标签：默认取当前时间作为标签名
# imageNewTag=`date +%Y%m%d-%H%M%S`
imageTag=$(./.env)
#镜像仓库地址
registryAddr="registry.cn-shenzhen.aliyuncs.com/"
 
#循环读取images.txt,并存入list中
n=0
 
for line in $(cat images.txt | grep ^[^#])
do
	list[$n]=$line
	((n+=1))
done
 
echo "需推送的镜像地址如下："
for variable in ${list[@]}
do
	echo ${variable}:${imageTag}
done
 
for variable in ${list[@]}
do
	#下载镜像
	echo "准备拉取镜像: $variable:$imageTag"
	docker pull $variable:$imageTag
	
	# #获取拉取的镜像ID
	imageId=`docker images -q $variable:$imageTag`
	echo "[$variable:$imageTag]拉取完成后的镜像ID: $imageId"
	
	#获取完整的镜像名
#	imageFormatName=`docker images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" |grep $variable:$imageTag`
	imageFormatName=`docker images --format "{{.Repository}}:{{.Tag}}" |grep $variable:$imageTag`
	echo "imageFormatName:$imageFormatName"
 
	#删掉最后一个/及其左边的字符串
	#如：192.168.35.126:5000/lyzhxg/bks/ly-sm-yxxt-ui:20200324-153539:0beed7b2fa8c  ->  ly-sm-yxxt-ui:20200324-153539:0beed7b2fa8c
	repository=${imageFormatName#*/}
	echo "repository :$repository"
	
	#删掉第一个:及其右边的字符串
	#如：ly-sm-yxxt-ui:20200324-153539:0beed7b2fa8c -> ly-sm-yxxt-ui
	#repository=${repository%%:*}
 
	echo "新镜像地址: $registryAddr$repository"
	
	#重新打镜像标签
	docker tag $imageId $registryAddr$repository
	
	# #推送镜像
	docker push $registryAddr$repository
done