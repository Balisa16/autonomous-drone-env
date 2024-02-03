#!/usr/bin/bash
home_dir="/home/all"

sitl_file="$home_dir/drone/ws/src/simulation/scripts/sitl.sh"
sudo rm "$sitl_file"
touch "$sitl_file"
echo -e "#!$(which bash)\n" >> "$sitl_file"
echo -e "sim()\n{\n\troslaunch simulation sitl.launch\n}\n" >> "$sitl_file"
echo -e "sitl()\n{\n\tlocal currentdir=\$(pwd)\n\tcd $home_dir/drone/ardupilot/ArduCopter\n\t. ~/.profile\n\tsim_vehicle.py -v ArduCopter -f gazebo-iris --console\n\tcd \$currentdir\n}\n" >> "$sitl_file"
echo -e "apm_sim()\n{\n\troslaunch simulation apm.launch\n}\n" >> "$sitl_file"
echo -e "apm()\n{\n\troslaunch mavros apm.launch\n}" >> "$sitl_file"