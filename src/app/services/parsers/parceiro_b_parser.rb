# frozen_string_literal: true

module Parsers
  class ParceiroBParser < ParserBase
    def parse
      {
        name: extract_by_label('Cliente', 'Nome do interessado', 'Nome'),
        email: extract_by_label('Contato', 'Email', 'E-mail')&.to_s&.split(/[|\s]/)&.first,
        phone: extract_by_label('Contato', 'Telefone')&.to_s,
        product_code: (@body.match(/Produto\s*[:-]?\s*(\w+)/i) && ::Regexp.last_match(1)) || @mail.subject[/\b([A-Z0-9]{3,})\b/],
        subject: @mail.subject
      }
    end
  end
end
