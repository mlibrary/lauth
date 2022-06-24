cc_library(
  name = "lauth-client",
  srcs = glob(["*.cpp"]),
  hdrs = glob(["*.h"]),
  deps = ["//include:cpp-httplib", "//include:nlohmann-json"],
  linkopts = ["-lssl", "-lcrypto"],
  # strip_include_prefix = ".",
  visibility = ["//visibility:public"],
)
