# Generated by: Neurodocker version 0.7.0+0.gdc97516.dirty
# Latest release: Neurodocker version 0.8.0
# Timestamp: 2022/04/12 08:32:32 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/ReproNim/neurodocker

FROM python:3.9.12-slim-buster

USER root

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'export USER="${USER:=`whoami`}"' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           wget build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ["deepmreye", "setup.py", "README.md", "requirements.txt", "/deepmreye/"]

WORKDIR /deepmreye

RUN pip install .

RUN pip install jupyterlab

RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

WORKDIR /home/neuro

COPY ["notebooks", "/home/neuro/notebooks"]

RUN mkdir -p /home/neuro/models

RUN wget https://osf.io/cqf74/download -O /home/neuro/dataset1_guided_fixations.h5

EXPOSE 8888

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "python:3.9.12-slim-buster" \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "wget build-essential" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "deepmreye", \
    \n        "setup.py", \
    \n        "README.md", \
    \n        "requirements.txt", \
    \n        "/deepmreye/" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/deepmreye" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "pip install ." \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "pip install jupyterlab" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/home/neuro" \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "notebooks", \
    \n        "/home/neuro/notebooks" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir -p /home/neuro/models" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "wget https://osf.io/cqf74/download -O /home/neuro/dataset1_guided_fixations.h5" \
    \n    ], \
    \n    [ \
    \n      "expose", \
    \n      [ \
    \n        "8888" \
    \n      ] \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json
