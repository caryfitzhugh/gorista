VERSION_LABEL=`git rev-parse --short HEAD`_$(date +%s)

CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo-linux-go-bean -o gorista .

sudo `aws ecr get-login --region us-east-1`
sudo docker build -t gorista:$VERSION_LABEL -f Dockerfile .
sudo docker tag   -f gorista:$VERSION_LABEL 848735772674.dkr.ecr.us-east-1.amazonaws.com/corista:$VERSION_LABEL
sudo docker push  848735772674.dkr.ecr.us-east-1.amazonaws.com/corista:$VERSION_LABEL

ACR_NAME=848735772674.dkr.ecr.us-east-1.amazonaws.com\\/corista:$VERSION_LABEL
cat Dockerrun.aws.json.template | sed s/%%IMAGE_NAME%%/"$ACR_NAME"/g > Dockerrun.aws.json

ZIPFILE=$VERSION_LABEL.zip
echo "Zipping $ZIPFILE"
zip $ZIPFILE Dockerrun.aws.json

echo "Uploading to S3.."
aws s3 cp $ZIPFILE s3://deploys.corista.com/

echo "Cleanup, this should be done with pipes and not files! blah"
rm $ZIPFILE
rm Dockerrun.aws.json

echo ""
echo "Creating the application version $VERSION_LABEL"
echo ""

aws elasticbeanstalk create-application-version \
  --application-name gorista \
  --version-label $VERSION_LABEL \
  --source-bundle S3Bucket=deploys.corista.com,S3Key=$ZIPFILE

echo ""
echo "Updating the environment's running version to $VERSION_LABEL"
echo ""

aws elasticbeanstalk \
  update-environment \
  --environment-name gorista-env \
  --version-label $VERSION_LABEL
