class EmailParserService < Parsers::Base
  def parse
    {
      name: extract_name,
      email: extract_email,
      phone: extract_phone,
      product_code: extract_product_code
    }
  end

  private

  def extract_name
    extract_field(@mail.body.decoded, [
      /Nome do cliente: (.*)/,
      /Nome: (.*)/
    ])
  end

  def extract_email
    extract_field(@mail.body.decoded, [
      /E-mail: (.*)/,
      /Email: (.*)/
    ])
  end

  def extract_phone
    extract_field(@mail.body.decoded, [
      /Telefone: (.*)/,
      /Telefone: (\d{2} \d{5}-\d{4})/
    ])
  end

  def extract_product_code
    extract_field(@mail.subject, [
      /Produto (.*)/,
      /Interesse no produto (.*)/
    ])
  end
end
