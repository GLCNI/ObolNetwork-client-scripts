# ObolNetwork-client-scripts
docker-compose script templates for alternative clients

![Obol Ar LINE - hi res- GIT](https://user-images.githubusercontent.com/67609618/218346108-006aebc0-c0b0-4eac-8c8c-6f84f6cd7d74.jpg)

Repository for docker compose configurations, for alternative clients for Obol Network Charon, with Charon https://github.com/ObolNetwork/charon 
default execution client is GETH and default consensus client is lighthouse with Teku configured for the validator client. 

**Obol Network:** Obol Network is distributed validator technology stack, charon is a middleware client to coordinate a validator consisting of multiple node operators.  https://obol.tech/ 

**How to run a Distributed Validator cluster:** will be maintaining this throughout the Testnet https://mirror.xyz/0xf3bF9DDbA413825E5DdF92D15b09C2AbD8d190dd/Hw5uYDd24ena2vziyTZ39priB4XBONBwWqnwOB8DEh0

*Bia is the current Testnet iteration, which is on Goerli Ethereum, I will be adding configurations for the following clients as the testnet progresses, will update with upcoming Testnets after BIA*

*NOTE: this is a work in progress and not recommended for production deployments, Obol is in testnet* 

## How to Use (configure manually)

In the `docker-compose.yml` file, replace under `services` with the client template of choice from `/bia`

```
version: "3.8"

# Override any defaults specified by `${FOO:-bar}` in `.env` with `FOO=qux`.
# ${VARIABLE:-default} evaluates to default if VARIABLE is unset or empty in the environment.
# ${VARIABLE-default} evaluates to default only if VARIABLE is unset in the environment.

services:
  <INSERT SERVICE HERE FOR EXECUTION> (default is 'geth' )

  <INSERT SERVICE HERE FOR CONSENSUS> (default is 'lighthouse' )
  ...

  ...


networks:
  dvnode:
```

# Obol setup tool
this is a setup tool to deploy a charon distributed validator node with client selection and auto configuration based on selection.

## How to use Obol setup tool.  


download script to `$HOME` directory 
```
wget https://raw.githubusercontent.com/GLCNI/ObolNetwork-client-scripts/main/deployment-script/obol-deployment.sh && chmod a+x obol-deployment.sh
```

run script 
```
./obol-deployment.sh
```

### what it does
- updates system and checks dependancies 
- installs git and docker if needed
- clones obol charon (LINK) repository 
- download client configuration templates for docker compose
- configure ports and client selection 
- create docker-compose.yml for charon distributed validator node with selected clients

### features pending 
- add ENR creation 
- add validator client templates 
- add monitoring changes, with metrics 
