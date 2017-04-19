#!/bin/bash

# Setup and run omero

set -eux

virtualenv /home/omero/omeropy-virtualenv --system-site-packages

# Get pip to download and install requirements:

set +o nounset
source ~omero/omeropy-virtualenv/bin/activate
set -o nounset


if [ "$1" == "omego" ]; then

    pip install omego
    omego download python
    
    OMERO_ZIP=`ls | grep OMERO.py*.zip`
    OMERO_ZIP="${OMERO_ZIP%.*}"

else

    echo Downloading ${1}
    OMERO_ZIP=`echo "$1" | rev | cut -d / -f 1 | rev`
    OMERO_ZIP="${OMERO_ZIP%.*}"

    curl -o ~omero/$OMERO_ZIP.zip ${1} && \
        unzip -d /home/omero $OMERO_ZIP.zip 

fi

ln -s ~omero/$OMERO_ZIP ~omero/OMERO.py && \
rm $OMERO_ZIP.zip

pip install zeroc-ice

pip install --upgrade pip
pip install --upgrade 'Pillow<3.0'
pip install --upgrade -r ~omero/OMERO.py/share/web/requirements-py27-nginx.txt

# load omero config
/home/omero/OMERO.py/bin/omero load /home/omero/omeroweb.config

# configure nginx
/home/omero/OMERO.py/bin/omero web config nginx > /home/omero/omero-web.conf.tmp
sudo cp /home/omero/omero-web.conf.tmp  /etc/nginx/conf.d/omero-web.conf
