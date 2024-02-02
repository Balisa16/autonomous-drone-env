#!/usr/bin/bash

ins_ardupilot_mavproxy()
{
    echo -e "\n\n\033[1;32m>>> Installing Ardupilot and MAVProxy\033[0m"
    cd $home_dir/drone
    git clone https://github.com/ArduPilot/ardupilot.git
    cd ardupilot

    if [ $ubuntu_ver -eq 20 ]; then
        Tools/environment_install/install-prereqs-ubuntu.sh -y
        . ~/.profile

        # Checkout into the Copter branch
        git checkout Copter-4.4
        git submodule update --init --recursive

    elif [ $ubuntu_ver -eq 18 ]; then
        git checkout Copter-3.6
        git submodule update --init --recursive

        sudo apt install -y python-matplotlib python-serial python-wxgtk3.0 python-wxtools python-lxml python-scipy python-opencv ccache gawk python-pip python-pexpect

        sudo pip install future pymavlink MAVProxy

        echo "export PATH=$PATH:$home_dir/drone/ardupilot/Tools/autotest" >> ~/.bashrc
        echo "export PATH=/usr/lib/ccache:$PATH" >> ~/.bashrc
    fi

    source ~/.bashrc

    # # cd $home_dir/drone/ardupilot/ArduCopter
    # # sim_vehicle.py -w

    local args1=$1
    if [ "$args1" = "false" ]; then
        echo -e "\033[1;32m>>> Finished installing Ardupilot and MAVProxy\033[0m"
        exit 1
    fi
}

ins_gazebo()
{
    echo -e "\n\n\033[1;32m>>> Installing Gazebo\033[0m"

    # Setup Source and Keys
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt update
    
    # Install Gazebo
    if [ $ubuntu_ver -eq 20 ]; then
        sudo apt-get install -y gazebo11 libgazebo11-dev
        cd $home_dir/drone
        git clone https://github.com/khancyr/ardupilot_gazebo.git
        cd ardupilot_gazebo

    elif [ $ubuntu_ver -eq 18 ]; then
        sudo apt install -y gazebo9 libgazebo9-dev
        cd ~$home_dir/drone
        git clone https://github.com/khancyr/ardupilot_gazebo.git
        cd ardupilot_gazebo
        git checkout dev

    fi

    #  Build and Install
    mkdir build
    cd build
    cmake ..
    make -j$(( $(nproc) - 1 )) # Don't use full threads
    sudo make install

    # Register Gazebo
    echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc

    # Set Gazebo Model Path
    echo "export GAZEBO_MODEL_PATH=$home_dir/drone/ardupilot_gazebo/models" >> ~/.bashrc
    . ~/.bashrc

    local args1=$1
    if [ "$args1" = "false" ]; then
        echo -e "\033[1;32m>>> Finished installing Gazebo\033[0m"
        exit 1
    fi
}

ins_ros()
{
    if [ $ubuntu_ver -eq 20 ]; then
        echo -e "\n\n\033[1;32m>>> Installing ROS Noetic\033[0m"
    elif [ $ubuntu_ver -eq 18 ]; then
        echo -e "\n\n\033[1;32m>>> Installing ROS Melodic\033[0m"
    fi

    # Setup Source and Keys
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt install -y curl
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    # Update Package List
    sudo apt update

    # Install ROS Desktop Full
    if [ $ubuntu_ver -eq 20 ]; then
        sudo apt install -y ros-noetic-desktop-full
        echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
    elif [ $ubuntu_ver -eq 18 ]; then
        sudo apt install -y ros-melodic-desktop-full
        echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
    fi

    source ~/.bashrc

    #  Install Dependencies for ROS Building Packages
    if [ $ubuntu_ver -eq 20 ]; then
        sudo apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
        sudo apt install -y python3-rosdep
    elif [ $ubuntu_ver -eq 18 ]; then
        sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
        sudo apt install -y python-rosdep
    fi

    # Initialize rosdep
    sudo rosdep init
    rosdep update

    local args1=$1
    if [ "$args1" = "false" ]; then
        echo -e "\033[1;32m>>> Finished installing ROS\033[0m"
        exit 1
    fi
}

