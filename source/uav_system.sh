#!/usr/bin/bash

emiro_dir="~" 

echo -e "\n\n\033[1;32m>>> Install UAV System\033[0m"

sudo apt update
sudo apt install -y libncurses5-dev pkg-config

cd $emiro_dir/drone/ws/src

if [ ! -d "$emiro_dir/drone/ws/src/emiro" ]; then
    echo "Clone UAV-System"
    git clone https://github.com/Balisa16/UAV-System.git emiro
    cd $emiro_dir/drone/ws/src/emiro
    git submodule update --init --recursive
fi
catkin build emiro

# Check if the folder exists
folder_path="$emiro_dir/drone/ws/src/emiro/release/bin"
if [ ! -d "$folder_path" ]; then
    echo -e "\n\n\033[1;31mError:\033[0m Release folder does not exist. Maybe previous build is failed."
    exit 1
fi

# Esport shared library into devel library
cp $emiro_dir/drone/ws/src/emiro/release/lib/* $emiro_dir/drone/ws/devel/lib

output_file="$emiro_dir/drone/ws/src/emiro/shell/emiro.sh"
rm -r "$output_file"
touch "$output_file"

# Check if the folder exists
if [ ! -d "$folder_path" ]; then
  echo "Error: The specified folder does not exist."
  exit 1
fi

# List all files in the folder and write the names to the output file
echo -e "#!$(which bash)\n" >> "$output_file"
for file in "$folder_path"/*; do
  if [ -f "$file" ]; then
    file_name=$(basename "$file")
    echo -e "Shortcut \033[1;32m$file_name\033[0m == rosrun emiro $file_name"
    echo -e "$file_name()\n{" >> "$output_file"
    echo -e "\trosrun emiro $file_name" >> "$output_file"
    echo -e "}" >> "$output_file"
  fi
done

# Regist EMIRO path
echo "export EMIRO_PATH=$emiro_dir/drone/ws/src/emiro" >> ~/.bashrc
echo "source $emiro_dir/drone/ws/src/emiro/shell/emiro.sh" >> ~/.bashrc
source ~/.bashrc