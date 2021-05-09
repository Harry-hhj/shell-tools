#!/bin/bash

start_time=`date +%s%N` #定义脚本运行的开始时间
usage="Usage: ./myfind.sh [-a] [directory] keyword"

#=============================================
#=            Preprocess Part                =
#=             deal with opts                =
#= example: ./myfind.sh -h                   =
#= example: ./myfind.sh . hello              =
#= example: ./myfind.sh -a . hello           =
#= example: ./myfind.sh hello                =
#= example: ./myfind.sh -a hello             =
#=============================================

ARGS=`getopt -o ah -n 'help' -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi
 
flag=false
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

c=$#
#echo "c${c}"
if [ $c -eq 1 ]; then
    directory='.'
    keyword=$1
elif [ $c -eq 2 ]; then
        directory=$1
        keyword=$2
    else
        echo "Too many parameters! ${usage}"
        exit 1
fi
#echo $flag
#echo "directory: ${directory}, keyword: ${keyword}"

echo "=== Check ==="
echo "The following files' encodings are not supported: "
find $directory -type f -readable -regex '.*\.c\|.*\.h' 2>&1 | grep -v 'Permission denied' | xargs -I {} file {} | grep -v -E 'UTF-8|ASCII'
if [ $? -ne 0 ];then
    echo "Null."
fi

echo
echo "=== Results ==="
if [ -d $directory ]; then  # -d 文件 判断该文件是否存在,并且是否为目录(是目录为真)
    find $directory -type f -readable -regex '.*\.c\|.*\.h' 2>&1 | grep -v 'Permission denied' | xargs -I {} grep -n -H --color=auto $keyword {}
else
    echo "Command Error! Usage: ${usage}"
    exit 1
fi

if $flag; then
    echo
    echo "=== Statistics ==="
    for res in $(find $directory -type f -readable -regex '.*\.c\|.*\.h' | xargs -I {} grep -c -H $keyword {})
    do
        echo "${res} time(s)"
    done
fi

stop_time=`date +%s%N`  #定义脚本运行的结束时间
echo
echo "=== Finish ==="
echo "TOTAL EXCUTING TIME: $[($stop_time - $start_time)/1000000] ms"
