#!/usr/bin/bash

echo -e "\n\n\033[1;32m>>> Install Mission Planner\033[0m"

mkdir -p $home_dir/drone/mp

if [ -e /etc/os-release ]; then
    # Source the file to get the variables
    . /etc/os-release

    sudo apt install -y ca-certificates gnupg
    sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    # Check if the variable ID is set and if it is "ubuntu"
    if [ "$ID" == "ubuntu" ]; then
        # Check the version
        if [ "$VERSION_ID" == "18.04" ]; then
            echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
        elif [ "$VERSION_ID" == "20.04" ]; then
            echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
        else
            echo "Ubuntu version other than 18.04 or 20.04 detected."
            exit 1
        fi
    else
        echo "Not an Ubuntu distribution."
        exit 1
    fi
else
    echo "Unable to determine the distribution."
    exit 1
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