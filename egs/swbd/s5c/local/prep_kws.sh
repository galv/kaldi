# cleanup
rm -rf data/local/dict_kws
rm -rf data/lang_kws
rm -rf exp/tri4/graph_kws

local/kws_prepare_dict.sh
utils/prepare_lang.sh data/local/dict_kws "<unk>" data/local/lang_kws data/lang_kws

# Compiles G for trigram LM
LM=data/local/lm/sw1.o3g.kn.gz
srilm_opts="-subset -prune-lowprobs -unk -tolower -order 3"
utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
  data/lang_kws $LM data/local/dict_kws/lexicon.txt data/lang_kws_tg

# create the graph
utils/mkgraph.sh data/lang_kws_tg exp/tri4 exp/tri4/graph_kws

