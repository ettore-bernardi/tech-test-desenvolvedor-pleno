module Parsers
  class Base
    attr_reader :mail

    def initialize(email_content)
      @mail = Mail.read_from_string(email_content)
    end

    def parse
      raise NotImplementedError, "#{self.class} has not implemented method 'parse'"
    end

    private

    def extract_field(content, patterns)
      patterns.each do |pattern|
        match = content.match(pattern)
        return match[1].strip if match
      end
      nil
    end
  end
end
