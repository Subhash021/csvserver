#!/bin/bash

# Pull Docker images
echo "Pulling required Docker images..."
docker pull infracloudio/csvserver:latest
docker pull prom/prometheus:v2.45.2

# Generate inputFile using gencsv.sh
echo "Generating inputFile..."
cat <<'EOF' > gencsv.sh
#!/bin/bash
start=$1
end=$2
if [ -z "$start" ] || [ -z "$end" ]; then
    echo "Usage: $0 <start_index> <end_index>"
    exit 1
fi

for ((i=start; i<=end; i++)); do
    echo "$i, $((RANDOM % 1000))"
done > inputFile
EOF

chmod +x gencsv.sh
./gencsv.sh 2 8

# Run the csvserver container with inputFile
echo "Running csvserver container..."
docker run -d --name csvserver -v $(pwd)/inputFile:/csvserver/inputFile infracloudio/csvserver:latest

# Verify container status
echo "Checking container status..."
docker ps -a
docker logs $(docker ps -q -f name=csvserver)

# Run container with environment variables
echo "Running csvserver container with environment variables..."
docker run -d --name csvserver \
    -p 9393:9300 \
    -e CSVSERVER_BORDER=Orange \
    -v $(pwd)/inputFile:/csvserver/inputFile \
    infracloudio/csvserver:latest

# Save required files
echo "Saving required files..."
echo "docker run -d --name csvserver -p 9393:9300 -e CSVSERVER_BORDER=Orange -v $(pwd)/inputFile:/csvserver/inputFile infracloudio/csvserver:latest" > part-1-cmd

curl -o part-1-output http://localhost:9393/raw
docker logs $(docker ps -q -f name=csvserver) >& part-1-logs

echo "All operations completed successfully."

