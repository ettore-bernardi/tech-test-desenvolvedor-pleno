# frozen_string_literal: true

module Parsers
  class PartnerB < Base
    def parse
      body = @mail.body.decoded
      name = extract_field(body, [ /Nome: (.*)/ ])
      email = extract_field(body, [ /E-mail: (.*)/ ])
      phone = extract_field(body, [ /Telefone: (.*)/ ])

      return nil unless name && email

      {
        name: name,
        email: email,
        phone: phone
      }
    end
  end
end
