#!/bin/bash

if [ -z $KUBERNETES_ENV ]; then
    /usr/local/uaa/bin/job_properties.sh
    /usr/local/uaa/bin/pre-start.sh
    /usr/local/uaa/bin/pre-setup-dirs.sh
else
    /usr/local/uaa/bin/pre-setup-dirs.sh
fi

exec catalina.sh run
