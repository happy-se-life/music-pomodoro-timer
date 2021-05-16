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
#   GitHub: @happy-se-life
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
log_file=`date "+%Y%m%d_log.md"`
task_name=""
duration=0

if [ ! -f ${CONST_BREAK_TIME_BGM_FILE} ] ; then
  echo -en "BGM not found. Exited.\n"
  exit 1
fi

# Log writer as markdown
function write_log () {
  if [ -z "${task_name}" ] ; then
    # Termination while break time.
    return
  fi
  if [ ! -f $log_file ] ; then
    # Header
    echo -en "| Date time           | Task name                                | Duration |\n" > ${log_file}
    echo -en "|:--------------------|:-----------------------------------------|---------:|\n" >> ${log_file}
    #           2021/05/16 20:35:16 | 1234567890123456789012345678901234567890       3600
  fi
  # Body
  printf "| %-19s | %-40s | %8d |\n" "`date "+%Y/%m/%d %H:%M:%S"`" "`echo ${task_name} | cut -c 1-40`" $duration >> ${log_file}
}

# TODO
trap "write_log; clear; cat ${log_file}; echo -en \"Stopped by user.\n\"; exit" SIGINT

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
  concentration_time=0
  for((i=0; i<$max_concentration_time; i++))
  do
    progress=$((($i + 1) * 100 / $max_concentration_time))
    echo -en "\r${progress}%"
    sleep 1
    concentration_time=$(($concentration_time + 1))
    duration=$(($concentration_time / 60))
  done
  say ${CONST_VOICE_STOP_TO_WORK}
  write_log

  # Init.
  task_name=""
  duration=0
  echo -en "\n"
  
  # Break time
  if [ $short_break_count -lt $CONST_SHORT_BREAK_CYCLE ] ; then
    # Short break
    say ${CONST_VOICE_TAKE_SHORT_BREAK}
    echo -en "Short break.\n"
    play_bgm $max_short_break_time
    say ${CONST_VOICE_STOP_SHORT_BREAK}
    short_break_count=$(($short_break_count + 1))
  else
    # Long break
    say ${CONST_VOICE_TAKE_LONG_BREAK}
    echo -en "Long break.\n"
    play_bgm $max_long_break_time
    say ${CONST_VOICE_STOP_LONG_BREAK}
    short_break_count=0
  fi
  if [ $short_break_count -eq $CONST_SHORT_BREAK_CYCLE ] ; then
    say ${CONST_VOICE_NOTICE_NEXT_BREAK}
  fi
  
  concentration_cycle=$(($concentration_cycle + 1))
done
