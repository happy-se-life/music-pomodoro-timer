# music-pomodoro-timer
This is pomodoro timer made by only bash for macOS.

## Features
* You can keep playing BGM during breaks. This is better than an alarm only.
* Audio guide.
* Task logging.

## Requirements:
* macOS Big Sur

## Install

1. Create install folder and change directory to that.

2. Clone the code.
<pre>
git clone https://github.com/happy-se-life/music-pomodoro-timer.git
</pre>

3. Grant execute permission.
<pre>
chmod +x ./music-pomodoro-timer.sh
</pre>

4. Set BGM file
<pre>
vim music-pomodoro-timer.sh
</pre>
Edit CONST_BREAK_TIME_BGM_FILE="/pathto/xxxx.mp3".

5. Run it.
<pre>
./music-pomodoro-timer.sh
</pre>

## License
* MIT Lisense
