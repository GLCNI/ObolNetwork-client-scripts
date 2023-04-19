#!/bin/bash

# Check if .bash_profile exists
if [ ! -f "$HOME/.bash_profile" ]; then
    # If not, check if .profile exists
    if [ -f "$HOME/.profile" ]; then
        # If .profile exists, rename it to .bash_profile
        mv "$HOME/.profile" "$HOME/.bash_profile"
    else
        # If neither file exists, create .bash_profile
        touch "$HOME/.bash_profile"
    fi
fi

# ------------------------------------------------------------------------------------------
# INITIAL SETUP
# ------------------------------------------------------------------------------------------
# setup device and dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install curl git -y

# INSTALL DOCKER 
# Check if Docker is already installed
echo "checking if Docker is installed on the system..."
sleep 5
if command -v docker &> /dev/null
then
    echo "Docker is already installed"
else
    # Install Docker
    echo "installing Docker and Docker Compose..."
    sleep 3
    sudo apt-get remove docker docker-engine docker.io containerd runc
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo rm -r get-docker.sh 
    sudo usermod -aG docker $USER && newgrp docker
    echo "Docker is now installed"
fi

# Check Docker version
docker_version=$(docker --version | awk '{print $3}')
docker_compose_version=$(docker compose version | awk '{print $4}')
echo "You are running Docker version $docker_version and Docker Compose version $docker_compose_version"
sleep 5

# ------------------------------------------------------------------------------------------
# DEFINE PORTS
# ------------------------------------------------------------------------------------------

# Use Default Ports or change them
echo "Do you want to change ports, or use default ports?"
echo "Default ports are: Execution p2p: 30303, Consensus p2p: 9000, Charon: 3610, RPC: 8545"
echo "Enter 1 to change ports, or 2 to use default ports:"
read change_ports
echo
if [ "$change_ports" == "1" ]; then
    echo -n "Use default Execution p2p Port 30303, or enter custom port (1 - default 30303, 2 - enter custom custom port) > "
    read select_el_p2p_port
    echo
    if test "$select_el_p2p_port" == "1"
    then
        EL_P2P_PORT=$"30303"
        echo "export EL_P2P_PORT=$EL_P2P_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    if test "$select_el_p2p_port" == "2"
    then
        read -p "Enter Execution p2p Port: " EL_P2P_PORT
        echo "export EL_P2P_PORT=$EL_P2P_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    # define consensus P2P Port Default 9000
    echo -n "Use default Consensus p2p Port 9000, or enter custom port (1 - default 9000, 2 - enter custom custom port) > "
    read select_cl_p2p_port
    echo
    if test "$select_cl_p2p_port" == "1"
    then
        CL_P2P_PORT=$"9000"
        echo "export CL_P2P_PORT=$CL_P2P_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    if test "$select_cl_p2p_port" == "2"
    then
        read -p "Enter Consensus p2p Port: " CL_P2P_PORT
        echo "export CL_P2P_PORT=$CL_P2P_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    # define charon Port Default 3610
    echo -n "Use default Port 3610, or enter custom port (1 - default 3610, 2 - enter custom custom port) > "
    read select_charon_port
    echo
    if test "$select_charon_port" == "1"
    then
        CHARON_PORT=$"3610"
        echo "export CHARON_PORT=$CHARON_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    if test "$select_charon_port" == "2"
    then
        read -p "Enter Charon Port: " CHARON_PORT
        echo "export CHARON_PORT=$CHARON_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    # define RPC Port Default 8545
    echo -n "Use default Port 8545, or enter custom port (1 - default 8545, 2 - enter custom custom port) > "
    read select_rpc_port
    echo
    if test "$select_rpc_port" == "1"
    then
        RPC_PORT=$"8545"
        echo "export RPC_PORT=$RPC_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
    if test "$select_rpc_port" == "2"
    then
        read -p "Enter rpc Port: " RPC_PORT
        echo "export RPC_PORT=$RPC_PORT" >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
else
    # Set the default values for the variables
    EL_P2P_PORT="30303"
    CL_P2P_PORT="9000"
    CHARON_PORT="3610"
    RPC_PORT="8545"
    echo "export EL_P2P_PORT=$EL_P2P_PORT" >> $HOME/.bash_profile
    echo "export CL_P2P_PORT=$CL_P2P_PORT" >> $HOME/.bash_profile
    echo "export CHARON_PORT=$CHARON_PORT" >> $HOME/.bash_profile
    echo "export RPC_PORT=$RPC_PORT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi

