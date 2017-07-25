require_relative "./env"

module LeeroyJenkins
  class Logger
    NAME = "LJ"

    class << self
      def warn(message)
        write("[\e[33m#{NAME} WARN\e[0m]", message)
      end

      def error(message)
        write("[\e[31m#{NAME} ERROR\e[0m]", message)
      end

      def info(message)
        write("[\e[36m#{NAME} INFO\e[0m]", message)
      end

      def write(header, message)
        if Env.test?
          test_log.unshift(message)
        else
          STDOUT.write("#{header} #{message} \n")
        end
      end

      def write_error(header, message)
        if Env.test?
          test_log.unshift(message)
        else
          STDERR.write("#{header} #{message} \n")
        end
      end

      def test_log
        @test_log ||= []
      end
    end
  end
end
