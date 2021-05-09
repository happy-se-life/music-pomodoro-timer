#!/bin/bash
#
# Usage:
#   musicPomodoroTimer.sh
#
# Description:
#   This is pomodoro timer made by bash.
#   The feature is that you can keep playing BGM during breaks. This is better than an alarm.
#   Please use it to create a pace for telework.
#
# Requirements:
#   macOS Big Sur
#
# Auther:
#   Twitter: @happy_se_life
#
## You can modify following constants.
#
# Timer in minutes
CONST_CONCENTRATION_TIME=25
CONST_SHORT_BREAK_TIME=5
CONST_LONG_BREAK_TIME=15
#
# Short break cycle
#
CONST_SHORT_BREAK_CYCLE=4
#
# Bckground music for break time.
# It supports music files that can be played with the afplay command.
#
CONST_BREAK_TIME_BGM_FILE="./air.mp3"
#
# Speaking words
#
if [ $LANG = "ja_JP.UTF-8" ] ; then
  # Japanese
  CONST_VOICE_READY_TO_WORK="準備はよろしいですか？作業名を入力してください。"
  CONST_VOICE_START_TO_WORK="作業を初めてください。"
  CONST_VOICE_STOP_TO_WORK="作業を終了してください。お疲れ様でした。"
  CONST_VOICE_TAKE_SHORT_BREAK="少し休憩しましょう。BGMをお届けします。"
  CONST_VOICE_STOP_SHORT_BREAK="休憩の時間が終了しました。"
  CONST_VOICE_TAKE_LONG_BREAK="長めに休憩をしましょう。BGMをお届けします。"
  CONST_VOICE_STOP_LONG_BREAK="休憩の時間が終了しました。"
  CONST_VOICE_NOTICE_NEXT_BREAK="次回は長めの休憩です。"
else
  # English
  CONST_VOICE_READY_TO_WORK="Are you ready? Please enter the task name."
  CONST_VOICE_START_TO_WORK="Start working."
  CONST_VOICE_STOP_TO_WORK="Stop working. Thank you for your hard work."
  CONST_VOICE_TAKE_SHORT_BREAK="Let's take a break. We will deliver BGM."
  CONST_VOICE_STOP_SHORT_BREAK="The break time is over."
  CONST_VOICE_TAKE_LONG_BREAK="Let's take a long break. We will deliver BGM."
  CONST_VOICE_STOP_LONG_BREAK="The break time is over."
  CONST_VOICE_NOTICE_NEXT_BREAK="Next time is a long break."
fi
#
## You cannot modify below. 
#
max_concentration_time=$(($CONST_CONCENTRATION_TIME * 60))
max_short_break_time=$(($CONST_SHORT_BREAK_TIME * 60))
max_long_break_time=$(($CONST_LONG_BREAK_TIME * 60))
concentration_cycle=1
short_break_count=1
log_file=`date "+%Y%m%d.log"`

if [ ! -f ${CONST_BREAK_TIME_BGM_FILE} ] ; then
  echo -en "BGM not found. Exited.\n"
  exit 1
fi

# Log writer
function write_log () {
  echo -en "`date "+%Y/%m/%d %H:%M:%S"` : $1\n" >> ${log_file}
}

# TODO
# trap 'write_log "Stopped by user."' SIGINT

# Play BGM
function play_bgm () {
  bgm=0
  remaining=$1
  while :
  do
    st=`date "+%s"`
    afplay -t $1 "${CONST_BREAK_TIME_BGM_FILE}"
    ed=`date "+%s"`
    bgm=$(($ed - $st))
    remaining=$(($remaining - $bgm))
    if [ $remaining -lt 5 ] ; then
      break
    fi
    if [ $remaining -lt $bgm ] ; then
      afplay -t $remaining "${CONST_BREAK_TIME_BGM_FILE}"
      break
    fi
  done
}

# Main loop
while :
do
  say ${CONST_VOICE_READY_TO_WORK}
  sleep 1
  echo -n "Enter task name: " 
  read task_name
  
  # Start concentration time
  say ${CONST_VOICE_START_TO_WORK}
  write_log "Task name is ${task_name}. Cycle=$concentration_cycle"
  write_log "Concentration was started."
  st=`date "+%s"`
  for((i=0; i<$max_concentration_time; i++))
  do
    progress=$((($i + 1) * 100 / $max_concentration_time))
    echo -en "\r${progress}%"
    sleep 1
  done
  say ${CONST_VOICE_STOP_TO_WORK}
  ed=`date "+%s"`
  duration=$((($ed - $st) / 60))
  write_log "Task name is ${task_name}. Cycle=$concentration_cycle. duration was $duration minutes."
  write_log "Concentration was ended."
  echo -en "\n"
  
  # Start break time
  if [ $short_break_count -lt $CONST_SHORT_BREAK_CYCLE ] ; then
    # Short break time
    say ${CONST_VOICE_TAKE_SHORT_BREAK}
    echo -en "Short break time.\n"
    write_log "Short break was started."
    play_bgm $max_short_break_time
    say ${CONST_VOICE_STOP_SHORT_BREAK}
    write_log "Short break was ended."
    short_break_count=$(($short_break_count + 1))
  else
    # Long break time
    say ${CONST_VOICE_TAKE_LONG_BREAK}
    echo -en "Long break time.\n"
    write_log "Long break was started."
    play_bgm $max_long_break_time
    say ${CONST_VOICE_STOP_LONG_BREAK}
    write_log "Long break was ended."
    short_break_count=0
  fi
  if [ $short_break_count -eq $CONST_SHORT_BREAK_CYCLE ] ; then
    say ${CONST_VOICE_NOTICE_NEXT_BREAK}
  fi
  
  concentration_cycle=$(($concentration_cycle + 1))
done