# ------------------------------------------------------------------------------------------
# FIREWALL SETTINGS
# ------------------------------------------------------------------------------------------

source $HOME/.bash_profile
sudo ufw allow $EL_P2P_PORT
sudo ufw allow $CL_P2P_PORT
sudo ufw allow $CHARON_PORT
echo "If running local, you will need to Port Forward Ports: $CHARON_PORT, $EL_P2P_PORT, $CL_P2P_PORT"
sleep 5

# Enable SSH
echo "Do you want to enable SSH? (yes/no):"
read enable_ssh
if [ "$enable_ssh" == "yes" ]; then
    sudo ufw allow ssh
fi

# Expose RPC
echo "Do you want to expose RPC? (yes/no):"
read expose_rpc
if [ "$expose_rpc" == "yes" ]; then
    sudo ufw allow $RPC_PORT
fi

#enable firewall
sudo ufw enable 

# ------------------------------------------------------------------------------------------
# CLONE OBOL AND CLIENT TEMPLATES
# ------------------------------------------------------------------------------------------
#clone Obol repository
git clone https://github.com/ObolNetwork/charon-distributed-validator-node.git

#clone client configuration templates
mkdir $HOME/charon-distributed-validator-node/docker-compose-templates/
cd $HOME/charon-distributed-validator-node/docker-compose-templates/
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/charon 
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/cl-lighthouse
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/cl-nimbus
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/cl-teku
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/el-besu
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/el-erigon
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/el-geth
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/el-nethermind
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/service-templates/vl-teku
cd

# ------------------------------------------------------------------------------------------
# SELECT CLIENTS
# ------------------------------------------------------------------------------------------
#execution client selection
echo -n "Select Execution Layer Client (1 - geth, 2 - nethermind, 3 - besu, 4 -erigon) > "
read select_el_client
echo
if test "$select_el_client" == "1"
then
    EL_CLIENT=$"geth"
    echo "export EL_CLIENT=$EL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi
if test "$select_el_client" == "2"
then
    EL_CLIENT=$"nethermind"
    echo "export EL_CLIENT=$EL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi
if test "$select_el_client" == "3"
then
    EL_CLIENT=$"besu"
    echo "export EL_CLIENT=$EL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi
if test "$select_el_client" == "4"
then
    EL_CLIENT=$"erigon"
    echo "export EL_CLIENT=$EL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi

#consensus client selection
echo -n "Select Consensus Layer Client (1 - lighthouse, 2 - teku, 3 - nimbus) > "
read select_cl_client
echo
if test "$select_cl_client" == "1"
then
    CL_CLIENT=$"lighthouse"
    echo "export CL_CLIENT=$CL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi
if test "$select_cl_client" == "2"
then
    CL_CLIENT=$"teku"
    echo "export CL_CLIENT=$CL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi
if test "$select_cl_client" == "3"
then
    CL_CLIENT=$"nimbus"
    echo "export CL_CLIENT=$CL_CLIENT" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi

# ------------------------------------------------------------------------------------------
# CREATE THE DOCKER COMPOSE SCRIPT
# ------------------------------------------------------------------------------------------
# move default template
cd charon-distributed-validator-node && mkdir backups && mv docker-compose.yml backups
# create docker-compose.yml 
echo 'version: "3.8"' > docker-compose.yml
echo '' >> docker-compose.yml
echo 'services:' >> docker-compose.yml
echo '' >> docker-compose.yml

# Add contents of the selected templates
cat $HOME/charon-distributed-validator-node/docker-compose-templates/el-${EL_CLIENT} >> docker-compose.yml
echo '' >> docker-compose.yml
cat $HOME/charon-distributed-validator-node/docker-compose-templates/cl-${CL_CLIENT} >> docker-compose.yml
echo '' >> docker-compose.yml
cat $HOME/charon-distributed-validator-node/docker-compose-templates/charon >> docker-compose.yml
echo '' >> docker-compose.yml
cat $HOME/charon-distributed-validator-node/docker-compose-templates/vl-teku >> docker-compose.yml
echo '' >> docker-compose.yml

# Add networks section to end
echo 'networks:' >> docker-compose.yml
echo '  dvnode:' >> docker-compose.yml
