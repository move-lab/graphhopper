# Setup for instances to build a graph via docker + graphhopper

echo "Install Docker + Git"
sudo yum update -y
# sudo yum install git docker -y
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

echo "Get move-lab/graphhopper repo"
cd ~
git clone https://github.com/move-lab/graphhopper.git
cd graphhopper

echo "Opening config.yml for possible RAM changes"
sleep 5
vim ./config.yml

echo "Build graphhopper image"
sudo docker build . -t movelab/graphhopper
