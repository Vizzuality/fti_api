# frozen_string_literal: true

module FileDataImporter
  module Parser
    class Base
      attr_reader :path_to_file

      def initialize(path_to_file)
        @path_to_file = path_to_file
      end

      def foreach_with_line
        raise NotImplementedError, "You need to implement foreach_with_line method."
      end
    end
  end
end
