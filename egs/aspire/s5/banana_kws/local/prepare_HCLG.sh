#!/bin/bash
# adapted from https://chrisearch.wordpress.com/2017/03/11/speech-recognition-using-kaldi-extending-and-using-the-aspire-model/

. ./cmd.sh
. ./path.sh
model=exp/tdnn_7b_chain_online
phones_src=exp/tdnn_7b_chain_online/phones.txt
dict_src=banana_kws/data/local/dict
lm_src=banana_kws/data/local/lang/G.fst

lang=
