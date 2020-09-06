#!/bin/bash

fileInput=$1;

function gospiderPlus(){
 printf '\n[Gospidering]'
 spider=$(gospider -S "$1" -d 4 -c 300)
 internalPathsRemovedDots=$(echo -e "$spider" | sed 's#\.\/#\/#g')
 juicyPathsFromGospider "$internalPathsRemovedDots";
}

function juicyPathsFromGospider(){
 printf '\n[JuicyPaths]\n'
 echo -e "$1" | head
 internalPaths=$(echo -e "$1" | tr ']' ' ' | awk '/linkfinder/{print $4" "$NF}' )
 [ -z "$internalPaths" ] && printf "\n[Not Found] Internal Paths\n" && exit
 
 analizingCorrectPathWalk "$internalPaths"
}

function analizingCorrectPathWalk(){
 printf '\n[Analizing Valid Path Walk]\n'
 echo -e "$1" | head
 allInternalPaths=$(
 echo -e "$1" | while read -r line; do 
  url=$(echo $line | awk '{print $1}');
  urlCount=$(echo $url | awk -F/ '{print NF-2}');
  path=$(echo $line | awk '{print $2}' | sed 's#\.\/#\/#g' | sed 's#\/\/#\/#g' | sed 's#\/\/#\/#g');
   if [[ $path != "^/" ]];then
   $path="/"$path
   fi
   if [[ "$urlCount" -gt "1" && "$path" != *"http"* && "$path" != *"locale"* && url != *"locale"* ]];then
     for i in $(eval echo {1..$urlCount});do 
     echo $(echo $url | rev |cut -d/ -f $i- | rev)$path;
     done | anew
   fi
 done )
 
 onlyPathsUp "$allInternalPaths"

 # awk -F/ '{for (path=3; path<NF;path++) print $1"//"$path"/"$NF}' 
}

function onlyPathsUp(){
 printf '\n[onlyPathsUp]\n'
 echo -e "$1" | head -n 100
 echo -e "$1" | grep -v "/.*.js.*/" | grep -v "[a-z]\{2\}\-[a-z]\{2\}" |
 anew | 
 httpx -silent -threads 300 -follow-redirects -content-length -status-code | grep 200
}

gospiderPlus $fileInput
