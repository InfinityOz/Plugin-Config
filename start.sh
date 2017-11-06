#!/bin/sh

cd "$(dirname "$0")"
. ./settings.sh

# makes things easier if script needs debugging
if [ x$FTB_VERBOSE = xyes ]; then
    set -x
fi

# cleaner code
eula_false() {
    grep -q 'eula=false' eula.txt
    return $?
}

start_server() {
"$JAVACMD" -server -Xms4096m -Xmx4096m -XX:PermSize=256m -XX:NewRatio=3 -XX:SurvivorRatio=3 -XX:TargetSurvivorRatio=80 -XX:MaxTenuringThreshold=8 -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:MaxGCPauseMillis=10 -XX:GCPauseIntervalMillis=50 -XX:MaxGCMinorPauseMillis=7 -XX:+ExplicitGCInvokesConcurrent -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=60 -XX:+BindGCTaskThreadsToCPUs -Xnoclassgc -jar Thermos-1.7.10-1614-server.jar nogui
}

# run install script if MC server or launchwrapper s missing
if [ ! -f $JARFILE -o ! -f libraries/$LAUNCHWRAPPER ]; then
    echo "Missing required jars. Running install script!"
    sh ./FTBInstall.sh
fi

# check if there is eula.txt and if it has correct content
if [ -f eula.txt ] && eula_false ; then
    echo "Make sure to read eula.txt before playing!"
    echo "To exit press <enter>"
    read ignored
    exit
fi

# inform user if eula.txt not found
if [ ! -f eula.txt ]; then
    echo "Missing eula.txt. Startup will fail and eula.txt will be created"
    echo "Make sure to read eula.txt before playing!"
    echo "To continue press <enter>"
    read ignored
fi

echo "Starting server"
rm -f autostart.stamp
start_server

while [ -e autostart.stamp ] ; do
    rm -f autostart.stamp
    echo "If you want to completely stop the server process now, press Ctrl+C before the time is up!"
    for i in 5 4 3 2 1; do
        echo "Restarting server in $i"
        sleep 1
    done
    echo "Rebooting now!"
    start_server
    echo "Server process finished"
done

