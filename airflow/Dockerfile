FROM fedora:28

# Image metadata
ENV NAME="stufff-ml/openshift-airflow" \
    SUMMARY="Apache Airflow on OpenShift"	\
    DESCRIPTION="Apache Airflow on OpenShift" \
    MAINTAINER="stufff-ml <hello@ratchet.cc>" \
    VENDOR="stufff-ml" \
    TAGS="fedora, airflow" \
    VERSION="1.10" \
    RELEASE="1.10"

LABEL name="$NAME" \
      maintainer="$MAINTAINER" \
      vendor="$VENDOR" \
      version="$VERSION" \
      release="$RELEASE" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="DESCRIPTION" \
      io.k8s.display-name="$NAME" \
      io.openshift.tags="$TAGS"

#
# Prepare the image
#

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    HOME="/usr/local/app" \
    USER_ID=1001 \
    USER_NAME=default

ENV ARCH=x86_64 \
    PYTHON_ALIAS="python3" \
    PIP_ALIAS="pip3" \
    PIP_ARGS="" \
    PYTHON_VERSION="3.6" \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING="UTF-8" \
    PIP_NO_CACHE_DIR="off"

ENV PATH=$HOME/.local/bin/:$PATH

# Install the very basics
RUN yum install -y dnf

# Additional packages
ENV INSTALL_PKGS="autoconf automake make gcc patch unzip python3 python3-devel python3-setuptools python3-pip python3-virtualenv"  

# Copy scripts to /usr/bin
COPY ./include/ /

RUN mkdir -p ${HOME}/.pki/nssdb && \
    chown -R ${USER_ID}:0 ${HOME}/.pki && \
    dnf -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    dnf -y clean all --enablerepo='*' && \
    fix-rpm-file-permissions

# Add the default user
RUN useradd -u ${USER_ID} -r -g 0 -d ${HOME} -s /sbin/nologin \
    -c "Default User" ${USER_NAME} && \
    chown -R ${USER_ID}:0 ${HOME}

# see https://github.com/jupyter/docker-stacks/issues/552
RUN chmod 766 /etc/passwd && chmod 766 /etc/group

#
# Install Airflow
#

ENV AIRFLOW_VERSION=1.10.0 \
    AIRFLOW_HOME="/usr/local/app" \
    AIRFLOW_GPL_UNIDECODE="True" \
    AIRFLOW_CMD="webserver" \
    AIRFLOW_MODULES="'crypto','kubernetes','postgres','s3','gcp_api'"

ENV PYTHONPATH=${PYTHONPATH:+${PYTHONPATH}:}${AIRFLOW_HOME}

# - Create a Python virtual environment for use by any application to avoid
#   potential conflicts with Python packages preinstalled in the main Python
#   installation.

# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.
RUN virtualenv-$PYTHON_VERSION ${AIRFLOW_HOME} && \
    chown -R ${USER_ID}:0 ${AIRFLOW_HOME} && \
    fix-permissions ${AIRFLOW_HOME} -P

ENV AIRFLOW_MODULES="apache-airflow['crypto','kubernetes','postgres','s3','gcp_api']"

RUN ${PIP_ALIAS} install --no-cache-dir ${AIRFLOW_MODULES}==${AIRFLOW_VERSION}

# Create directories so we can own them when we mount volumes
RUN mkdir -p ${AIRFLOW_HOME}/logs && mkdir -p ${AIRFLOW_HOME}/dags

#
# Finalize the image
#

RUN chown -R ${USER_ID}:0 ${AIRFLOW_HOME} && \
	fix-permissions ${AIRFLOW_HOME} -P

# Switch to AIRFLOW_HOME
WORKDIR ${AIRFLOW_HOME}
USER ${USER_ID}

# Expose all airflow ports
EXPOSE 8080 5555 8793

# Run airflow with minimal init
CMD ["start-airflow"]
