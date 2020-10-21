# Need to depend upon this.

package(
    default_visibility = ["//visibility:public"],
)

licenses(["notice"])

exports_files(["LICENSE"])

prefix_dir = "src/"

cc_library(
    name="base",
    srcs = [
     prefix_dir + "base/kaldi-error.cc",
     prefix_dir + "base/kaldi-math.cc",
     prefix_dir + "base/io-funcs.cc",
     prefix_dir + "base/timer.cc",
     prefix_dir + "base/kaldi-utils.cc",
    ],
    hdrs = [
    prefix_dir + "base/io-funcs-inl.h",
    prefix_dir + "base/io-funcs.h",
    prefix_dir + "base/kaldi-common.h",
    prefix_dir + "base/kaldi-error.h",
    prefix_dir + "base/kaldi-math.h",
    prefix_dir + "base/kaldi-types.h",
    prefix_dir + "base/kaldi-utils.h",
    prefix_dir + "base/timer.h",
    prefix_dir + "base/version.h",
    ],
    includes = [prefix_dir],
    deps = ["@openfst//:fst"]
)

# "@openfst:fst"

