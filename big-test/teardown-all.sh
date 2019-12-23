
set -x

ADVERT_DB_INSTANCE_NAME="advert-db-instance-a"
PAGE_DB_INSTANCE_NAME="page-db-instance-a"
SQL_SETUP_INSTANCE_NAME="sql-setup-vm-instance"
REGION="europe-west2"
ZONE="europe-west2-a"
STATIC_IP_SQL_SETUP_INSTANCE="static-sql-setup"

STATIC_IP_ADVERT_INSTANCE="static-advert"
STATIC_IP_SEARCH_INSTANCE="static-search"
STATIC_IP_INDEXER_INSTANCE="static-indexer"

ADVERT_VM_INSTANCE_NAME="advert-vm-instance"
SEARCH_VM_INSTANCE_NAME="search-vm-instance"
INDEXER_VM_INSTANCE_NAME="indexer-vm-instance"

#delete advert sql instance
gcloud --quiet sql instances delete $ADVERT_DB_INSTANCE_NAME

#delete page sql instance
gcloud --quiet sql instances delete $PAGE_DB_INSTANCE_NAME

#delete sql vm instance
gcloud --quiet compute instances delete $SQL_SETUP_INSTANCE_NAME \
    --zone=$ZONE --delete-disks=all

#delete static ip for vm instnace
gcloud --quiet compute addresses delete $STATIC_IP_SQL_SETUP_INSTANCE \
    --region $REGION

#delete advert vm instance
gcloud --quiet compute instances delete $ADVERT_VM_INSTANCE_NAME \
    --zone=$ZONE --delete-disks=all

#delete search vm instance
gcloud --quiet compute instances delete $SEARCH_VM_INSTANCE_NAME \
    --zone=$ZONE --delete-disks=all

#delete indexer vm instance
gcloud --quiet compute instances delete $INDEXER_VM_INSTANCE_NAME \
    --zone=$ZONE --delete-disks=all


#delete static ip for advert vm instnace
gcloud --quiet compute addresses delete $STATIC_IP_ADVERT_INSTANCE \
    --region $REGION

#delete static ip for search vm instnace
gcloud --quiet compute addresses delete $STATIC_IP_SEARCH_INSTANCE \
    --region $REGION

#delete static ip for indexer vm instnace
gcloud --quiet compute addresses delete $STATIC_IP_INDEXER_INSTANCE \
    --region $REGION