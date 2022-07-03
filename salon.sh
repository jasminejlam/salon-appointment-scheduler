#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ SALON APPOINTMENT SCHEDULER ~~\n"

SET_APPOINTMENT() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nSalon Services Menu:" 

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
  do
    echo "$SERVICE_ID) $NAME"
  done

  # get service_id
  read SERVICE_ID_SELECTED

  # if service doesn't exist
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SET_APPOINTMENT "Please choose a valid option."
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID ]]
    then
      SET_APPOINTMENT "We don't have that service."
    else
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if no record found
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi

      # get service_time
      echo -e "\nWhen would you like your appointment to be?"
      read SERVICE_TIME

      # set appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SET_APPOINTMENT