
set -v

# Install Stackdriver logging agent
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
sudo bash install-logging-agent.sh


#storing ip of database to put into conf file

GETIPADVERT="$(gcloud sql instances describe advert-db-instance --format='get(ipAddresses[0].ipAddress)')"

GETIPPAGE="$(gcloud sql instances describe page-db-instance --format='get(ipAddresses[0].ipAddress)')"

# Install prerequisits
apt-get update
apt-get install -yq git supervisor python python-pip
pip install --upgrade pip virtualenv

# Account to own server process
useradd -m -d /home/pythonapp pythonapp

# get source code
export HOME=/root
git clone https://github.com/ConorMcFeelyQUB/cloud-search.git /opt/app

# Python setup
virtualenv -p python3 /opt/app/gce/env
source /opt/app/gce/env/bin/activate
/opt/app/gce/env/bin/pip install -r /opt/app/gce/requirements.txt

# for supervisor set the ownership of the account
chown -R pythonapp:pythonapp /opt/app

#Put DB ips in envariables 
echo -n ',ADVERTIP='"${GETIPADVERT}" >> /opt/app/gce/python-app.conf

echo -n ',PAGEIP='"${GETIPPAGE}" >> /opt/app/gce/python-app.conf

# Put supervisor configuration in proper place
cp /opt/app/gce/python-app.conf /etc/supervisor/conf.d/python-app.conf

# Start service 
supervisorctl reread
supervisorctl update
