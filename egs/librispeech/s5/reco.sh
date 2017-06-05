#vars
export kaldiHome=`pwd`"/../../.."
export decode_cmd="run.pl --mem 4G"
export train_cmd="run.pl --mem 4G"
export max_jobs_run=20
mfccdir=`pwd`/mfcc
modelDir=nnet2_online/nnet_ms_a_online
graphDir=nnet2_online/nnet_ms_a_online/graph_test
min_lmwt=1
max_lmwt=20
step_lmwt=1
lmwt_cnt=`echo "("$max_lmwt"-"$min_lmwt")/"$step_lmwt | bc -l`

# create dir and cleanup if needed
if [ ! -d data/workfit ]; then
  mkdir data/workfit
fi;

if [ -d data/workfit ]; then
  rm -rf exp/$modelDir/decode_workfit/*
fi;
rm -rf data/workfit/*
rm -rf mfcc/*workfit*

# split file & create wav.scp, utt2spk
sh split.sh $1 > data/workfit/split
cut -f1,2 -d" " data/workfit/split  | sort > data/workfit/utt2spk
cut -f2-100 -d" " data/workfit/split | sort > data/workfit/wav.scp

#determine job count
jobs=`wc -l data/workfit/split | cut -f1 -d" "`

# generate other files
utils/fix_data_dir.sh data/workfit

# create mfcc & cmvn
echo "---------------------------------------"
echo "Computing & normalizing mfcc features..."
echo "---------------------------------------"
steps/make_mfcc.sh --nj $jobs --cmd "$train_cmd" --sample_frequency 16000 data/workfit exp/make_mfcc/workfit $mfccdir
steps/compute_cmvn_stats.sh data/workfit exp/make_mfcc/workfit $mfccdir

# decode
echo "----------------"
echo "nnet2 Decoding..."
echo "----------------"

steps/online/nnet2/decode.sh --nj $jobs --cmd "$decode_cmd" --per_utt true \
  --skip_scoring true exp/$graphDir data/workfit exp/$modelDir/decode_workfit
 
#convert to FSTs
echo "----------------------------------------------"
echo "Converting lattices to CTMs..."
echo "----------------------------------------------"
for l in `seq 1 $jobs`; do 
   if [ -f exp/$modelDir/decode_workfit/lat.$l.gz ]; then
     for lmwt in `seq 0 $lmwt_cnt`; do
       (
         LMWT=`echo $min_lmwt"+("$lmwt"*"$step_lmwt")" | bc -l`
         $kaldiHome/src/latbin/lattice-align-words exp/$graphDir/phones/word_boundary.int \
           exp/$modelDir/final.mdl "ark:gunzip -c exp/$modelDir/decode_workfit/lat.$l.gz|" ark:- 2> null | \
           ~/kaldi/src/latbin/lattice-to-ctm-conf --decode-mbr=true --inv-acoustic-scale=$LMWT ark:- -  2> null | \
          utils/int2sym.pl -f 5 exp/$graphDir/words.txt > exp/$modelDir/decode_workfit/path_$LMWT.$l.ctm || exit 1;
       ) &
     done
     wait
     (
       outputFileName=`head -$l data/workfit/wav.scp | tail -1 | cut -f3 -d" " | cut -f1-4 -d"."`".kaldi.libri.ctm"
       cat exp/$modelDir/decode_workfit/path_*.$l.ctm | cut -f3-100 -d" " | sort -u > $outputFileName
       echo "CTM saved to: "$outputFileName
     ) &          
   fi;
done
wait




