project('liblauth', 'cpp',
  version : '0.1',
  default_options : ['warning_level=3',
                     'cpp_std=c++2a'])

cpp_httplib = subproject('cpp-httplib').get_variable('cpp_httplib_dep')
json = dependency('nlohmann_json', fallback: ['nlohmann_json', 'nlohmann_json_dep'])

gtest = subproject('gtest').get_variable('gtest_main_dep')
gmock = subproject('gtest').get_variable('gmock_dep')

# subdir('include')
# subdir('src')
# subdir('test')

lauth_includes = include_directories('include')
lauth_sources = files([
  'src/lauth/api_client.cpp',
  'src/lauth/authorizer.cpp',
  'src/lauth/http_client.cpp',
])
lauth_tests = files([
  'test/lauth/api_client_test.cpp',
  'test/lauth/authorizer_test.cpp',
  'test/lauth/http_client_test.cpp',
  'test/lauth/request_test.cpp',
])

liblauth = shared_library(
  'lauth',
  lauth_sources,
  include_directories: lauth_includes,
  dependencies: [
    cpp_httplib,
    json,
  ],
  install: true,
)

install_headers(
  'include/lauth/api_client.hpp',
  'include/lauth/authorizer.hpp',
  'include/lauth/http_client.hpp',
  'include/lauth/request.hpp',
  subdir: 'lauth')

if get_option('tests')
  tests = executable(
    'lauth-test',
    lauth_sources + lauth_tests,
    include_directories: lauth_includes,
    dependencies: [
      cpp_httplib,
      json,
      gtest,
      gmock
    ]
  )

  test('lauth-test', tests)
endif

os = host_machine.system()
if os == 'darwin'
  httplib_links = []
else
  httplib_links = ['-lssl', '-lcrypto']
endif

executable(
  'http-service',
  files(['test/lauth/mock_service.cpp']),
  dependencies: [
    cpp_httplib,
  ],
  link_args: httplib_links
)

executable(
  'http-check',
  files(['src/http_check.cpp']),
  dependencies: [
    cpp_httplib,
  ],
  link_args: httplib_links
)
