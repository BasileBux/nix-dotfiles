#!/bin/sh

class=$(playerctl metadata --format '{{lc(status)}}')

text="~"
icon=' '
space=' '

if [[ -n "$class" ]]; then
  active_spotify=$(playerctl metadata --player=spotify --format '{{lc(status)}}')
  if [[ $active_spotify == "playing" ]]; then
    info=$(playerctl metadata --player=spotify --format '{{title}} - {{artist}}')
    text=$info
    class=$active_spotify
  else
    
    title=$(playerctl metadata --format '{{title}}')
    if [[ $title == *"Twitch"* ]]; then
      info=$title
    else
      info=$(playerctl metadata --format '{{artist}} - {{title}}')
    fi

    if [[ ${#info} > 30 ]]; then
      fullTitle=$info
      info=$(echo $info | cut -c1-30)"..."
    fi

    text=$info
    firefox_active=$(playerctl metadata --player=firefox --format '{{lc(status)}}')
    if [[ $firefox_active == "playing" ]]; then
      icon="󰈹 "
    else
      icon=" "
    fi

  fi

  echo -e "{\"text\":\""$icon"${space}"$text"\", \"class\":\""$class"\", \"tooltip\":\""$fullTitle"\"}"
  else
    class="No player currently"
    echo -e "{\"text\":\""$text"\", \"class\":\""$class"\", \"tooltip\":\"\"}"
fi


