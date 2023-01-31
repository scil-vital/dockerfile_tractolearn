FROM nvidia/cuda:11.8.0-base-ubuntu20.04

ENV ANTSPATH="/opt/ants-2.3.4/"
ENV PATH="/opt/ants-2.3.4:$PATH"
ENV TZ=America/Toronto

WORKDIR /home/fdumais/Desktop/Acuity/20221219_Bundling/20221219_FIESTA/final_tractolearn/tractolearn
ADD  configs /tractolearn/configs
ADD  doc /tractolearn/doc

ADD  scripts /tractolearn/scripts/
ADD  tractolearn /tractolearn/tractolearn/
ADD  requirements /tractolearn/requirements

ADD  setup.cfg /tractolearn/setup.cfg
ADD  setup_helpers.py /tractolearn/setup_helpers.py
ADD  setup.py /tractolearn/setup.py
ADD  README.md /tractolearn/README.md
ADD  LICENSE /tractolearn/LICENSE
ADD  fonts /usr/share/fonts/

RUN apt-get update -qq && \
    apt-get install -y -q --no-install-recommends \
       ca-certificates \
       curl \
       git

RUN apt install -y jq

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get -yq install libfontconfig1-dev

RUN apt-get install -y -q build-essential \
        autoconf \
        libtool \
        pkg-config \
        libgle3 && \
    apt-get -y install libblas-dev \
        liblapack-dev \
        gfortran \
        libxrender1

RUN apt-get install -y python3.8 python3.8-dev python3.8-distutils python3.8-venv

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.8 get-pip.py && \
    pip3.8 install --upgrade pip

RUN pip3.8 install git+https://github.com/scilus/scilpy.git@1.2.2

RUN rm -rf /var/lib/apt/lists/* && \
    echo "Downloading ANTs ..." && \
    mkdir -p /opt/ants-2.3.4 && \
    curl -fsSL https://dl.dropbox.com/s/gwf51ykkk5bifyj/ants-Linux-centos6_x86_64-v2.3.4.tar.gz \
        | tar -xz -C /opt/ants-2.3.4 --strip-components 1

RUN pip3.8 install --upgrade pickle5

RUN cd /tractolearn && \
    pip3.8 install torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio==0.8.1 -f https://download.pytorch.org/whl/cu111/torch_stable.html

RUN cd /tractolearn && pip3.8 install -e .

RUN pip install numpy==1.23.*

RUN chmod +x /tractolearn/scripts/*

ENV DISPLAY=:1

RUN Xvfb :1 -screen 1920x1080x24 > /dev/null 2>1 &
# RUN pip3.8 install pytest
# RUN python3.8 -m pytest -svv fury

# RUN apt-get install -y mesa-utils
