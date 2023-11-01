#!/bin/bash

# Function to generate a random transaction ID
generate_transaction_id() {
  echo "$(date +%Y%m%d%H%M%S)-$(shuf -i 1000-9999 -n 1)"
}

# Function to process payment
process_payment() {
  local transaction_id="$1"
  local total_price="$2"
  echo "Select a payment method:"
  echo "1. bKash"
  echo "2. Nagad"
  read payment_method

  case $payment_method in
    1)
      echo "Please make the payment using bKash to phone number 01567953069."  
      ;;

    2)
      echo "Please make the payment using Nagad to phone number 01734495478." 
      ;;

    *)
      echo "Invalid payment method. Please choose a valid option."
      process_payment "$transaction_id" "$total_price"  # Retry payment
      ;;
  esac

  # Ask for payment transaction ID (Assuming manual verification)
  echo "Enter the payment transaction ID (manual verification):"
  read entered_transaction_id

  # Check if the entered transaction ID is valid
  if is_valid_transaction_id "$entered_transaction_id"; then
    echo "Payment received with transaction ID: $transaction_id"
    echo "Your Total Bill is: $total_price tk"
    echo "Your delivery is on the way. It will take about 5 minutes."
    for ((i=1; i<=5; i++)); do
      sleep 60
      echo "Please wait... $((5 - i)) minutes remaining."
    done
    echo "Your order has been delivered. Enjoy your meal!"
  else
    echo "Transaction failed. The entered transaction ID does not match."
  fi
}

# Function to save transaction details to a log file
save_transaction_details() {
  local transaction_id="$1"
  local order="$2"
  echo "$transaction_id: $order" >> transaction_log.txt
}

# Function to check if a transaction ID exists in the text file
is_valid_transaction_id() {
  local id="$1"
  if grep -q "$id" transaction_log.txt; then
    return 0  # Found
  else
    return 1  # Not found
  fi
}

# Function to recommend items based on the current time
recommend_items() {
  local current_hour=$(date +%H)
  if [ $current_hour -ge 6 ] && [ $current_hour -lt 12 ]; then
    # Breakfast time
    echo "Recommendation: Breakfast Menu"
    echo "1. Paratha per piece (10 taka)"
    echo "2. Egg Fry (20 taka)"
    echo "3. Tea 1 cup (10 taka)"
    echo "4. Khichuri (40 taka)"
  elif [ $current_hour -ge 12 ] && [ $current_hour -lt 18 ]; then
    # Lunch time
    echo "Recommendation: Lunch Menu"
    echo "1. Rice (20 taka)"
    echo "2. Fried Rice (60 taka)"
    echo "3. Chicken (50 taka)"
    echo "4. Daal (10 taka)"
  else
    # Regular menu
    echo "Regular Menu"
    echo "1. Paratha per piece (10 taka)"
    echo "2. Egg Fry (20 taka)"
    echo "3. Tea 1 cup (10 taka)"
    echo "4. Khichuri (40 taka)"
    echo "5. Rice (20 taka)"
    echo "6. Fried Rice (60 taka)"
    echo "7. Chicken (50 taka)"
    echo "8. Daal (10 taka)"
  fi
}

# Generate a new transaction ID and save it
transaction_id=$(generate_transaction_id)

echo "Welcome to ___Wake N' Bake___"
recommend_items

cart=()  # Initialize the cart

while true; do
  echo "Add items to your cart or enter 'done' to proceed to payment."
  read choice

  if [ "$choice" == "done" ]; then
    break
  elif [ $choice -ge 1 ] && [ $choice -le 8 ]; then
    item_name=""
    case $choice in
      1)
        item_name="Paratha per piece"
        price=10
        ;;

      2)
        item_name="Egg Fry"
        price=20
        ;;

      3)
        item_name="Tea 1 cup"
        price=10
        ;;

      4)
        item_name="Khichuri"
        price=40
        ;;

      5)
        item_name="Rice"
        price=20
        ;;

      6)
        item_name="Fried Rice"
        price=60
        ;;

      7)
        item_name="Chicken"
        price=50
        ;;

      8)
        item_name="Daal"
        price=10
        ;;

      *)
        echo "Invalid choice. Please choose a valid option."
        continue
        ;;
    esac

    echo "How many $item_name do you want to add to your cart?"
    read item_quantity
    item_total_price=$((item_quantity * price))
    cart+=("$item_name x $item_quantity ($item_total_price tk)")
    echo "$item_name x $item_quantity added to cart."
  else
    echo "Invalid choice. Please choose a valid option."
  fi
done

if [ ${#cart[@]} -eq 0 ]; then
  echo "Your cart is empty. Goodbye!"
  exit
fi

# Display the items in the cart
echo "Items in Your Cart:"
for item in "${cart[@]}"; do
  echo "$item"
done

# Calculate the total price
total_price=0
for item in "${cart[@]}"; do
  item_price=$(echo "$item" | grep -o -P '\d+(?=\s*tk)')
  total_price=$((total_price + item_price))
done

# Display the order total
echo "Your Total Bill is: $total_price tk"
echo "Please pay the bill and wait for collecting the food!"
save_transaction_details "$transaction_id" "Cart: ${cart[*]} (Total: $total_price tk)"  # Save the cart as an order

# Process payment
process_payment "$transaction_id" "$total_price"

