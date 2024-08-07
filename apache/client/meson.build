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
  'src/lauth/authorization_result.cpp',
  'src/lauth/http_client.cpp',
])
lauth_tests = files([
  'test/lauth/api_client_test.cpp',
  'test/lauth/authorizer_test.cpp',
  'test/lauth/authorization_result_test.cpp',
  'test/lauth/request_test.cpp',
])

lauth_integration_tests = files([
  'test/lauth/http_client_test.cpp',
])

os = host_machine.system()
if os == 'darwin'
  httplib_links = []
else
  httplib_links = ['-lssl', '-lcrypto']
endif

liblauth = shared_library(
  'lauth',
  lauth_sources,
  include_directories: lauth_includes,
  dependencies: [
    cpp_httplib,
    json,
  ],
  link_args: httplib_links,
  install: true,
)

liblauth_dep = declare_dependency(include_directories: lauth_includes, link_with: liblauth)

install_headers(
  'include/lauth/api_client.hpp',
  'include/lauth/authorization_result.hpp',
  'include/lauth/authorizer.hpp',
  'include/lauth/http_client.hpp',
  'include/lauth/http_params.hpp',
  'include/lauth/http_headers.hpp',
  'include/lauth/json.hpp',
  'include/lauth/json_conversions.hpp',
  'include/lauth/logging.hpp',
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
      gmock,
    ],
    link_args: httplib_links,
  )
  test('lauth-test', tests)
endif

if get_option('integration-tests')
  integration_tests = executable(
    'lauth-integration-test',
    lauth_sources + lauth_integration_tests,
    include_directories: lauth_includes,
    dependencies: [
      cpp_httplib,
      json,
      gtest,
      gmock
    ],
    link_args: httplib_links,
  )
  test('lauth-integration-test', integration_tests)
endif

executable(
  'http-service',
  files(['test/mock_service.cpp']),
  dependencies: [
    cpp_httplib,
    json,
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

executable(
  'api-check',
  files(['src/api_check.cpp']),
  include_directories: lauth_includes,
  dependencies: [
    cpp_httplib,
    liblauth_dep,
  ],
  link_args: httplib_links,
)
