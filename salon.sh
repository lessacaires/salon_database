#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  # option message
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  # show services list BEFORE first prompt
  echo -e "Welcome to My Salon, how can I help you?"
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
    do
      # SERVICE_ID comes with leading spaces because of --tuples-only
      SERVICE_ID_FORMATTED=$(echo $SERVICE_ID | xargs)
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | xargs)
      echo "${SERVICE_ID_FORMATTED}) ${SERVICE_NAME_FORMATTED}"
    done

    read  SERVICE_ID_SELECTED

    # validate service exists
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | xargs)

    if [[ -z  $SERVICE_NAME_FORMATTED ]]
      then
      MAIN_MENU "I could not find that service. What would you like today?"
      return
    fi

    # get customer phone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | xargs)

    # if not found as name an insert
    if [[ -z $CUSTOMER_ID_FORMATTED ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        $PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone =  '$CUSTOMER_PHONE'")
        CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | xargs)
    else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID'")
        CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)      
    fi

    # get time
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # insert appointments
    $PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES ('$SERVICE_TIME', '$SERVICE_ID_SELECTED', '$CUSTOMER_ID_FORMATTED')"

    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU