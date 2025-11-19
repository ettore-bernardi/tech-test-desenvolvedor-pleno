require 'rails_helper'

RSpec.describe ProcessingLog, type: :model do
  it "is valid with valid attributes" do
    processing_log = build(:processing_log)
    expect(processing_log).to be_valid
  end

  it "can have a file attached" do
    processing_log = create(:processing_log)
    processing_log.raw_file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'email.eml')), filename: 'email.eml', content_type: 'message/rfc822')
    expect(processing_log.raw_file).to be_attached
  end
end
