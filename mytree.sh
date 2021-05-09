#!/bin/bash

start_time=`date +%s%N` #定义脚本运行的开始时间

usage="Usage: ./mytree.sh [directory] [-a]"

#=============================================
#=            Preprocess Part                =
#=             deal with opts                =
#= example: ./mytree.sh -h                   =
#= example: ./myfind.sh                      =
#= example: ./myfind.sh -a                   =
#= example: ./myfind.sh -a .                 =
#=============================================

flag=false
ARGS=`getopt -o ah -n 'help' -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi
 
flag=false  #是否展示隐藏文件或目录
#echo $ARGS
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"
case $1 in
-a)
    flag=true
    ;;
-h)
    echo $usage
    exit 0
    ;;
--)
    ;;
esac
eval set "${ARGS}"

#进入用户指定目录
if [ $# -eq 1 ]
then
    if [ -d $1 ]
    then cd $1
    else
        echo "Directory $1 does not exists"
        exit 1
    fi
elif [ $# -ne 0 ]
then
    echo usage
    exit 1
fi

#=============================================
#=              Process Part                 =
#=============================================

#表示层级关系
sblank="    "
#同级符号同缩进，表示一项
#blank将会填充在“└────”的前面，
sblankblank="└────"
 
#tree函数
tree()
{
    if $flag; then
        #输出当前目录中的所有目录包括隐藏目录
        files=`find . -maxdepth 1`
    else
        files=`find . -maxdepth 1 -name "[^.]*"`
    fi
    #对IFS变量 进行替换处理 TODO
    OLD_IFS=$IFS
    IFS=$'\n'
    #for循环，搜索该目录下的所有文件和文件夹
    for file in $files;
    do
        file=${file:2}
        #if判断，判断是不是文件，如果是文件的话，输出该文件名
        if [ -f "$file" ]; then
            echo "${sblankblank}$file"
        fi
        
        #if判断，判断是不是文件夹，如果是文件夹的话，为了兼容参数 -a ，首先剔除目录'.'和'..'，避免进入死循环，然后输出该文件夹名
        if [ -d "$file" ] && [ "$file" != "." ] && [ "$file" != ".." ]; then
            #输出该文件夹名
            echo "${sblankblank}$file"
            #在“└────”的前面填充“    ”，表示进入一个子目录
            sblankblank=${sblank}${sblankblank}
            #进入该文件夹
            cd $file
            #执行tree函数--递归
            tree
            #从该文件夹里出来
            cd ..
            #从文件夹里出来之后，将在“└────”的前面填充的“    ”删除，表示返回一个父目录
            sblankblank=${sblankblank#${sblank}}
        fi
    done
    IFS=$OLD_IFS
}

echo '.'
tree

stop_time=`date +%s%N`  #定义脚本运行的结束时间
echo "TOTAL EXCUTING TIME: $[($stop_time - $start_time)/1000000] ms"