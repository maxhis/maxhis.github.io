#!/bin/bash

# 定义文件夹路径
folder_path="source/_posts"

# 检查文件夹是否存在
if [ ! -d "$folder_path" ]; then
  echo "文件夹不存在: $folder_path"
  exit 1
fi

# 进入文件夹
cd "$folder_path" || exit

# 按文件名升序排序文件
sorted_files=$(ls -1 | sort)

# 循环执行 touch 命令
for file in $sorted_files; do
  # 检查文件是否存在
  if [ -f "$file" ]; then
    touch "$file"
    echo "已更新文件: $file"
  else
    echo "文件不存在: $file"
  fi
done
