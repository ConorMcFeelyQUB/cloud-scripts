apt-get update
apt-get install -yq git mysql-client

git clone https://github.com/ConorMcFeelyQUB/cloud-sql-setup.git

cd cloud-sql-setup/

#mysql --host=35.187.184.139 --user=root --password=QUBccProject -e \
#"source ./createandpop.sql"

GETIPADVERT="$(gcloud sql instances describe advert-db-instance --format='get(ipAddresses[0].ipAddress)')"

GETIPPAGE="$(gcloud sql instances describe page-db-instance --format='get(ipAddresses[0].ipAddress)')"

mysql --host="${GETIPPAGE}" --user=root --password=QUBccProject -e \
"source ./createandpoppage.sql" \

mysql --host="${GETIPADVERT}" --user=root --password=QUBccProject -e \
"source ./createandpopadvert.sql" \