#
# Dockerfile for an image with the currently checked out version of zipline installed. To build:
#
#    docker build -t stanleyu/quantopian-base-image .
#
#
FROM python:3.5

#
# set up environment
#
ENV TINI_VERSION v0.10.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

ENV PROJECT_DIR=/projects \
    NOTEBOOK_PORT=8888 \
    SSL_CERT_PEM=/root/.jupyter/jupyter.pem \
    SSL_CERT_KEY=/root/.jupyter/jupyter.key \
    PW_HASH="u'sha1:31cb67870a35:1a2321318481f00b0efdf3d1f71af523d3ffc505'" \
    CONFIG_PATH=/root/.jupyter/jupyter_notebook_config.py

#
# install TA-Lib and other prerequisites
#

RUN mkdir ${PROJECT_DIR} \
    && apt-get -y update \
    && apt-get -y install libfreetype6-dev libpng-dev libopenblas-dev liblapack-dev gfortran libhdf5-dev \
    && curl -L https://downloads.sourceforge.net/project/ta-lib/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz | tar xvz

#
# build and install zipline from source.  install TA-Lib after to ensure
# numpy is available.
#

WORKDIR /ta-lib

RUN pip install 'numpy>=1.11.1,<2.0.0' \
  && pip install 'scipy>=0.17.1,<1.0.0' \
  && pip install 'pandas>=0.18.1,<1.0.0' \
  && ./configure --prefix=/usr \
  && make \
  && make install \
  && pip install TA-Lib \
  && pip install matplotlib \
  && pip install jupyter \
  && pip install pyfolio

#
# This is then only file we need from source to remain in the
# image after build and install.
#

ADD ./etc/init_jupyter.sh /

RUN /init_jupyter.sh
