module LeeroyJenkins
  class Env
    LIVE = :live
    TEST = :test
    VALID = [LIVE, TEST]

    class << self
      def name
        @name || LIVE
      end

      def set_to_live!
        @name = LIVE
      end

      def live?
        name == LIVE
      end

      def set_to_test!
        @name = TEST
      end

      def test?
        name == TEST
      end
    end
  end
end
