#!/bin/bash

target=$1;

function gospiderPlus(){
 #printf '\n[Gospidering]'
 spider=$(gospider -a -s "$1" -d 3 -c 100)
 internalPathsRemovedDots=$(
 echo -e "$spider" | 
 sed 's#\.\/#\/#g'
 )
 juicyPathsFromGospider "$internalPathsRemovedDots";
}

function juicyPathsFromGospider(){
 #printf '\n[JuicyPaths]\n'
 #echo -e "$1" | head
 internalPaths=$(
   echo -e "$1" |
   tr ']' ' ' |
   awk '/linkfinder/{print $4" "$NF}' 
  )
 [ -z "$internalPaths" ] && exit
 
 echo -e "$internalPaths" |
 while read -r line; do 
  analizingCorrectPathWalk "$line" 
 done
}

function analizingCorrectPathWalk(){
 #printf '\n[Analizing Valid Path Walk]\n'
 	#echo -e "$1"
 
  url=$(echo $1 | awk '{print $1}');
  urlCount=$(echo $url | awk -F/ '{print NF-2}');
  path=$(
  echo $1 | 
  awk '{print $2}' | 
  sed 's#\.\/#\/#g' | 
  sed 's#\/\/#\/#g' | 
  sed 's#\/\/#\/#g'
  );

   if [[ "$path" != /* ]];then
   	#echo "[Fixing path] $path" # DEBUG
    path=$(echo "/"$path)
    #echo "[Fixed to] $path" # DEBUG
   fi

   if [[ "$url" =~ \/$ ]];then
   	#echo "[1 Ajustando url] $url" # DEBUG
    url=$(echo "$url" | sed 's#.$##g')
    #echo "[2 Ajustando url] $url" # DEBUG
   fi

   if [[ "$urlCount" -gt "1" && "$path" != *"http"* && "$path" != *"locale"* && url != *"locale"* ]];then
     for i in $(eval echo {1..$urlCount});do 
     	pass=$(echo $(echo $url | rev |cut -d/ -f $i- | rev)$path);
     	 onlyPathsUp "$pass"
     done | anew
   fi

 }

function onlyPathsUp(){
 
 #printf '\n[onlyPathsUp]\n'
 #echo -e "$1" | head -n 100
 echo -e "$1" |
 grep -v "/.*\.js.*/" |
 grep -v "[a-z]\{2\}\-[a-z]\{2\}" |
 anew | 
 httpx -silent -threads 300 -follow-redirects -content-length -status-code |
 grep 200 | 
 anew jsHttpsUrl | 
 sort -k3 -n
}

gospiderPlus $target
