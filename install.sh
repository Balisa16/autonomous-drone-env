#!/usr/bin/bash

home_dir="$(cd && pwd)"
install_type="all"

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

is_installed() {
  dpkg -l "$1" &> /dev/null
}

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

help_message()
{
  echo "Usage: $0 [options]"
  echo "Mandatory arguments to long options are mandatory for short options too :"
  echo "  -h, --help       Show this help message and exit. You're see it now"
  echo "  -v, --version    Show version information"
  echo "  -d, --directory  Specify the homedirectory to install. Default will be ~ or $HOME"
  echo "  -m, --mode       Specify the install type. Default is all. Must be one of :"
  echo "                   all             Install all (default)"
  echo "                   ardupilot       [1] Install Ardupilot and Mavproxy only"
  echo "                   gazebo          [2] Install gazebo only"
  echo "                   ros             [3] Install ROS only"
  echo "                   simulation      [4] Install simulation only"
  echo "                   uav-system      [5] Install UAV-System (beta version) only"
  echo "                   mission-planner [6] Install Mission-Planner (beta version) only"
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

if [ ! -d "$home_dir/drone" ]; then
  echo -e "\n\n\033[1;32m>>> Creating Copter Directory\033[0m"
  mkdir -p $home_dir/drone
fi

case $install_type in
  "all")
    echo "Installing all"

    # ins_ardupilot_mavproxy

    # ins_gazebo

    # ins_ros

    # setup_workspace

    # ins_simulation

    # success

    # source source/uav_system.sh

    # source source/mission_planner.sh
    ;;
  "ardupilot")
    echo "Installing ardupilot and mavproxy"
    # ins_ardupilot_mavproxy
    ;;
  "gazebo")
    echo "Installing gazebo"
    # ins_gazebo
    ;;
  "ros")
    echo "Installing ROS"
    # ins_ros
    # setup_workspace
    ;;
  "simulation")
    echo "Installing simulation"
    # ins_simulation
    ;;
  "uav-system")
    echo "Installing uav-system"
    # source source/uav_system.sh
    ;;
  "mission-planner")
    echo "Installing mission-planner"
    # source source/mission_planner.sh
    ;;
  *)
    echo "Unknown option: $install_type"
    ;;
esac