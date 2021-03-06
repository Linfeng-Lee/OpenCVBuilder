#!/bin/bash

echo "Build and install OpenCV in MacOS."

HOME=/Users/lee

INSTALL_DIR=/opt/opencv/build
CMAKE_INSTALL_PREFIX=$INSTALL_DIR

# PYTHON3_EXECUTABLE=$HOME/miniforge3/envs/torch/bin/python3
OPENCV_SOURCE_DIR=$HOME/Desktop/github_download/opencv/opencv_4.x
OPENCV_CONTRIB_SOURCE_DIR=$HOME/Desktop/github_download/opencv/opencv_contrib_4.x/modules
OPENCV_PKG_PATH=${INSTALL_DIR}/lib/pkgconfig/opencv.pc
OPENCV_CMAKE_PATH=${INSTALL_DIR}/lib/cmake/opencv4

echo "Build configuration: "
echo " OpenCV Source Path: $OPENCV_SOURCE_DIR"
echo " OpenCV Contrib Source Path: $OPENCV_CONTRIB_SOURCE_DIR"
echo " OpenCV binaries will be installed in: $INSTALL_DIR"
echo " OpenCV pkgconfig path: $OPENCV_PKG_PATH"
echo " OpenCV cmake path: $OPENCV_CMAKE_PATH"
echo " Python3 executable: $PYTHON3_EXECUTABLE"

echo "Install python3 dependency..."
brew install python3-dev python3-numpy python3-py python3-pytest
echo "Install python3 dependency done."


cd $OPENCV_SOURCE_DIR
mkdir build
cd build

function run_cmake(){
  time cmake \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_OSX_ARCHITECTURES=arm64 \
  -D CMAKE_SYSTEM_PROCESSOR=arm64 \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
  -D OPENCV_EXTRA_MODULES_PATH=${OPENCV_CONTRIB_SOURCE_DIR} \
  -D PYTHON_DEFAULT_EXECUTABLE=$(python -c "import sys; print(sys.executable)")   \
  -D PYTHON3_EXECUTABLE=$(python -c "import sys; print(sys.executable)")   \
  -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python -c "import numpy; print (numpy.get_include())") \
  -D PYTHON3_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D BUILD_opencv_python3=ON \
  -D WITH_OPENJPEG=OFF \
  -D WITH_IPP=OFF \
  -D WITH_TBB=OFF \
  -D INSTALL_C_EXAMPLES=OFF \
  -D OPENCV_ENABLE_NONFREE=ON \
  -D BUILD_EXAMPLES=ON \
  -D ENABLE_FAST_MATH=ON \
  -D WITH_LIBV4L=ON \
  -D WITH_OPENGL=ON \
  ../

  if [ $? -eq 0 ] ; then
    echo "CMake configuration make successful"
  else
    echo "CMake issues " >&2
    echo "Please check the configuration being used"
    exit 1
  fi
}

sleep 2

function make_opencv(){
  NUM_CPU=8
  echo "NUM_CPU: $NUM_CPU"
  time make -j$NUM_CPU

  if [ $? -eq 0 ] ; then
    echo "OpenCV make successful"

  else
    echo "Make did not build " >&2
    echo "Retrying ... "
  
    make
    if [ $? -eq 0 ] ; then
      echo "OpenCV make successful"
  
    else
      echo "Make did not successfully build" >&2
      echo "Please fix issues and retry build"
      exit 1
    fi
  fi

}

function make_install(){
    echo "Installing ... "
  sudo make install
  if [ $? -eq 0 ] ; then
    echo "OpenCV installed in: $CMAKE_INSTALL_PREFIX"
  else
    echo "There was an issue with the final installation"
    exit 1
  fi
}

run_cmake
make_opencv
make_install

echo "pkg-config --cflags opencv4:"
echo $(pkg-config --cflags opencv4)

echo "pkg-config --libs opencv4:"
echo $(pkg-config --libs opencv4)
