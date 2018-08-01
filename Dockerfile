FROM nvidia/cudagl:9.0-runtime-ubuntu16.04

RUN apt-get update 
RUN apt-get install -y \
	software-properties-common \
  	ca-certificates \
	wget \
	firefox\
	curl \
	git  \
	python3-dev \
	mesa-utils
RUN apt-get install -y \
	g++ \
	cmake \
	cmake-gui \
	doxygen \
	mpi-default-dev \
	openmpi-bin \
	openmpi-common \
	libusb-1.0-0-dev \
	libqhull* \
	libusb-dev \
	libgtest-dev
RUN apt-get install -y \
	git-core \
	freeglut3-dev \
	pkg-config \
	build-essential \
	libxmu-dev \
	libxi-dev \
	libphonon-dev \
	libphonon-dev \
	phonon-backend-gstreamer
RUN apt-get install -y \
	phonon-backend-vlc \
	graphviz \
	mono-complete \
	qt-sdk \
	libflann-dev  
RUN apt-get install -y \
	libflann1.8 \
	libboost1.58-all-dev

# Text editors
RUN apt-get install -y \
	gedit \
	vim 
# Install sublime 
RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - && \
	echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
RUN apt-get update && \
	apt-get install sublime-text

########### Install PCL v 1.8 ###########
# Source https://askubuntu.com/questions/916260/how-to-install-point-cloud-library-v1-8-pcl-1-8-0-on-ubuntu-16-04-2-lts-for

# Add the JDK 8 and accept licenses (mandatory)
# Source https://gist.github.com/teekaay/39bff8c66cd8e43c2ba57a6b2eef4fa8
RUN add-apt-repository ppa:webupd8team/java && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN add-apt-repository -y ppa:webupd8team/java && \
	apt-get update && \
	apt-get --yes --no-install-recommends install oracle-java8-installer

RUN wget --quiet http://launchpadlibrarian.net/209530212/libeigen3-dev_3.2.5-4_all.deb && \
	dpkg -i libeigen3-dev_3.2.5-4_all.deb && \
	rm libeigen3-dev_3.2.5-4_all.deb
RUN apt-mark hold libeigen3-dev

RUN wget --quiet http://www.vtk.org/files/release/7.1/VTK-7.1.0.tar.gz && \
	tar -xf VTK-7.1.0.tar.gz && \
	rm VTK-7.1.0.tar.gz
RUN cd VTK-7.1.0 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install

RUN wget --quiet https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.0.tar.gz && \
	tar -xf pcl-1.8.0.tar.gz && \
	rm pcl-1.8.0.tar.gz
RUN cd pcl-pcl-1.8.0 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install

RUN rm -r /VTK-7.1.0 && \
	rm -r /pcl-pcl-1.8.0

# Install pip, numpy & cython python2&3
RUN wget --quiet https://bootstrap.pypa.io/get-pip.py && \
	python3 get-pip.py && \
RUN pip3 install --upgrade pip
RUN pip3 install cython==0.25.2
RUN pip3 install numpy

RUN python2 get-pip.py && \
	rm get-pip.py
RUN pip2 install --upgrade pip
RUN pip2 install cython==0.25.2
RUN pip2 install numpy


# Clone python-pcl repo
RUN git clone https://github.com/strawlab/python-pcl.git

# Modify setup.py
RUN cd python-pcl && \
	sed -i "s/# ext_args\['include_dirs'\]\.append('\/usr\/include\/vtk-5\.8')/ext_args\['include_dirs'\]\.append('\/usr\/local\/include\/vtk-7\.1')/g" setup.py && \
	sed -i "s/# ext_args\['library_dirs'\]\.append('\/usr\/lib')/ext_args\['library_dirs'\]\.append('\/usr\/lib')/g" setup.py && \
	sed -i "s/# Extension(\"pcl.pcl_visualization\"/Extension(\"pcl.pcl_visualization\"/g" setup.py
RUN cd python-pcl && \
	python3 setup.py build_ext -i && \
 	python3 setup.py install
RUN cd python-pcl && \
	python2 setup.py build_ext -i && \
	python2 setup.py install

