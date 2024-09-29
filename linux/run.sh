#
# Visualenv Linux demo
#
# EE Sep '24

#
# Octomim server settings
#
source .env

#
# Get shell env variables
#
ENV=$(printenv)


#
# Create Stego Image
#
requestJson="{\"text\":\"$ENV\"}"
start=$(date +%s%N)  # Start time in nanoseconds
response=$(curl -s -H "Content-Type: application/json" -u "$username:$password" -d "$requestJson" -k "$baseUrl"/stego/create/text  )
echo $response
filename=$(echo "$response" | jq -r '.file')
responseTime=$((($end - $start) / 1000000))  # Convert nanoseconds to milliseconds
echo "Response Time: $responseTime ms"
if [[ $response == *error* ]]; then
  echo "Error in embedding."
  exit
fi

#
# Download stego image   
#
echo "Getting stego image..."
response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"file\":\"$filename\"}" -u "$username:$password" -k "$baseDataUrl"/data/stego -o "$filename"  )


# 
# Get hidden data from stego image
#
start=$(date +%s%N)  # Start time in nanoseconds
response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"file\":\"$filename\"}" -u "$username:$password" -k "$baseUrl"/stego/extract/text  )
#echo curl -s -X POST -H "Content-Type: application/json" -d "{\"file\":\"$filename\"}" -u "$username:$password" -k "$baseUrl"/stego/extract/token  
end=$(date +%s%N)  # End time in nanoseconds
echo $response
responseTime=$((($end - $start) / 1000000))  # Convert nanoseconds to milliseconds
echo "Response Time: $responseTime ms"

