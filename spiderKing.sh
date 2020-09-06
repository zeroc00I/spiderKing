#!/bin/bash

fileInput=$1;

function gospiderPlus(){
 printf '\n[Gospidering]'
 spider=$(timeout 12 gospider -S $1 -d 3 -c 300)
 internalPathsRemovedDots=$(echo -e "$spider" | sed 's#\.\/#\/#g')
 juicyPathsFromGospider "$internalPathsRemovedDots";
}

function juicyPathsFromGospider(){
 printf '\n[JuicyPaths]'
 internalPaths=$(echo -e "$1" | tr ']' ' ' | awk '/linkfinder/{print $4" "$NF}' )
 [ -z "$internalPaths" ] && printf "\n[Not Found] Internal Paths\n" && exit
 
 echo -e "$internalPaths" | sed 's#\.\/#\/#g' | sed 's#\/\/#\/#g' | sed 's#\/\/#\/#g'
 analizingCorrectPathWalk "$internalPaths"
}

function analizingCorrectPathWalk(){
 printf '\n[Analizing Valid Path Walk]'
 
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

gospiderPlus $fileInput
