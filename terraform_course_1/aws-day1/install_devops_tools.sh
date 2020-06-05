#! /bin/bash
# Install the latest os updates
## Add this into userdata.
sudo useradd -m -d /home/ec2-user -s /bin/bash -c "ec2-user Owner" -U ec2-user; (echo redhat; echo redhat) | sudo passwd ec2-user
echo 'ec2-user   ALL=(ALL)       NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config

yum update -y
yum install -y wget vim
sudo yum install -y epel-release
# Install java-1.8-openjdk
yum install -y java-1.8.0-openjdk
# Update the java path into environment.bash_profile
cat <<EOF >>/root/.bash_profile
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/bin
EOF

#install the Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
#Download Nexus
cd /opt
sudo wget https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.16.1-02-unix.tar.gz
tar -zxvf nexus-3.16.1-02-unix.tar.gz
mv /opt/nexus-3.16.1-02 /opt/nexus

#Create nexus user
sudo useradd nexus; (echo redhat; echo redhat) | sudo passwd nexus

#update to nexus user into sude
echo 'nexus   ALL=(ALL)       NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo

#Change file and owner permission for nexus files
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

#Add nexus as a service at boot time
cat <<EOF >>/opt/nexus/bin/nexus.rc
run_as_user="nexus"
EOF

#Add nexus as a service at boot time
sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus

#Log in as a nexus user and start service
#su - nexus
#/etc/init.d/nexus start

# Install and setup maven build Server.
sudo yum install -y maven

# Install tomcat Server
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
cd /tmp
curl -O http://apache.mirrors.ionfish.org/tomcat/tomcat-9/v9.0.30/bin/apache-tomcat-9.0.30.tar.gz
sudo tar xzvf apache-tomcat-9.0.30.tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/
#tomcat service files
cat <<EOF >>/etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#Install SonarQube on Centos 7.x  and configure Mysql
sudo yum install wget unzip -y
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
#enable db
sudo yum install mysql-server
sudo systemctl start mysqld

# Create db and user for Sonarqube
mysql -u root
CREATE DATABASE sonarqube_db;
CREATE USER 'sonarqube_user'@'localhost' IDENTIFIED BY 'redhat';
GRANT ALL PRIVILEGES ON sonarqube_db.* TO 'sonarqube_user'@'localhost' IDENTIFIED BY 'redhat';
FLUSH PRIVILEGES;
exit

#Download and install SonarQube:
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip
unzip sonarqube-6.7.6.zip
mv sonarqube-6.7.6 /opt/sonarqube

# Create a user for SonarQube:
(echo redhat; echo redhat) | sudo passwd sonarqube
# Change the owenership and Group.
chown -R sonarqube:sonarqube /opt/sonarqube
cat <<EOF >>/opt/sonarqube/bin/linux-x86-64/sonar.sh
RUN_AS_USER=sonarqube
EOF

# Configure sonarqube with MySQL database:
cat <<EOF >>/opt/sonarqube/conf/sonar.properties

sonar.jdbc.username=sonarqube_user
sonar.jdbc.password=password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube_db?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance
EOF

# Start SonarQube
/opt/sonarqube/bin/linux-x86-64/sonar.sh start

# Configuring sonarqube as a Systemd service:
sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh stop

cat <<EOF >>/etc/systemd/system/sonar.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
Restart=always

[Install]
WantedBy=multi-user.target
EOF
# Restart the sonar service with systemd:
sudo systemctl restart sonar
sudo systemctl start sonar
sudo systemctl enable sonar

#Set a password for the newly created user for SonarQube database.
sudo -u sonar psql -U sonar -d sonar -c "alter user sonar with password 'P@ssword';"

#Create a new database for PostgreSQL database by running:
#CREATE DATABASE sonar OWNER sonar;
sudo -u sonar createdb sonar

#Download and configure SonarQube
#wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.3.zip
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.0.zip
sudo yum -y install unzip
#Unzip the archive using the following command.
sudo unzip sonarqube-8.0.zip -d /opt
sudo mv /opt/sonarqube-8.0 /opt/sonarqube
sudo useradd administrator; (echo redhat; echo redhat) | sudo passwd administrator

#Assign permissions to administrator user for directory /opt/sonarqube
sudo chown -R administrator:administrator /opt/sonarqube/

#Add SonarQube configuration file
cat <<EOF >>/opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=P@ssword
sonar.jdbc.url=jdbc:postgresql://localhost/sonar
sonar.web.javaAdditionalOpts=-server
EOF

#Configure Systemd service

cat <<EOF >>/etc/systemd/system/sonar.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF
