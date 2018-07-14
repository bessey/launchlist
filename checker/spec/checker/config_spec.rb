RSpec.describe Checker::Config do
  it "parses all checklists OK" do
    dir = Dir.new(Dir.pwd + "/../lists")
    configs = Checker::Config.parse_all(dir)
    configs.each do |config|
      expect(config.errors).to(
        be_empty,
        "expected no errors for #{config.path}, got #{config.errors.join("\n")}"
      )
      expect(config).to be_valid
    end
  end
end
