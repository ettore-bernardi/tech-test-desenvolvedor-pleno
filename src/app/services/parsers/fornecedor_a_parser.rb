# frozen_string_literal: true

module Parsers
  class FornecedorAParser < ParserBase # rubocop:disable Style/Documentation
    def parse
      {
        name: extract_by_label('Nome do cliente', 'Nome'),
        email: extract_by_label('E-mail', 'E-mail'),
        phone: extract_by_label('Telefone', 'Telefone'),
        product_code: @body.match(/c[oó]digo\s*(?:do\s*)?produto\s*[:-]?\s*(\w+)/i) && ::Regexp.last_match(1),
        subject: @mail.subject
      }
    end
  end
end
