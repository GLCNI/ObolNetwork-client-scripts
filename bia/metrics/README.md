#Getting Metrics working with other clients

##Nethermind

changes to `prometheus.yml` in ./prometheus

`scrape_configs:
  - job_name: "nethermind"
    metrics_path: /metrics
    static_configs:
      - targets: ["nethermind:6060"]`

Add to `docker-compose.yml` for nethermind service 

    `ports:
      - 30309:30309/tcp # P2P TCP
      - 30309:30309/udp # P2P UDP
      - 6060:6060 # metrics
    command: |
      --Metrics.Enabled=true
      --Metrics.ExposePort=6060
      --Metrics.IntervalSeconds=10
      --Metrics.NodeName="Nethermind"`

