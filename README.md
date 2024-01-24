# Autonomous Drone Installation

Script to install simple Autonomous Drone Simulation System in Ubuntu 18.04 or Ubuntu 20.04. This ideally start after you install your ubuntu (New Ubuntu)

## Run
Run Installation
```
./install.sh <option>
source ~/.bashrc
```
***option*** can be :
- **mission-planner** : if you want to install mission planner only.
- **uav-system** : if you want to try simulation of my Autonomous UAV System (beta) only.
- **simulation** : if you already install ardupilot and gazebo and want to install simulator.
- **all** or leave it blank : if you want to install all.
Find a comfortable seat and enjoy your coffee :coffee: while waiting for the installation process to finish. This process will take about 25 minutes.

## Noted
1. In the first time, when you run ``sitl`` you'll find that arducopter compile their library. It's ok and please wait until terminal show like [this](images/first_sitl.png). Compilation just occurred in the first SITL run, so it will be faster in subsequent SITL runs.
2. When installation is finished and you're run ```catkin build``` in ~/drone/ws. Your terminal should looks like [this](images/build.png)
3. I am not tested this shell for Ubuntu 18 yet. So may will be there are some error. I would like say thanks if there someone tested and give correction for [Ubuntu 18](source/ubuntu18.sh) installation script.

## References
1. [Intelligent-Quads](https://github.com/Intelligent-Quads)
2. [Ardupilot](https://github.com/Ardupilot)
3. [ROS](https://github.com/ros)
4. [Gazebo](https://gazebosim.org/home)