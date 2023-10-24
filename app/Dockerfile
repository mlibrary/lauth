FROM ruby

# Docker build arguments/defaults
ARG UNAME=devenv
ARG UID=1001
ARG GID=1001

# Simple unix/linux tools
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y install --no-install-recommends \
      git \
      wget \
      vim

# Create development enviroment user home directory off of root directory
RUN groupadd -g $GID -o $UNAME && \
    useradd -m -d /$UNAME -u $UID -g $GID -o -s /bin/bash $UNAME

# Change ownership of home directory (possibly not needed)
COPY --chown=$UID:$GID . /$UNAME

USER $UNAME

WORKDIR /$UNAME

RUN gem install hanamismith

CMD ["sleep", "infinity"]
