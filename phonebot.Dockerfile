ARG VARIANT=20.04
FROM ubuntu:${VARIANT} AS dev
ARG DEBIAN_FRONTEND=noninteractive

ENV HOME=/root

# Install C++ Build Dependencies

RUN apt-get update && apt-get install --yes \
    python3-pip \
    firefox \
&&  rm --force --recursive /var/lib/apt/lists/*


# install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openssh-server \
    python3 \
    python3-dev \
    vim \
    wget \
    libssl-dev \
    curl \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install pip --upgrade pip


#upgrade node
RUN npm cache clean -f && npm install -g n && n stable && hash -r

#install development tools
RUN pip install robotframework robotframework-browser robotframework-tidy jinja2 numpy astropy
RUN rfbrowser init
RUN npx playwright install-deps

# Setup SSH keys
#COPY id_rsa /id_rsa
#COPY id_rsa.pub /id_rsa.pub
#WORKDIR $HOME/.ssh
#RUN echo "StrictHostKeyChecking no " > ~/.ssh/config && \
#   mv /id_rsa $HOME/.ssh/ && \
#   mv /id_rsa.pub $HOME/.ssh/ && \
#   chmod 600 $HOME/.ssh/id_rsa

# Install the phonebot repo
ARG PROJECT_URL
ARG PROJECT_NAME
ARG BRANCH_NAME
WORKDIR $HOME
RUN git clone --branch ${BRANCH_NAME} ${PROJECT_URL} $HOME/$PROJECT_NAME

#install ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb && dpkg -i ripgrep_13.0.0_amd64.deb

# Copy RC file(s)
COPY .inputrc $HOME/.inputrc
COPY .bash_aliases $HOME/.bash_aliases
COPY .vimrc $HOME/.vimrc
COPY .tmux.conf $HOME/.tmux.conf

WORKDIR $HOME/$PROJECT_NAME
RUN npm install --global yarn && yarn install

# Run in daemon state
CMD cd ${HOME} && \
   env > /.env && \
   tail -f &> /dev/null
