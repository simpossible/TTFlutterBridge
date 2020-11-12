#! /bin/sh
export PATH=/usr/local/bin:$PATH
git_commit_des="自动发布pod"

repo_name="9-repo"

echo "\n ****** begin ****** \n"

echo "\n ---- 获取podspec文件 begin ---- \n"

# 获取到的文件路径
file_path=""
file_name=""
# 文件后缀名
file_extension="podspec"
# 文件夹路径，pwd表示当前文件夹
directory="$(pwd)"

# 参数1: 路径；参数2: 文件后缀名
function getFileAtDirectory(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element
        # echo "$dir_or_file"
        if [ -d $dir_or_file ]
        then
            getFileAtDirectory $dir_or_file
        else
            file_extension=${dir_or_file##*.}
            if [[ $file_extension == $2 ]]; then
                echo "$dir_or_file 是 $2 文件"
                file_path=$dir_or_file
                file_name=$element
            fi
        fi
    done
}
getFileAtDirectory $directory $file_extension

echo "\n -------------"
echo "\n file_path: ${file_path}"
echo "\n file_name: ${file_name}"

echo "\n ---- 获取podspec文件 end ---- \n"

# 定义pod文件名称
pod_file_name=${file_name}
# 查找 podspec 的版本
search_str="s.version"

# 读取podspec的版本
podspec_version=""

#定义了要读取文件的路径
my_file="${pod_file_name}"
while read my_line
do
#输出读到的每一行的结果
# echo $my_line

    # 查找到包含的内容，正则表达式获取以 ${search_str} 开头的内容
    result=$(echo ${my_line} | grep "^${search_str}")
    if [[ "$result" != "" ]]
    then
        echo "\n ${my_line} 包含 ${search_str}"

        # 分割字符串，是变量名称，不是变量的值; 前面的空格表示分割的字符，后面的空格不可省略
        array=(${result// / })
        # 数组长度
        count=${#array[@]}
        # 获取最后一个元素内容
        version=${array[count - 1]}
        # 去掉 '
        version=${version//\'/}

        podspec_version=$version
    #else
        # echo "\n ${my_line} 不包含 ${search_str}"
    fi

done < $my_file

echo "\n -------------"
echo "\n podspec_version: ${podspec_version}"

echo "\n ---- 读取podspec文件内容 end ---- \n"


#分割版本号的3个数

version_array=(${podspec_version//./ })
echo 'the array is ${version_array}'
count=${#version_array[@]}

last_version=${version_array[count-1]}
last_version=${last_version//\"/}

in_last=$(($last_version+1))

real_version=""
last_version_str=""
seperator="."
for (( i = 0; i < $count; i++ )); do
	if [[ $i == $(($count-1)) ]]; then
		#statements
		lastTemp=$(($last_version))
		tempversion=$in_last
	else
		if [[ $i == 0 ]]; then
			tempversion=${version_array[i]}
			tempversion=${tempversion//\"/}
			tempversion=$tempversion$seperator
			lastTemp=$tempversion
		else
		tempversion=${version_array[i]}$seperator
		lastTemp=$tempversion
		fi

	fi
	last_version_str=$last_version_str$lastTemp
	real_version=$real_version$tempversion
done
echo "the new_version is ${real_version}"
echo "the last_version is ${last_version_str}"


#替换原有版本号
sed -i "" " s/${last_version_str}/${real_version}/g" $my_file

# git 操作
echo "git add ."
git add .
echo "git status"
git status
echo "git commit -m ${git_commit_des}"
git commit -m ${git_commit_des}${real_version}

echo "\n ------ 执行 pod 本地校验 ------ \n"
# pod 本地校验
# echo "pod lib lint --allow-warnings --verbose"
# pod lib lint --allow-warnings --verbose --sources=git@192.168.9.231:cocoapods/repo.git,9-repo


echo "\n ------ 执行 git 打标签tag，并推送到远端 ------ \n"
# git推送到远端
echo "git tag ${real_version}"
git tag ${real_version}
echo "git push origin master --tags"
git push origin master --tags


# echo "\n ------ 执行 pod 远端校验 ------ \n"
# pod 远端校验
# echo "pod spec lint --allow-warnings --verbose"
# pod spec lint $pod_file_name --sources=git@gitlab.ttyuyin.com:cocoapods/repo.git,$repo_name --verbose --allow-warnings


current_path=`pwd`
cd ~/.cocoapods/repos/$repo_name
repo_path=`pwd`

git pull

cd $current_path
# 发布
echo "推送到远端 $current_path"
pod repo push $repo_name $pod_file_name --sources=git@gitlab.ttyuyin.com:cocoapods/repo.git,$repo_name --allow-warnings --verbose

echo "推送repo变更到远端"
cd $repo_path
git add .
git status
git commit -m "${pod_file_name}:${new_version}"
git push origin master --tags
