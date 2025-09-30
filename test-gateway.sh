#!/bin/bash

# Family Finance API Gateway Test Script

echo "🚀 Family Finance API Gateway Test"
echo "=================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test functions
test_endpoint() {
    local endpoint=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $description... "
    
    response=$(curl -s -w "%{http_code}" "$endpoint")
    status_code="${response: -3}"
    body="${response%???}"
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓${NC} ($status_code)"
        if [ ! -z "$body" ] && [ ${#body} -lt 200 ]; then
            echo "   Response: $body"
        fi
    else
        echo -e "${RED}✗${NC} ($status_code)"
        echo "   Expected: $expected_status, Got: $status_code"
    fi
    echo
}

test_cors() {
    local endpoint=$1
    echo -n "Testing CORS for $endpoint... "
    
    cors_headers=$(curl -s -I -X OPTIONS -H "Origin: http://localhost:3000" "$endpoint" | grep -i "access-control")
    
    if [ ! -z "$cors_headers" ]; then
        echo -e "${GREEN}✓${NC}"
        echo "$cors_headers" | sed 's/^/   /'
    else
        echo -e "${RED}✗${NC}"
        echo "   No CORS headers found"
    fi
    echo
}

# Base URL
BASE_URL="http://localhost"

echo "Base URL: $BASE_URL"
echo

# Test health endpoint
test_endpoint "$BASE_URL/health" "Health check"

# Test gateway info
test_endpoint "$BASE_URL/" "Gateway info"

# Test API endpoints (these will return 404 with mock services, which is expected)
test_endpoint "$BASE_URL/api/auth/" "Auth service route" 404
test_endpoint "$BASE_URL/api/accounts/" "Account service route" 404
test_endpoint "$BASE_URL/api/transactions/" "Transaction service route" 404

# Test CORS
echo "CORS Tests:"
echo "-----------"
test_cors "$BASE_URL/api/auth/"

# Test rate limiting (commented out as it would require many requests)
# echo "Rate Limiting Test:"
# echo "------------------"
# echo "This would require making many requests to test rate limiting..."

echo "Gateway Status:"
echo "--------------"
docker-compose ps

echo
echo "🎉 Test completed!"
echo
echo "Next steps:"
echo "- Replace mock services with your real services in docker-compose.yml"
echo "- Update upstream server configurations if needed"
echo "- Configure SSL for production"
echo "- Set up monitoring and logging"