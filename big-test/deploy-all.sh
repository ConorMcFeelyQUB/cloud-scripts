set -ex

ADVERT_DB_INSTANCE_NAME="advert-db-instance-b"
PAGE_DB_INSTANCE_NAME="page-db-instance-b"
DB_PASSWORD="QUBccProject"
DB_TEIR="db-n1-standard-2"
REGION="europe-west2"
ZONE="europe-west2-a"

#creating sql instance for advert db
gcloud sql instances create $ADVERT_DB_INSTANCE_NAME \
    --tier="db-n1-standard-2" \
    --region="europe-west2" 

#set the rootpassword for the new sql instance
gcloud sql users set-password root --host=% --instance $ADVERT_DB_INSTANCE_NAME --password $DB_PASSWORD


# \
#     --availability-type= regional
#creating sql instance for page db
gcloud sql instances create $PAGE_DB_INSTANCE_NAME \
    --tier="db-n1-standard-2" \
    --region="europe-west2"

#set the rootpassword for the new sql instance
gcloud sql users set-password root --host=% --instance $PAGE_DB_INSTANCE_NAME --password $DB_PASSWORD

#enable sqladmin service
gcloud services enable sqladmin.googleapis.com

#allow http traffic
# gcloud compute firewall-rules create default-allow-http-8080 \
#     --allow tcp:8080 \
#     --source-ranges 0.0.0.0/0 \
#     --target-tags http-server \
#     --description "Allow port 8080 access to http-server"


############################################################
#Creating db tables and putting initial data

STATIC_IP_SQL_SETUP_INSTANCE="static-sql-setup"

#Creating a static IP for the sqlsetup vm
gcloud compute addresses create $STATIC_IP_SQL_SETUP_INSTANCE \
    --region $REGION \

#Storing the newly created static ip 
STATIC_IP_SQL_SETUP="$(gcloud compute addresses describe $STATIC_IP_SQL_SETUP_INSTANCE --region $REGION --format='get(address)')"


#Add setup IP to authorised list for advert sql instance
gcloud --quiet sql instances patch $ADVERT_DB_INSTANCE_NAME --authorized-networks="${STATIC_IP_SQL_SETUP}",

#Add setup IP to authorised list for page sql instance
gcloud --quiet sql instances patch $PAGE_DB_INSTANCE_NAME --authorized-networks="${STATIC_IP_SQL_SETUP}",

#create vm instance to run mysql commands

SQL_SETUP_INSTANCE_NAME="sql-setup-vm-instance"

gcloud compute instances create $SQL_SETUP_INSTANCE_NAME \
    --image-family=debian-9 \
    --image-project=debian-cloud \
    --machine-type=g1-small \
    --scopes userinfo-email,cloud-platform \
    --metadata-from-file startup-script=startup-script-sql-setup.sh \
    --zone $ZONE \
    --tags http-server \
    --address ${STATIC_IP_SQL_SETUP}


#################################
#Creating static ips for 3 VM instances and store ips
STATIC_IP_ADVERT_INSTANCE="static-advert"
STATIC_IP_SEARCH_INSTANCE="static-search"
STATIC_IP_INDEXER_INSTANCE="static-indexer"

#advert
gcloud compute addresses create $STATIC_IP_ADVERT_INSTANCE \
    --region $REGION \

STATIC_IP_ADVERT="$(gcloud compute addresses describe $STATIC_IP_ADVERT_INSTANCE --region $REGION --format='get(address)')"

#search
gcloud compute addresses create $STATIC_IP_SEARCH_INSTANCE \
    --region $REGION \

STATIC_IP_SEARCH="$(gcloud compute addresses describe $STATIC_IP_SEARCH_INSTANCE --region $REGION --format='get(address)')"

#indexer
gcloud compute addresses create $STATIC_IP_INDEXER_INSTANCE \
    --region $REGION \

STATIC_IP_INDEXER="$(gcloud compute addresses describe $STATIC_IP_INDEXER_INSTANCE --region $REGION --format='get(address)')"


#authorise advert and search for the advert sql instance
gcloud --quiet sql instances patch $ADVERT_DB_INSTANCE_NAME --authorized-networks="${STATIC_IP_SQL_SETUP}","${STATIC_IP_ADVERT}","${STATIC_IP_SEARCH}",


#authorise indexer and search for the page sql instance
gcloud --quiet sql instances patch $PAGE_DB_INSTANCE_NAME --authorized-networks="${STATIC_IP_SQL_SETUP}","${STATIC_IP_INDEXER}","${STATIC_IP_SEARCH}",

#Now create the 3 VM instances giving the static ips

ADVERT_VM_INSTANCE_NAME="advert-vm-instance"
SEARCH_VM_INSTANCE_NAME="search-vm-instance"
INDEXER_VM_INSTANCE_NAME="indexer-vm-instance"


#advert
gcloud compute instances create $ADVERT_VM_INSTANCE_NAME \
    --image-family=debian-9 \
    --image-project=debian-cloud \
    --machine-type=g1-small \
    --scopes userinfo-email,cloud-platform \
    --metadata-from-file startup-script=startup-script-advert.sh \
    --zone $ZONE \
    --tags http-server \
    --address ${STATIC_IP_ADVERT}

#search
gcloud compute instances create $SEARCH_VM_INSTANCE_NAME \
    --image-family=debian-9 \
    --image-project=debian-cloud \
    --machine-type=g1-small \
    --scopes userinfo-email,cloud-platform \
    --metadata-from-file startup-script=startup-script-search.sh \
    --zone $ZONE \
    --tags http-server \
    --address ${STATIC_IP_SEARCH}

#indexer
gcloud compute instances create $INDEXER_VM_INSTANCE_NAME \
    --image-family=debian-9 \
    --image-project=debian-cloud \
    --machine-type=g1-small \
    --scopes userinfo-email,cloud-platform \
    --metadata-from-file startup-script=startup-script-indexer.sh \
    --zone $ZONE \
    --tags http-server \
    --address ${STATIC_IP_INDEXER}


#FIN
