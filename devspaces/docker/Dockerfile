FROM phusion/baseimage:0.11

LABEL description="Devspaces implementation for Remote Retro"

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
        locales \
        curl    \
        wget    \
        gzip    \
        bzip2   \
        unzip   \
        build-essential \
        autoconf \
        libncurses5-dev \
        libssl-dev \
        sudo \
        git  \
        inotify-tools \
    && apt-get clean \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the locale
RUN sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen \
    && locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

#
# Install Chrome for e2e tests
#
RUN wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | apt-key add -  \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
  && apt-get update && apt-get install -y  \
    libx11-6 \
    libxss1 \
    fonts-liberation \
    libappindicator1 \
    libindicator7 \
    google-chrome-stable \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#
# Install postgres
#
ENV PG_VERSION  9.6
ENV PG_ETC      /etc/postgresql/${PG_VERSION}/main
ENV PG_DIR      /var/lib/postgresql
ENV PG_DATA     ${PG_DIR}/data
ENV PATH        ${PG_DIR}/${PG_VERSION}/bin:$PATH

# Create  postgres user, add repos and install postgres.
RUN set -eux; \
    groupadd -r postgres --gid=999; \
    useradd -r -g postgres --uid=999 --home-dir=${PG_DIR} --shell=/bin/bash postgres; \
    mkdir -p ${PG_DIR}; \
    chown -R postgres:postgres ${PG_DIR}; \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' ; \
    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - ; \
    apt-get update ; \
    apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages install \
    postgresql-${PG_VERSION} postgresql-contrib-${PG_VERSION} libpq-dev ; \
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/*

#
# Configure retro user
#
ENV USER retro
ENV HOME /home/${USER}

RUN useradd -ms /bin/bash ${USER} \
  && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to retro user from now
USER ${USER}

COPY .tool-versions /opt/devspaces/.tool-versions
#RUN mkdir /data && sudo chown -R ${USER}:${USER} /data

WORKDIR ${HOME}

#
# Install ASDF version manager, Erlang, Elixir
#
ENV ASDF_VERSION v0.5.1
# https://github.com/stride-nyc/remote_retro#elixirphoenix-dependencies
# Install the asdf version manager
ENV PATH="${PATH}:${HOME}/.asdf/shims:${HOME}/.asdf/bin"

RUN git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch ${ASDF_VERSION} \
  && chmod +x ${HOME}/.asdf/asdf.sh \
  && echo 'export PATH="${PATH}:${HOME}/.asdf/shims:${HOME}/.asdf/bin"' > $HOME/.bashrc \
  \
  && /bin/bash -c "asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git;" \
  && /bin/bash -c "asdf install erlang $(awk '/erlang/ { print $2 }' /opt/devspaces/.tool-versions)" \
  && /bin/bash -c "asdf global erlang $(awk '/erlang/ { print $2 }' /opt/devspaces/.tool-versions)" \
  \
  && /bin/bash -c "asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git;" \
  && /bin/bash -c "asdf install elixir $(awk '/elixir/ { print $2 }' /opt/devspaces/.tool-versions)" \
  && /bin/bash -c "asdf global elixir $(awk '/elixir/ { print $2 }' /opt/devspaces/.tool-versions)"

#
# Install NVM, Node JS and phantom JS
#
ENV NVM_VERSION v0.33.1
ENV NODE_VERSION 8.10.0
ENV NVM_DIR ${HOME}/.nvm

# https://github.com/trilogy-group/remote_retro#node-dependencies
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | bash \
  \
  && . ${NVM_DIR}/nvm.sh \
  && nvm install ${NODE_VERSION} \
  && npm install -g \
    yarn \
    phantomjs \
    chromedriver \
  && yarn

#
# Switch back to root and finalize startup scripts
#
USER root

#
# Copy assets and Install services
#
COPY assets /opt/devspaces/assets
RUN chmod +x /opt/devspaces/assets/scripts/* \
    && chmod +x /opt/devspaces/assets/entrypoint.sh \
    && cp /opt/devspaces/assets/scripts/* /usr/local/bin/

# Install services
COPY assets/services /etc/service
RUN chmod +x /etc/service/postgres/run \
  && chmod +x /etc/service/postgres/log/run

WORKDIR /data

EXPOSE 4000 5001 5432

ENTRYPOINT /opt/devspaces/assets/entrypoint.sh

CMD tail -f /dev/null
