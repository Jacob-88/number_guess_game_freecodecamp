#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#game tested +
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME' ")
#username logic
if [[ -z $USER_ID ]]
then 
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULTS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username ='$USERNAME'")  
else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = '$USER_ID'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
GUESS_COUNT=0
echo "Guess the secret number between 1 and 1000:"
#game logic
while true 
do
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then 
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    GUESS_COUNT=$((GUESS_COUNT + 1))
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
  GUESS_COUNT=$((GUESS_COUNT + 1))
done
#update results
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")
#commit for refatoring
if [[ -z $BEST_GAME ]] || [[ $GUESS_COUNT -lt $BEST_GAME ]]
then 
  UPDATE_RESULTS=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE user_id = $USER_ID")
fi
