// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

#include "gis/cuda/common/gpu_memory.h"
#include "gis/cuda/functor/relate_template.h"
#include "gis/cuda/functor/st_equals.h"

namespace arctern {
namespace gis {
namespace cuda {

void ST_Equals(const GeometryVector& left_vec, const GeometryVector& right_vec,
               bool* host_results) {
  auto size = left_vec.size();
  auto left_ctx_holder = left_vec.CreateReadGpuContext();
  auto right_ctx_holder = right_vec.CreateReadGpuContext();
  auto matrices = GenRelateMatrix(*left_ctx_holder, *right_ctx_holder);
  auto results = GpuMakeUniqueArray<bool>(size);
  auto func = [] __device__(de9im::Matrix mat) {
    return mat.IsMatchTo(de9im::Matrix("T*F**FFF*"));
  };  // NOLINT

  RelationFinalize(func, matrices.get(), left_vec.size(), results.get());
  GpuMemcpy(host_results, results.get(), size);
}

}  // namespace cuda
}  // namespace gis
}  // namespace arctern
