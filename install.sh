#!/usr/bin/bash

# Check if the /etc/os-release file exists
if [ -e /etc/os-release ]; then
    # Source the file to get the variables
    . /etc/os-release

    # Check if the variable ID is set and if it is "ubuntu"
    if [ "$ID" == "ubuntu" ]; then
        # Check the version
        if [ "$VERSION_ID" == "18.04" ]; then
            echo "Ubuntu 18.04 detected."
            source source/ubuntu18.sh
        elif [ "$VERSION_ID" == "20.04" ]; then
            echo "Ubuntu 20.04 detected."
            source source/ubuntu20.sh
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



install_type="all"

if [ ! "$#" -eq 0 ]; then
    install_type=$1
    install_type=$(echo "$install_type" | tr '[:upper:]' '[:lower:]')
fi


case $install_type in
  "all")
    init_dir

    echo -e "\n\n\033[1;32m>>> Updating Ubuntu\033[0m"
    sudo apt update
    sudo apt upgrade -y
    
    echo -e "\n\n\033[1;32m>>> Installing CMake and Git\033[0m"
    sudo apt install -y cmake git

    ins_ardupilot_mavproxy

    ins_gazebo

    ins_ros

    setup_workspace

    ins_simulation

    success
    ;;
  "simulation")
    ins_simulation
    ;;
  "uav-system")
    echo "You choose UAV-Simulation"
    ;;
  *)
    echo "Unknown option: $install_type"
    ;;
esac

