#!/bin/bash

#!/bin/bash

zenity --title "Removing the song" --question "Do you really want to delete the song $(mpc | head -n 1)?"
 
#If Yes, then 0 is returned, else 1
reply=$(echo $?)

if [[ reply -eq 0 ]];then
        song_to_remove=$(mpc | head -n 1)
        playlist_pos=$(mpc -f %position% | head -n 1)
        #Delete the song
        rm "$(mpc -f %file% | head -n 1 | sed 's/^/\/home\/shadyabhi\/Music\//')"
        #Remove the song from playlist
        mpc del $playlist_pos
        #Write to log file
        echo "[`date`] -> --$song_to_remove-- is now deleted..." >> ~/.mpdremove.log
fi
