RSpec.describe "Checker::Schema" do
  it "is a valid JSON schema" do
    validation = JSON::Validator.fully_validate_schema(Checker::Schema)
    expect(validation).to be_empty
  end
end
