#!/bin/sh

#OTHURL="https://www.origin.com/en-de/store/free-games/on-the-house"
OTHURL="https://www.origin.com/deu/en-us/store/free-games/on-the-house"
OTHFILE="/tmp/oth"
OTHFILEOLD="${OTHFILE}-old"
#SEDEXPRESSION="s:.*<h5><a.*>\(.*\)</a></h5>.*:\1:g"
SEDEXPRESSION="s:.*<a class=\"origin-store-program-offer-title\".*>\(.*\)</a>.*:\1:g"
MAILTEXTEND="Go to https://www.origin.com/en-de/store/free-games/on-the-house if you are interested."
MAILTO="someone@example.org"
#MAILTO="someone@example.org,someoneelse@example.de"

# check if we have already checked before (since restarting the server)
if [ -f ${OTHFILE} ]; then
    OTHFILEEXISTS=true
else
    OTHFILEEXISTS=false
fi

# if we have downloaded a file before, store it for later
if ${OTHFILEEXISTS}
then
    mv ${OTHFILE} ${OTHFILEOLD}
fi

# download the current file
#wget ${OTHURL} -O ${OTHFILE} -o /dev/null
curl ${OTHURL} -o ${OTHFILE}

# It seems that the name of the game is shown in a <h5> tag, so why not just get this out of the file to get the name…
NEWNAME=$(grep -i "origin-store-program-offer-title" ${OTHFILE} | sed "${SEDEXPRESSION}")

# If we have an old file, compare the name in the current file with the name in the old file.
if ${OTHFILEEXISTS}
then
    #OLDNAME=$(grep -i "<h5>" ${OTHFILEOLD} | sed "${SEDEXPRESSION}")
    OLDNAME=$(grep -i "origin-store-program-offer-title" ${OTHFILEOLD} | sed "${SEDEXPRESSION}")

    # If both names are the same, send an email to someone.
    if [ ! "${OLDNAME}" = "${NEWNAME}" ]; then
        NEEDTOMAIL=true
        MAILTEXT="I found a new game in the Origin on-the-house program.\n\n\tOld game: ${OLDNAME}\n\tNew game: ${NEWNAME}\n"
    else
        NEEDTOMAIL=false
    fi
else
    # Ouch, there was no old file, send an email anyways.
    NEEDTOMAIL=true
    MAILTEXT="The current game in the Origin on-the-house program is:\n\n\t${NEWNAME}\n\nI don't have any recollection of the last game, because you probably restarted the server."
fi

# If we have something interesting to say, mail something to someone, somewhere.
if ${NEEDTOMAIL}
then
    COMPLETEMAILTEXT="${MAILTEXT}\n${MAILTEXTEND}"
    echo "${COMPLETEMAILTEXT}" #| mail -s "New game found in the Origin on-the-house program." ${MAILTO}
fi
