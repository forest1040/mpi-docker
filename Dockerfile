FROM ubuntu:20.04

ENV USER mpirun

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER} 

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends git build-essential cmake vim curl && \
    apt-get install -y --no-install-recommends openmpi-bin libopenmpi-dev libscalapack-openmpi-dev libopenblas-dev intel-mkl && \
    apt-get install -y --no-install-recommends sudo openssh-server && \
    apt-get install -y --no-install-recommends python3-dev python3-numpy python3-pip python3-virtualenv python3-scipy && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN echo 'root:${USER}' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN adduser --disabled-password --gecos "" ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ssh
ENV SSHDIR ${HOME}/.ssh/

RUN mkdir -p ${SSHDIR}

ADD ssh/config ${SSHDIR}/config
ADD ssh/id_rsa.mpi ${SSHDIR}/id_rsa
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/id_rsa.pub
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/authorized_keys

RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${USER}:${USER} ${SSHDIR}

RUN pip install --upgrade pip

USER ${USER}
RUN  pip install --user -U setuptools \
    && pip install --user mpi4py

# OpenMPI
USER root

RUN rm -fr ${HOME}/.openmpi && mkdir -p ${HOME}/.openmpi
ADD default-mca-params.conf ${HOME}/.openmpi/mca-params.conf
RUN chown -R ${USER}:${USER} ${HOME}/.openmpi

# Copy MPI4PY example scripts
ENV TRIGGER 1

ADD mpi4py_benchmarks ${HOME}/mpi4py_benchmarks
RUN chown -R ${USER}:${USER} ${HOME}/mpi4py_benchmarks

# mptensor build
RUN cd ${HOME} && git clone https://github.com/smorita/mptensor.git
ADD Makefile.option ${HOME}/mptensor/
RUN cd ${HOME}/mptensor && mkdir build && cd build && \
    cmake -DSCALAPACK_LIB=/usr/lib/x86_64-linux-gnu/libscalapack-openmpi.so ../ && \
    make -j ${JOBS}

# mptensor test build
RUN cd ${HOME}/mptensor/tests && \
    make -j ${JOBS}

# mptensor examples/Ising_2D build
RUN cd ${HOME}/mptensor/examples/Ising_2D && \
    make -j ${JOBS}

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