setup_workspace()
{
    echo -e "\n\n\033[1;32m>>> Setting up Workspace\033[0m"

    # Install desire dependencies
    if [ $ubuntu_ver -eq 20 ]; then
        sudo apt-get install -y python3-wstool python3-rosinstall-generator python3-catkin-lint python3-pip python3-catkin-tools
        pip3 install osrf-pycommon
    elif [ $ubuntu_ver -eq 18 ]; then
        sudo apt-get install python-wstool python-rosinstall-generator python-catkin-tools
    fi

    mkdir -p $home_dir/drone/ws/src
    cd $home_dir/drone/ws
    catkin init

    cd $home_dir/drone/ws
    if [ $ubuntu_ver -eq 20 ]; then
        . /opt/ros/noetic/setup.bash
    elif [ $ubuntu_ver -eq 18 ]; then
        . /opt/ros/melodic/setup.bash
    fi
    wstool init $home_dir/drone/ws/src

    rosinstall_generator --upstream mavros | tee /tmp/mavros.rosinstall
    rosinstall_generator mavlink | tee -a /tmp/mavros.rosinstall
    wstool merge -t src /tmp/mavros.rosinstall
    wstool update -t src
    rosdep install --from-paths src --ignore-src --rosdistro `echo $ROS_DISTRO` -y

    catkin build

    # Register Catkin devel path
    echo "source $home_dir/drone/ws/devel/setup.bash" >> ~/.bashrc
    source ~/.bashrc

    # Install Geographiclib
    sudo $home_dir/drone/ws/src/mavros/mavros/scripts/install_geographiclib_datasets.sh

    local args1=$1
    if [ "$args1" = "false" ]; then
        echo -e "\033[1;32m>>> Finished setup workspace\033[0m"
        exit 1
    fi
}

ins_simulation()
{
    echo -e "\n\n\033[1;32m>>> Installing Simulation\033[0m"

    # Clone and Checkout
    cd $home_dir/drone/ws/src
    git clone https://github.com/Balisa16/Simulation.git simulation
    cd simulation
    git submodule update --init --recursive

    # Build Simulation
    catkin build

    # Rewrite sitl.sh
    sitl_file="$home_dir/drone/ws/src/simulation/scripts/sitl.sh"
    sudo rm "$sitl_file"
    touch "$sitl_file"
    echo -e "#!$(which bash)\n" >> "$sitl_file"
    echo -e "sim()\n{\n\troslaunch simulation sitl.launch\n}\n" >> "$sitl_file"
    echo -e "sitl()\n{\n\tcd $home_dir/drone/ardupilot/ArduCopter\n\t. ~/.profile\n\tsim_vehicle.py -v ArduCopter -f gazebo-iris --console\n}\n" >> "$sitl_file"
    echo -e "apm_sim()\n{\n\troslaunch simulation apm.launch\n}\n" >> "$sitl_file"
    echo -e "apm()\n{\n\troslaunch mavros apm.launch\n}\n" >> "$sitl_file"

    sudo chmod +x "$sitl_file"

    # Register Gazebo Model Path
    echo "GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:$home_dir/drone/ws/src/simulation/models:$home_dir/drone/ws/src/simulation/models2" >> ~/.bashrc
    echo "source $home_dir/drone/ws/src/simulation/scripts/sitl.sh" >> ~/.bashrc 
    source ~/.bashrc

    local args1=$1
    if [ "$args1" = "false" ]; then
        echo -e "\033[1;32m>>> Finished installing Simulation\033[0m"
        exit 1
    fi
}

success()
{
    echo -e "\n\n\033[1;32m>>> Installation Finished\033[0m"
    echo -e "You can try this :"
    echo -e "+ Terminal 1 : \033[32msim\033[0m"
    echo -e "+ Terminal 2 : \033[32msitl\033[0m"
    echo -e "+ Terminal 3 : \033[32mapm_sim\033[0m"
}
