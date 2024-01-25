#!/usr/bin/bash

home_dir="$(cd && pwd)"
install_type="all"
ubuntu_ver=0

is_installed() {
  dpkg -l "$1" &> /dev/null
}

help_message()
{
  echo "Usage: $0 [options]"
  echo -e "\nMandatory arguments to long options are mandatory for short options too :"
  echo -e "\033[1m  -h, --help       \033[0mShow this help message and exit. You're see it now"
  echo -e "\033[1m  -v, --version    \033[0mShow version information"
  echo -e "\033[1m  -d, --directory  \033[0mSpecify the homedirectory to install. Default will be ~ or $HOME"
  echo -e "\033[1m  -m, --mode       \033[0mSpecify the install type. Must be one of :"
  echo -e "                   \033[3mall             \033[0mInstall all (default)"
  echo -e "                   \033[3mardupilot       \033[0m[1] Install Ardupilot and Mavproxy only"
  echo -e "                   \033[3mgazebo          \033[0m[2] Install Gazebo only"
  echo -e "                   \033[3mros             \033[0m[3] Install ROS only"
  echo -e "                   \033[3msimulation      \033[0m[4] Install Simulation only"
  echo -e "                   \033[3muav-system      \033[0m[5] Install UAV-System (beta version) only"
  echo -e "                   \033[3mmission-planner \033[0m[6] Install Mission-Planner (beta version) only"
  echo -e "\n\033[1mExample :\033[0m"
  echo -e "\033[1;32m$0 -m simulation                \033[0mTo install simulation only in default directory : $home_dir"
  echo -e "\033[1;32m$0 -d /home/user                \033[0mTo install all system in desired directory"
  echo -e "\033[1;32m$0 -m simulation -d /home/user  \033[0mTo install simulation only in desired directory"
}

counter=1

# Loop through each command-line argument
for arg in "$@"; do
  counter_used=false
  # Swicth on the argument
  #  if arg == "-h" or arg == "--help" then print help
  if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
    help_message
    exit 1
  elif [ "$arg" == "-v" ] || [ "$arg" == "--version" ]; then
    echo "Version 1.0.0"
  elif [ "$arg" == "-d" ] || [ "$arg" == "--directory" ]; then
    if [ "$counter" -lt "$#" ]; then
      counter_used=true
      ((counter++))
      home_dir="${!counter}"
    else
      echo "Error: -d/--directory option requires a directory path."
      exit 1
    fi
  elif [ "$arg" == "-m" ] || [ "$arg" == "--mode" ]; then
    if [ ! "$#" -eq 0 ]; then
      counter_used=true
      ((counter++))
      install_type="${!counter}"
      install_type=$(echo "$install_type" | tr '[:upper:]' '[:lower:]')
    fi
  fi

  if [ "$counter_used" = false ]; then
    ((counter++))
  fi
done

echo -e "\n\n\033[1;32m>>> Updating Ubuntu\033[0m"
sudo apt update

# Check if cmake is installed
if ! is_installed cmake; then
  echo "Installing cmake..."
  echo -e "\n\n\033[1;32m>>> Installing CMake\033[0m"
  sudo apt install -y cmake
fi

# Check if git is installed
if ! is_installed git; then
  echo "Installing git..."
  echo -e "\n\n\033[1;32m>>> Installing Git\033[0m"
  sudo apt install -y git
fi

if [ ! -d "$home_dir/drone" ]; then
  echo -e "\n\n\033[1;32m>>> Creating Copter Directory\033[0m"
  mkdir -p $home_dir/drone
fi

# Check if the /etc/os-release file exists
if [ -e /etc/os-release ]; then
    # Source the file to get the variables
    . /etc/os-release

    # Check if the variable ID is set and if it is "ubuntu"
    if [ "$ID" == "ubuntu" ]; then
        # Check the version
        if [ "$VERSION_ID" == "18.04" ]; then
            echo "Ubuntu 18.04 detected."
            ubuntu_ver=18
        elif [ "$VERSION_ID" == "20.04" ]; then
            echo "Ubuntu 20.04 detected."
            ubuntu_ver=20
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

if [ $ubuntu_ver -eq 0 ]; then
  exit 1
fi

source source/core.sh

case $install_type in
  "all")
    ins_ardupilot_mavproxy

    ins_gazebo

    ins_ros

    setup_workspace

    ins_simulation

    success

    source source/uav_system.sh

    source source/mission_planner.sh
    ;;
  "ardupilot")
    ins_ardupilot_mavproxy false
    ;;
  "gazebo")
    ins_gazebo
    ;;
  "ros")
    ins_ros
    setup_workspace
    ;;
  "simulation")
    ins_simulation
    ;;
  "uav-system")
    source source/uav_system.sh
    ;;
  "mission-planner")
    source source/mission_planner.sh
    ;;
  *)
    echo "Unknown option: $install_type"
    ;;
esac