# Get environment variables, default is the author's username
# Need docker >= 17.0.5 in order to accept ARG before FROM
ARG DOCKER_USERNAME=doanminhdang

# Pull base image with swig precompiled
FROM $DOCKER_USERNAME/rpi-debian-swig:latest

# Define working directory
WORKDIR /home/pi

# Display previous time when swig was installed
RUN DATE_FILE=date_install_swig.txt && \
    if [ -f $DATE_FILE ]; then cat $DATE_FILE; fi

RUN git clone https://github.com/casadi/casadi.git -b master casadi

# Compile casadi
RUN cd /home/pi/casadi && \
    mkdir build && \
    cd build && \
    cmake -D WITH_PYTHON=ON .. && \
    make && \
    make install

# Add date for tracing the date of installing
RUN cd /home/pi && date -u '+%F %T %Z' > date_install_casadi.txt

# Set PYTHONPATH environment for casadi
ENV PYTHONPATH="${PYTHONPATH}:/usr/local/lib:/usr/local/python"

# Test
RUN python3 -c "import casadi"

# Define default command
CMD ["bash"]
