
set -v

GETIP="$(gcloud sql instances describe page-db-instance --format='get(ipAddresses[0].ipAddress)')"

# Install Stackdriver logging agent
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
sudo bash install-logging-agent.sh

# Install prerequisites
apt-get update
apt-get install -yq git supervisor python python-pip
pip install --upgrade pip virtualenv

# account to own server process
useradd -m -d /home/pythonapp pythonapp

# get source code
export HOME=/root
git clone https://github.com/ConorMcFeelyQUB/cloud-index-test.git /opt/app

# Python setup
virtualenv -p python3 /opt/app/gce/env
source /opt/app/gce/env/bin/activate
/opt/app/gce/env/bin/pip install -r /opt/app/gce/requirements.txt

# supervisor set ownership for the account
chown -R pythonapp:pythonapp /opt/app

echo -n ',PAGEIP='"${GETIP}" >> /opt/app/gce/python-app.conf

# supervisor configuration in proper place
cp /opt/app/gce/python-app.conf /etc/supervisor/conf.d/python-app.conf

supervisorctl reread
supervisorctl update