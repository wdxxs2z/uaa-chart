#!/bin/bash

if [ "$KUBERNETES_ENV" = "false" || "$KUBERNETES_ENV" = "" ]; then
    /usr/local/uaa/bin/job_properties.sh
fi

if [ ! -f /.pre_start_created ]; then
    /usr/local/uaa/bin/pre-start.sh
fi

exec catalina.sh run
