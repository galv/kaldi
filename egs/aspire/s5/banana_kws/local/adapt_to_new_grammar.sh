#!/bin/bash
# adapted from
# https://chrisearch.wordpress.com/2017/03/11/speech-recognition-using-kaldi-extending-and-using-the-aspire-model/

# Adapts $online_model to use the new grammar in $lm_src, putting the new model into 

. ./cmd.sh
. ./path.sh

# inputs
stage=0
experiment_name=1a

phones_src=exp/tdnn_7b_chain_online/phones.txt
dict_src=banana_kws/data/local/dict
lm_src=banana_kws/data/local/lang/G_text.fst
new_grammar_online_model=banana_kws/exp/$experiment_name

raw_wav_data=/home/galv/development/keyword_data
data_ark_dir=banana_kws/data/hot_word_wav_archives
lattice_ark_dir=banana_kws/exp/$experiment_name/hot_word_lattice_archives
phone_numbers=( 4044455385 4044454027 ActionItem.PolyCom 4044454269 )

# decoding inputs
wav_file=TODO
beam=15.0

. ./utils/parse_options.sh

# constant inputs
original_model=exp/chain/tdnn_7b
original_online_model=exp/tdnn_7b_chain_online

# outputs
#lang=banana_kws/exp/$experiment_name/data/lang
dict=banana_kws/exp/$experiment_name/data/dict
dict_tmp=banana_kws/exp/$experiment_name/data/dict_tmp
graph=banana_kws/exp/$experiment_name/graph

if [ $stage -le 0 ]; then

utils/prepare_lang.sh --phone-symbol-table $phones_src $dict_src "<unk>" $dict_tmp $dict

fstcompile --isymbols=$dict/words.txt --osymbols=$dict/words.txt --keep_isymbols=false \
	   --keep_osymbols=false $lm_src > $dict/G.fst

# Should self-loop-scale be 1.0 for chain models?
utils/mkgraph.sh --self-loop-scale 1.0 $dict $original_online_model $graph

steps/online/nnet3/prepare_online_decoding.sh --mfcc-config conf/mfcc_hires.conf \
					      $dict exp/nnet3/extractor $original_model \
					      $new_grammar_online_model

fi

# Prepare data for transcribing lattices
if [ $stage -le 1 ]; then
    mkdir -p $data_ark_dir
    for phone_number in "${phone_numbers[@]}"; do
	mkdir -p $data_ark_dir/$phone_number
	wav_scp=$data_ark_dir/$phone_number/wav.scp
	spk2utt=$data_ark_dir/$phone_number/spk2utt.ark
	# Truncate files, in case they already exist, since we will be
	# appending to them.
	rm -f $wav_scp
	rm -f $spk2utt
	for wav_file in $raw_wav_data/$phone_number/*.wav; do
	    echo "$(basename $wav_file) $(realpath $wav_file)" >> $wav_scp
	    echo "$(basename $wav_file) $(basename $wav_file)" >> $spk2utt
	done
    done
fi

# Actually transcribe the lattices
if [ $stage -le 2 ]; then
    mkdir -p $lattice_ark_dir

    for phone_number in "${phone_numbers[@]}"; do
	spk2utt=$data_ark_dir/$phone_number/spk2utt.ark
	wav_scp=$data_ark_dir/$phone_number/wav.scp
	lat_ark=$lattice_ark_dir/$phone_number.ark
	
	online2-wav-nnet3-latgen-faster \
	    --online=false \
	    --do-endpointing=false \
	    --frame-subsampling-factor=3 \
	    --config=$new_grammar_online_model/conf/online.conf \
	    --max-active=7000 \
	    --beam=15.0 \
	    --lattice-beam=6.0 \
	    --acoustic-scale=1.0 \
	    --word-symbol-table=$graph/words.txt \
	    $original_online_model/final.mdl \
	    $graph/HCLG.fst \
	    "ark:$spk2utt" \
	    "scp:$wav_scp" \
	    "ark:$lat_ark" &
    done
    wait
fi

if [ $stage -le 3 ]; then

    online2-wav-nnet3-latgen-faster \
	--online=false \
	--do-endpointing=false \
	--frame-subsampling-factor=3 \
	--config=$new_grammar_online_model/conf/online.conf \
	--max-active=7000 \
	--beam=$beam \
	--lattice-beam=6.0 \
	--acoustic-scale=1.0 \
	--word-symbol-table=$graph/words.txt \
	$original_online_model/final.mdl \
	$graph/HCLG.fst \
	"ark:echo utt1 utt1|" \
	"scp:echo utt1 $wav_file|" \
	"ark:/dev/null"
fi

# Possibly do kws on the lattices? Doesn't seem necessary. Probably
# want to make my own C executable callable from Go.
if [ $stage -le 4 ]; then
    exit "TODO"
fi
