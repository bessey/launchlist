RSpec.describe Checker::Differ do
  describe "#modified_paths" do
    it "lists all modified paths" do
      differ = Checker::Differ.new(
        Dir.pwd + "/..",
        "e0b1b50d4ca5636a97a5714bfb9f1618ca7a3746",
        "26c2d0190483e9ba1795dd779bfb110593c18342"
      )
      expect(differ.modified_paths).to contain_exactly(
        "checker/checker.gemspec",
        "checker/Gemfile.lock",
        "checker/lib/checker/config.rb",
        "checker/lib/checker/differ.rb",
        "checker/lib/checker/schema.rb",
        "checker/spec/checker/config_spec.rb",
        "checker/spec/checker/differ_spec.rb",
        "checker/spec/checker/schema_spec.rb",
      )
    end
  end
end
