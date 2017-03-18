window=15
overlap=5
delta=`echo $window"-"$overlap | bc -l`
duration=`sox $1 -n stat 2>&1 | grep Length | cut -f2 -d":" | tr -d " "` 
intDuration=`echo $duration | cut -f1 -d"."` 
noExt=`echo $1 | cut -f1 -d"."`
ext=`echo $1 | cut -f2-1000 -d"."`
outExt="wav"
windowCnt=`echo "scale=2.0;0.99999999+"$duration"/("$window"-"$overlap")" | bc -l | cut -f1 -d"."` 

for w in `seq 1 $windowCnt`; do 
  if [ $w -lt 10 ]; then
    wind="000"$w
  elif [ $w -lt 100 ]; then
    wind="00"$w
  elif [ $w -lt 1000 ]; then
    wind="0"$w
  else
    wind=$w
  fi

  start=`echo "("$w"-1)*"$delta | bc -l`;
  end=`echo $start"+"$window | bc -l` ;
  if [ $end -gt $intDuration ]; then
    end=$intDuration
    start=`echo $end"-"$window | bc -l | cut -f1 -d"."`
  fi

  if [ $start -lt 0 ]; then
    start=0
    window=$intDuration
    end=$intDuration
  fi
  
  #echo "start="$start", end="$end
 
  fileName=$noExt.$wind"."$start"."$end"."$outExt
  sox $1 -c1 -r 16000 -t wavpcm -e signed-integer $fileName trim $start =$end  
  echo "utt"$wind" utt"$wind" cat "$fileName" | ";
done
