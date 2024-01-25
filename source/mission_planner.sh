#!/usr/bin/bash

ins_mission_planner()
{
    echo -e "\n\n\033[1;32m>>> Install Mission Planner\033[0m"

    mkdir -p $home_dir/drone/mp

    # Check the version
    if [ $ubuntu_ver -eq 20 ]; then
        echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
    elif [ $ubuntu_ver -eq 18 ]; then
        echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
    fi

    sudo apt update
    sudo apt install -y mono-complete

    wget -q -O mp.zip https://firmware.ardupilot.org/Tools/MissionPlanner/MissionPlanner-latest.zip
    unzip mp.zip -d $home_dir/drone/mp
    rm mp.zip

    rm -f $home_dir/drone/mp/missionplanner.sh 2>/dev/null
    touch $home_dir/drone/mp/missionplanner.sh

    echo -e "mp(){\n" >> $home_dir/drone/mp/missionplanner.sh
    echo -e "\tmono $home_dir/drone/mp/MissionPlanner.exe\n}" >> $home_dir/drone/mp/missionplanner.sh

    echo "source $home_dir/drone/mp/missionplanner.sh" >> ~/.bashrc
    echo -e "Mission Planner installed.\n>>> You can use \033[1;32mmp\033[0m command to run the Mission Planner."

    local args1=$1
    if [ "$args1" = "false" ]; then
        echo -e "\033[1;32m>>> Finished installing Mission Planner\033[0m"
        exit 1
    fi
}