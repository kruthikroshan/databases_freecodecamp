#!/bin/bash

PSQL="psql -X --username=postgres --dbname=salon --tuples-only --no-align --quiet"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

while true; do
  $PSQL -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=""
  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | tr -d '\n')
  fi
  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  echo -e "\nI could not find that service. What would you like today?"
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | tr -d '\n')
if [[ -z "$CUSTOMER_ID" ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_ID=$($PSQL -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id;" | tr -d '\n')
else
  CUSTOMER_NAME=$($PSQL -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;" | tr -d '\n')
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

$PSQL -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" >/dev/null
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."