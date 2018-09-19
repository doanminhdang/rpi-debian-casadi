# Get environment variables, default is the author's username
# Need docker >= 17.0.5 in order to accept ARG before FROM
ARG DOCKER_ORGANIZATION=doanminhdang
ARG SWIG_IMAGE_TAG=latest

# Pull base image with swig precompiled
FROM $DOCKER_ORGANIZATION/rpi-debian-swig:$SWIG_IMAGE_TAG

# Define working directory
WORKDIR /home/pi

# Display previous time when swig was installed
RUN DATE_FILE=date_install_swig.txt && \
    if [ -f $DATE_FILE ]; then cat $DATE_FILE; fi

RUN git clone https://github.com/casadi/casadi.git -b master casadi

ARG CASADI_VERSION

# Change to the specified version of casadi
RUN cd /home/pi/casadi && \
    git checkout tags/$CASADI_VERSION

# Compile casadi
RUN cd /home/pi/casadi && \
    mkdir build && \
    cd build && \
    cmake -D WITH_PYTHON=ON .. && \
    make && \
    make install

# Add date for tracing the date of installing casadi
RUN cd /home/pi && date -u '+%F %T %Z' > date_install_casadi.txt
RUN cd /home/pi && echo CasADi version: $CASADI_VERSION > version_casadi.txt

# Set PYTHONPATH environment for casadi
ENV PYTHONPATH="${PYTHONPATH}:/usr/local/lib:/usr/local/python"

# Test
RUN python3 -c "import casadi"

# Make port 22 available to the world outside this container
EXPOSE 22

# Define default command
CMD ["bash"]
