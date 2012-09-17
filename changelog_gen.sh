#!/bin/sh

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate=${1}
cdate=`date +"%m_%d_%Y"`
rdir=`pwd`

sdate=${ydate}

# Check the date start range is set
# Find the directories to log
find $rdir -name .git | sed 's/\/.git//g' | sed 'N;$!P;$!D;$d' | while read line
do
    cd $line
    # Test to see if the repo needs to have a changelog written.
    log=$(git log --pretty="%an - %s" --no-merges --since=$sdate --date-order)
    project=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    if [ -z "$log" ]; then
        echo "Nothing updated on $project, skipping"
    else
        # Prepend group project ownership to each project.
        origin=`grep "$project" $rdir/.repo/manifest.xml | awk {'print $4'} | cut -f2 -d '"'`
        if [ "$origin" = "aokp" ]; then
            proj_credit=AOKP
        elif [ "$origin" = "i9100" ]; then
            proj_credit=i9100-AOKP
        elif [ "$origin" = "aosp" ]; then
            proj_credit=AOSP
        elif [ "$origin" = "cm" ]; then
            proj_credit=CyanogenMod
        else
            proj_credit=""
        fi
        # Write the changelog
        echo "$proj_credit Project name: $project" >> "$WORKSPACE"/archive/Changelog_$cdate.txt
        echo "$log" | while read line
        do
             echo "  •$line" >> "$WORKSPACE"/archive/Changelog_$cdate.txt
        done
        echo "" >> "$WORKSPACE"/archive/Changelog_$cdate.txt
    fi
done

exit 0
