# frozen_string_literal: true

module Parsers
  class ParserBase # rubocop:disable Style/Documentation
    def initialize(mail)
      @mail = mail
      @body = extract_body
    end

    def parse
      raise NotImplementedError
    end

    private

    def extract_body
      if @mail.multipart?
        part = @mail.parts.find { |p| p.content_type =~ %r{text/plain} }
        part ? part.decoded : @mail.parts.first.decoded
      else
        @mail.body.decoded
      end
    end

    def extract_by_label(*labels)
      labels.each do |label|
        re = /#{label}\s*[:-]?\s*(.+)/i
        if (m = @body.match(re))
          return m[1].to_s.strip
        end
      end
      nil
    end
  end
end
