// pybind/matrix/matrix_pybind.cc

// Copyright 2019   Daniel Povey
//           2019   Dongji Gao
//           2019   Mobvoi AI Lab, Beijing, China (author: Fangjun Kuang)

// See ../../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#include "matrix/matrix_pybind.h"

#include "matrix/compressed_matrix_pybind.h"
#include "matrix/kaldi_matrix_pybind.h"
#include "matrix/kaldi_vector_pybind.h"
#include "matrix/matrix_common_pybind.h"
#include "matrix/sparse_matrix_pybind.h"

void pybind_matrix(py::module& m) {
  pybind_matrix_common(m);
  pybind_kaldi_vector(m);
  pybind_sparse_matrix(m);
  pybind_kaldi_matrix(m);
  pybind_compressed_matrix(m);
}
