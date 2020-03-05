# Setup for instances to build a graph via docker + graphhopper

echo "SETUP SCRIPT FOR THE GRAPHBUILDER boii"
echo "Don't run with 'sudo'"
sleep 7

echo "Update packages"
sudo yum update -y

echo "Install Git"
sudo yum install git -y

echo "Install Docker"
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "Install OpenJDK 8 JRE"
sudo yum install java-1.8.0-openjdk -y

echo "Install Osmosis"
cd ~
wget https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
mkdir osmosis
mv osmosis-latest.tgz osmosis
cd osmosis
tar xvfz osmosis-latest.tgz
rm osmosis-latest.tgz
chmod a+x bin/osmosis
bin/osmosis

echo "Osmosis available via ~/osmosis/bin/osmosis"

echo "Create pbf directory"
cd ~
mkdir pbf

echo "Get move-lab/graphhopper repo"
cd ~
git clone https://github.com/move-lab/graphhopper.git

echo "Usage:"
echo "---"
echo "---"
echo "Edit Dockerfile for possible RAM adjustments ('Xmx' and 'Xms' values. Eg. Xmx32G = 32gb RAM)"
echo "---"
echo "Build docker image:"
echo "cd ~/graphhopper && docker build . -t movelab/graphhopper"
echo "---"
echo "Download pbf file into pbf folder:"
echo "cd ~/pbf && wget https://lab-graphhopper-graphdata-prod.s3-eu-west-1.amazonaws.com/england_denmark_germany_merged.pbf"
echo "---"
echo "Build graph with docker image:"
echo "docker run -d -p 8999:8989 -v /home/ec2-user/pbf:/data movelab/graphhopper:latest -i /data/england_denmark_germany_merged.pbf"
