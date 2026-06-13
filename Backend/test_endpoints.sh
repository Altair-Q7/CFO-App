#!/bin/bash
# Backend API Endpoint Test Script

BASE="http://localhost:3001/api"

echo "=== Testing Health ==="
curl -s $BASE/health
echo -e "\n"

echo "=== Testing Signup ==="
SIGNUP=$(curl -s -X POST $BASE/auth/signup -H "Content-Type: application/json" -d '{"name":"Test User","email":"test@example.com","password":"password123"}')
echo "$SIGNUP"
TOKEN=$(echo $SIGNUP | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "Token: $TOKEN"
echo -e "\n"

echo "=== Testing Login ==="
LOGIN=$(curl -s -X POST $BASE/auth/login -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"password123"}')
echo "$LOGIN"
if [ -z "$TOKEN" ]; then
  TOKEN=$(echo $LOGIN | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
fi
echo -e "\n"

echo "=== Testing Onboarding ==="
curl -s -X POST $BASE/auth/onboarding -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"companyName":"Acme Corp","industry":"SaaS","monthlyRevenue":80000,"monthlyExpenses":55000,"employees":15}'
echo -e "\n"

echo "=== Testing Dashboard Metrics ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/dashboard/metrics
echo -e "\n"

echo "=== Testing Dashboard Trends ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/dashboard/trends
echo -e "\n"

echo "=== Testing Dashboard Activity ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/dashboard/activity
echo -e "\n"

echo "=== Testing Forecasting ==="
curl -s -X POST $BASE/forecasting/project -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"months":12,"revenueGrowth":5,"expenseGrowth":3,"hiringCost":0}'
echo -e "\n"

echo "=== Testing AI Chat ==="
curl -s -X POST $BASE/ai/chat -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"message":"What is my current runway?"}'
echo -e "\n"

echo "=== Testing AI History ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/ai/history
echo -e "\n"

echo "=== Testing AI Suggestions ==="
curl -s $BASE/ai/suggestions
echo -e "\n"

echo "=== Testing Reports P&L ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/reports/pnl
echo -e "\n"

echo "=== Testing Reports Balance Sheet ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/reports/balance-sheet
echo -e "\n"

echo "=== Testing Reports Cash Flow ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/reports/cash-flow
echo -e "\n"

echo "=== Testing Marketplace Advisors ==="
curl -s $BASE/marketplace/advisors
echo -e "\n"

echo "=== Testing Notifications ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/notifications
echo -e "\n"

echo "=== Testing Profile ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/profile
echo -e "\n"

echo "=== Testing Fundraising Readiness ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/fundraising/readiness
echo -e "\n"

echo "=== Testing Fundraising Data Room ==="
curl -s -H "Authorization: Bearer $TOKEN" $BASE/fundraising/data-room
echo -e "\n"

echo "=== ALL TESTS COMPLETE ==="