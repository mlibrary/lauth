#ifndef __LAUTH_LOGGING_HPP__
#define __LAUTH_LOGGING_HPP__

#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <sstream>

namespace mlibrary::lauth {
  enum LogLevel {
    FATAL = 0,
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4,
    TRACE = 5
  };

  const std::string LogLevels[] = {"FATAL", "ERROR", "WARN", "INFO", "DEBUG", "TRACE"};

  class LogSink {
    public:
      virtual ~LogSink() = default;
      virtual void write(const std::string& level, const std::string& msg, const char* file, int line) = 0;
      virtual void fatal(const std::string& msg, const char* file, int line) = 0;
      virtual void error(const std::string& msg, const char* file, int line) = 0;
      virtual void warn(const std::string& msg, const char* file, int line) = 0;
      virtual void info(const std::string& msg, const char* file, int line) = 0;
      virtual void debug(const std::string& msg, const char* file, int line) = 0;
      virtual void trace(const std::string& msg, const char* file, int line) = 0;
  };

  class StdOut : public LogSink {
    public:
      virtual ~StdOut() = default;

      void write(const std::string& level, const std::string& msg, const char* file, int line) override {
        std::cout << "[" << level << "] " << file << "(" << line << "): " << msg << std::endl;
      }

      void fatal(const std::string& msg, const char* file, int line) override {
        write(LogLevels[LogLevel::FATAL], msg, file, line);
      }

      void error(const std::string& msg, const char* file, int line) override {
        write(LogLevels[LogLevel::ERROR], msg, file, line);
      }

      void warn(const std::string& msg, const char* file, int line) override {
        write(LogLevels[LogLevel::WARN], msg, file, line);
      }

      void info(const std::string& msg, const char* file, int line) override {
        write(LogLevels[LogLevel::INFO], msg, file, line);
      }

      void debug(const std::string& msg, const char* file, int line) override {
        write(LogLevels[LogLevel::DEBUG], msg, file, line);
      }

      void trace(const std::string& msg, const char* file, int line) override {
        write(LogLevels[LogLevel::TRACE], msg, file, line);
      }
  };

  class NullLog : public LogSink {
    public:
      virtual ~NullLog() = default;
      void write(const std::string&, const std::string&, const char*, int) override {}
      void fatal(const std::string&, const char*, int) override {}
      void error(const std::string&, const char*, int) override {}
      void warn(const std::string&, const char*, int) override {}
      void info(const std::string&, const char*, int) override {}
      void debug(const std::string&, const char*, int) override {}
      void trace(const std::string&, const char*, int) override {}
  };

  class Logger {
    public:
      Logger() : out(std::make_unique<NullLog>()) {};
      Logger(std::unique_ptr<LogSink>&& out) : out(std::move(out)) {};

      Logger(const Logger&) = delete;
      Logger& operator=(const Logger&) = delete;
      Logger(Logger&&) = delete;
      Logger& operator=(const Logger&&) = delete;
      virtual ~Logger() = default;

      static void set(std::shared_ptr<Logger> logger) {
        Logger::logger = logger;
      }

      static std::shared_ptr<Logger> get() {
        if (!Logger::logger) {
          Logger::logger = std::make_shared<Logger>();
        }
        return Logger::logger;
      }

      void fatal(const std::string& msg, const char* file, int line) {
        out->fatal(msg, file, line);
      }

      void error(const std::string& msg, const char* file, int line) {
        out->error(msg, file, line);
      }

      void warn(const std::string& msg, const char* file, int line) {
        out->warn(msg, file, line);
      }

      void info(const std::string& msg, const char* file, int line) {
        out->info(msg, file, line);
      }

      void debug(const std::string& msg, const char* file, int line) {
        out->debug(msg, file, line);
      }

      void trace(const std::string& msg, const char* file, int line) {
        out->trace(msg, file, line);
      }

    protected:
      inline static std::shared_ptr<Logger> logger;
      std::unique_ptr<LogSink> out;
  };
}

#define LAUTH_DEBUG(msg)                       \
  mlibrary::lauth::Logger::get()->debug(       \
    static_cast<std::ostringstream&>(          \
      std::ostringstream().flush() << msg      \
    ).str(),                                   \
    __FILE__, __LINE__                         \
  )

#define LAUTH_WARN(msg)                        \
  mlibrary::lauth::Logger::get()->warn(        \
    static_cast<std::ostringstream&>(          \
      std::ostringstream().flush() << msg      \
    ).str(),                                   \
    __FILE__, __LINE__                         \
  )

#endif // __LAUTH_LOGGING_HPP__
