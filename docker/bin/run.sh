#!/bin/bash

if [ ! -f /.pre_start_created ]; then
    /usr/local/uaa/bin/pre-start.sh
fi

/usr/local/uaa/bin/job_properties.sh

exec catalina.sh run
