require_relative "./env"

module LeeroyJenkins
  class Utils
    # Mostly here so we can stub in specs
    def self.quit_program(code)
      exit(code) unless Env.test?
    end
  end
end
