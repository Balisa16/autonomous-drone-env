#!/usr/bin/bash

echo -e "\n\n\033[1;32m>>> Creating Copter Directory\033[0m"

sudo apt update
sudo apt install -y libncurses5-dev pkg-config

cd ~/drone/ws/src

if [ ! -d "~/drone/ws/src/emiro" ]; then
    echo "Clone UAV-System"
    git clone https://github.com/Balisa16/UAV-System.git emiro
    cd ~/drone/ws/src/emiro
    git submodule update --init --recursive
fi
catkin build emiro

# Check if the folder exists
folder_path="release/bin"
if [ ! -d "$folder_path" ]; then
    echo -e "\n\n\033[1;31mError:\033[0m Release folder does not exist. Maybe previous build is failed."
    exit 1
fi

output_file="/home/all/drone/ws/src/emiro/shell/emiro.sh"
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

echo "File names listed in $output_file."

# Regist EMIRO path
if [ -z "$(ls -A "$folder_path")" ]; then
    echo -e "\n\n\033[1;31mError:\033[0m Release folder is empty. Maybe previous build is failed."
    exit 1
else
    rm shell/emiro.sh
    touch shell/emiro.sh
    echo -e "#!/usr/bin/bash\n" >> shell/emiro.sh
    echo -e "" >> shell/emiro.sh
    echo "The folder contains files."
fi
echo "export EMIRO_PATH=$(pwd)" >> ~/.bashrc
source ~/.bashrc