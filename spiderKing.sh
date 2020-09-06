#!/bin/bash

fileInput=$1;

function gospider(){
 printf '[Gospidering]'
 spider=$(timeout 2 gospider -S $1 -d 3 -c 300 2>/dev/null | anew)
 echo -e "$spider"
 juicyPathsFromGospider "$spider";
}

function juicyPathsFromGospider(){
 printf '[JuicyPaths]'
 internalPaths=$(echo -e "$1" | tr ']' ' ' | sed 's#\.\/#\/#g' | awk '/linkfinder/{print $4" "$NF}')
 echo -e "$internalPaths"
 exit
 #awk -F/ '{print $1"//"$3"/"$NF}'
 #analizingCorrectPathWalk "$internalPaths"
}

function analizingCorrectPathWalk(){
 printf '[Analizing Valid Path Walk]'
 
 echo -e "$1" | while read line; do 
  url=$(echo $line | awk '{print $1}');
  urlCount=$(echo $url | awk -F/ '{print NF-2}');
  path=$(echo $line | awk '{print $2}');
   if [[ "$urlCount" -gt "1" ]];then
     for i in $(eval echo {1..$urlCount});do 
     echo $(echo $url | rev |cut -d/ -f $i- | rev)$path;
     done | anew
   fi
 done

 # awk -F/ '{for (path=3; path<NF;path++) print $1"//"$path"/"$NF}' 
}

function onlyPathsUp(){
 printf '[onlyPathsUp]'
 echo -e "$1" | 
 anew | 
 httpx -silent -threads 300 -content-length -content-type
}

gospider $fileInput
