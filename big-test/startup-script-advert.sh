
set -v

#Trying to set env variable permanently so adding to bashrc then sourcing it to refresh
#python os.get will hopefully be able to see it
#echo 'export' ABZ'='"222">>~/.bashrc
#source ~/.bashrc

GETIP="$(gcloud sql instances describe advert-db-instance-b --format='get(ipAddresses[0].ipAddress)')"


# Install Stackdriver logging agent
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
sudo bash install-logging-agent.sh

# Install prerequsits
apt-get update
apt-get install -yq git supervisor python python-pip
pip install --upgrade pip virtualenv

# Account to own server process
useradd -m -d /home/pythonapp pythonapp

# get the source code
export HOME=/root
git clone https://github.com/ConorMcFeelyQUB/cloud-advert.git /opt/app

# Python setup
virtualenv -p python3 /opt/app/gce/env
source /opt/app/gce/env/bin/activate
/opt/app/gce/env/bin/pip install -r /opt/app/gce/requirements.txt

# For supervisor set ownership of the new account 
chown -R pythonapp:pythonapp /opt/app

#Put DB ip in envariables 
echo -n ',ADVERTIP='"${GETIP}" >> /opt/app/gce/python-app.conf

# Put supervisor configuration in proper place
cp /opt/app/gce/python-app.conf /etc/supervisor/conf.d/python-app.conf

# Start service 
supervisorctl reread
supervisorctl update