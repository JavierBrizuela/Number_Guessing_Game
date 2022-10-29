#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
GUESS_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo Enter your username:
read USERNAME

READ_GUESS_NUMBER() {
  read USER_GUESS
  if [[ ! $USER_GUESS =~ ^[0-9]*$ ]]
  then
    echo That is not an integer, guess again:
    READ_GUESS_NUMBER
  fi
}
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(number_guess) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
USER_NAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_NAME ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USERNAME_INSERT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  else
  echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo Guess the secret number between 1 and 1000:
READ_GUESS_NUMBER
COUNT=1
echo $GUESS_NUMBER
while (( $USER_GUESS != $GUESS_NUMBER ))
do
if (( $USER_GUESS < $GUESS_NUMBER ))
then
echo "It's higher than that, guess again:"
else
echo "It's lower than that, guess again:"
fi
READ_GUESS_NUMBER
COUNT=$(( $COUNT + 1 ))
done

GAME_RESULT=$($PSQL "INSERT INTO  games(user_id, number_guess) VALUES ($USER_ID, $COUNT)")
echo -e "\nYou guessed it in $COUNT tries. The secret number was $GUESS_NUMBER. Nice job!"