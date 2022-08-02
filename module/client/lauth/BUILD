cc_library(
  name = "lauth-client",
  srcs = glob(["*.cpp", "v1/*.h", "v1/*.cpp"]),
  hdrs = glob(["*.h"]),
  deps = ["//include:cpp-httplib", "//include:nlohmann-json"],
  linkopts = ["-lssl", "-lcrypto"],
  alwayslink = True,
  # strip_include_prefix = ".",
  visibility = ["//visibility:public"],
)
