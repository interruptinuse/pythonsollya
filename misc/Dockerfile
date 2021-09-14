FROM ubuntu:20.04 AS ci_pythonsollya_deps

RUN apt update

# setup dpkg (behind apt) to be non-interactive
# prevent some dependencies (e.g. tzdata) from spuriously
# prompting the user during apt-get install
ARG DEBIAN_FRONTEND=noninteractive

RUN apt install -y git
RUN apt install -y python3 python3-setuptools libpython3-dev python3-pip
# install sollya's dependency
RUN apt install -y libmpfr-dev libmpfi-dev libfplll-dev libxml2-dev wget
RUN apt install -y dh-autoreconf
RUN apt install -y build-essential
RUN apt install -y bison flex

FROM ml_ci_base_deps AS ci_pythonsollya_base

# install sollya
WORKDIR  /home/

RUN git clone https://gitlab.inria.fr/sollya/sollya.git -b master sollya_git
WORKDIR /home/sollya_git/
RUN sh autogen.sh && ./configure && make && make install

#
WORKDIR /home/
