#!/bin/bash -eu

# The BSD License
# Copyright (c) 2018 PickNik Consulting
# Copyright (c) 2014 OROCA and ROS Korea Users Group

#set -x

function usage {
    # Print out usage of this script.
    echo >&2 "usage: $0 [ROS distro (default: noetic)"
    echo >&2 "          [-h|--help] Print help message."
    exit 0
}

# Parse command line. If the number of argument differs from what is expected, call `usage` function.
OPT=`getopt -o h -l help -- $*`
if [ $# != 1 ]; then
    usage
fi
eval set -- $OPT
while [ -n "$1" ] ; do
    case $1 in
        -h|--help) usage ;;
        --) shift; break;;
        *) echo "Unknown option($1)"; usage;;
    esac
done

ROS_DISTRO=$1
ROS_DISTRO=${ROS_DISTRO:="noetic"}

version=`lsb_release -sc`
echo ""
echo "INSTALLING ROS USING quick_ros_install --------------------------------"
echo ""
echo "Checking the Ubuntu version"
case $version in
  "saucy" | "trusty" | "vivid" | "wily" | "xenial" | "bionic" | "focal")
  ;;
  *)
    echo "ERROR: This script will only work on Ubuntu Saucy(13.10) / Trusty(14.04) / Vivid / Wily / Xenial / Bionic / Focal. Exit."
    exit 0
esac

relesenum=`grep DISTRIB_DESCRIPTION /etc/*-release | awk -F 'Ubuntu ' '{print $2}' | awk -F ' LTS' '{print $1}'`
if [ "$relesenum" = "14.04.2" ]
then
  echo "Your ubuntu version is $relesenum"
  echo "Intstall the libgl1-mesa-dev-lts-utopic package to solve the dependency issues for the ROS installation specifically on $relesenum"
  sudo apt-get install -y libgl1-mesa-dev-lts-utopic
else
  echo "Your ubuntu version is $relesenum"
fi

echo "Add the ROS repository"
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"
fi


echo "Updating & upgrading all packages"
sudo apt-get update
sudo apt-get dist-upgrade -y

echo "Installing ROS"

# Support for Python 3 in Noetic
if [ "$ROS_DISTRO" = "noetic" ]
then
   sudo apt install -y \
	liburdfdom-tools \
	python3-rosdep \
	python3-rosinstall \
	python3-bloom \
	python3-rosclean \
	python3-wstool \
	python3-pip \
	python3-catkin-lint \
	python3-catkin-tools \
	python3-rosinstall \
	ros-$ROS_DISTRO-desktop-full
else
   exit 1
fi

# Only init if it has not already been done before
if [ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi
rosdep update

echo "Done installing ROS"

echo "#######################################################"

echo "Installing Turtlebot3"

sudo apt-get install ros-noetic-joy ros-noetic-teleop-twist-joy \
  ros-noetic-teleop-twist-keyboard ros-noetic-laser-proc \
  ros-noetic-rgbd-launch ros-noetic-rosserial-arduino \
  ros-noetic-rosserial-python ros-noetic-rosserial-client \
  ros-noetic-rosserial-msgs ros-noetic-amcl ros-noetic-map-server \
  ros-noetic-move-base ros-noetic-urdf ros-noetic-xacro \
  ros-noetic-compressed-image-transport ros-noetic-rqt* ros-noetic-rviz \
  ros-noetic-gmapping ros-noetic-navigation ros-noetic-interactive-markers

mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src/
git clone -b noetic-devel https://github.com/ROBOTIS-GIT/DynamixelSDK.git
git clone -b noetic-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone -b noetic-devel https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
git clone https://github.com/tu-darmstadt-ros-pkg/hector_slam.git
cd ~/catkin_ws && catkin_make
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
export TURTLEBOT3_MODEL=burger

echo "Done installing Turtlebot3"

echo "#######################################################"
 

echo "Installing Visual Studio Code"

sudo apt update
sudo apt install software-properties-common apt-transport-https wget
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt install code

echo "Done installing VS Code"

echo "#######################################################"

echo "Installing OpenCV"

sudo apt install libopencv-dev python3-opencv
echo "Done installing OpenCV"

echo "#######################################################"

echo "Install NumPy and Matplotlib"

pip install numpy matplotlib

echo "Done installing NumPy and Matplotlib"

echo "#######################################################"

exit 0
