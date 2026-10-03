#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only --quiet"

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"

show_services() {
  $PSQL -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
}

while true; do
  show_services
  read SERVICE_ID_SELECTED

  SERVICE_NAME=
  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$(printf '%s\n' "SELECT name FROM services WHERE service_id = :'service_id';" | $PSQL -v service_id="$SERVICE_ID_SELECTED")
  fi
  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  echo
  echo "I could not find that service. What would you like today?"
done

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$(printf '%s\n' "SELECT customer_id FROM customers WHERE phone = :'phone';" | $PSQL -v phone="$CUSTOMER_PHONE")

if [[ -z "$CUSTOMER_ID" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  printf '%s\n' "INSERT INTO customers(phone, name) VALUES(:'phone', :'name');" | $PSQL -v phone="$CUSTOMER_PHONE" -v name="$CUSTOMER_NAME" > /dev/null
  CUSTOMER_ID=$(printf '%s\n' "SELECT customer_id FROM customers WHERE phone = :'phone';" | $PSQL -v phone="$CUSTOMER_PHONE")
else
  CUSTOMER_NAME=$(printf '%s\n' "SELECT name FROM customers WHERE customer_id = :'customer_id';" | $PSQL -v customer_id="$CUSTOMER_ID")
fi

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

printf '%s\n' "INSERT INTO appointments(service_id, customer_id, time) VALUES(:'service_id', :'customer_id', :'service_time');" | $PSQL -v service_id="$SERVICE_ID_SELECTED" -v customer_id="$CUSTOMER_ID" -v service_time="$SERVICE_TIME" > /dev/null

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
