RSpec.shared_examples 'invalid with overlap error' do
  it 'is invalid and has overlap error' do
    expect(subject).not_to be_valid
    expect(subject.errors[:base]).to include(I18n.t('activerecord.errors.models.frame.attributes.base.no_overlap'))
  end
end

RSpec.shared_examples 'valid frame' do
  it 'is valid' do
    expect(subject).to be_valid
  end
end
