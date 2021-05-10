// pybind/fstext/fstext_pybind.cc

// Copyright 2020   Mobvoi AI Lab, Beijing, China
//                  (author: Fangjun Kuang, Yaguang Hu, Jian Wang)

// See ../../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#include "fstext/fstext_pybind.h"
#include "fstext/fstext-lib.h"
#include "lat/kaldi-lattice.h"

#include "fstext/kaldi_fst_io_pybind.h"
#include "fstext/lattice_weight_pybind.h"

void pybind_fstext(py::module& m) {
  pybind_kaldi_fst_io(m);
  pybind_lattice_weight(m);

  // We should really use a fst::Fst here, but vector_fst_pybind.h
  // doesn't implement inheritance correctly and I don't want to deal
  // with it right now.
  m.def("GetLinearSymbolSequence", [](const fst::VectorFst<kaldi::LatticeArc>& fst)->std::tuple<bool, std::vector<int32>, std::vector<int32>, kaldi::LatticeArc::Weight> {
          std::vector<int32> isymbols_out;
          std::vector<int32> osymbols_out;
          kaldi::LatticeArc::Weight tot_weight_out;
          bool result = fst::GetLinearSymbolSequence<kaldi::LatticeArc, kaldi::int32>
              (fst, &isymbols_out, &osymbols_out, &tot_weight_out);
          return std::make_tuple(result, isymbols_out, osymbols_out, tot_weight_out);
      });
}
