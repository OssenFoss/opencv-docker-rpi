#FROM raspbian:buster
FROM nuberegistry:80/raspbian/buster

# This prepares for either installing opencv or building opencv
RUN apt-get update && apt-get -y upgrade \
        && apt-get install -y \
	build-essential cmake pkg-config \
	libjpeg-dev libtiff5-dev libjasper-dev libpng-dev \
	libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
	libxvidcore-dev libx264-dev \
	libfontconfig1-dev libcairo2-dev \
	libgdk-pixbuf2.0-dev libpango1.0-dev \
	libgtk2.0-dev libgtk-3-dev \
	libatlas-base-dev gfortran \
	libhdf5-dev libhdf5-serial-dev libhdf5-103 \
	libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5 \
	python3-dev

RUN wget https://bootstrap.pypa.io/get-pip.py && \
	python3 get-pip.py && \
	rm -rf ~/.cache/pip
RUN apt-get install -y \
	python3-venv zip unzip
RUN pip install virtualenv virtualenvwrapper
# Enable our virtualenv 
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
ENV WORKON_HOME=$HOME/.virtualenvs

#$ mkvirtualenv cv -p python3

RUN pip3 install scipy \
                cython \
                keras 
RUN pip3 install \
                scikit-image \
			rpi.gpio \
			flask \
			gevent \
			zmq \
			picamera[array] \
			imutils

# Build OpenCV from source
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.1.1.zip && \
	wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.1.1.zip && \
	unzip opencv.zip && \
	unzip opencv_contrib.zip && \
	mv opencv-4.1.1 opencv && \
	mv opencv_contrib-4.1.1 opencv_contrib && \
	cd opencv && mkdir build && cd build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
    		-D CMAKE_INSTALL_PREFIX=/usr/local \
    		-D OPENCV_EXTRA_MODULES_PATH=$WORKDIR/opencv_contrib/modules \
    		-D ENABLE_NEON=ON \
    		-D ENABLE_VFPV3=ON \
    		-D BUILD_TESTS=OFF \
    		-D INSTALL_PYTHON_EXAMPLES=OFF \
    		-D OPENCV_ENABLE_NONFREE=ON \
    		-D CMAKE_SHARED_LINKER_FLAGS=-latomic \
    		-D BUILD_EXAMPLES=OFF .. && \
	make -j4 && \
	make install && \
	ldconfig && \
	cd ../.. && \
	rm -rf open* && \
	ls -lrt /

RUN cd /usr/local/lib/python3.7/site-packages/cv2/python-3.7 && \
	mv cv2.cpython-37m-arm-linux-gnueabihf.so cv2.so && \
	cd  /opt/venv/lib/python3.7/site-packages/ && \
	ln -s /usr/local/lib/python3.7/site-packages/cv2/python-3.7/cv2.so cv2.so

# A few missing bibs and bobs
RUN apt-get install -y \
	libraspberrypi-bin

# Copy the Python Scripts
#COPY run* ./
#COPY src ./src

# Trigger Python script
#CMD ./YourPythonScript PARM1 PARM2
