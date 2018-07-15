RSpec.describe Checker::ActiveCheckBuilder do
  describe "#build" do
    before do
      # For reference, this diff contains the following files:
      # checker/Gemfile.lock
      # checker/checker.gemspec
      # checker/lib/checker/config.rb
      # checker/lib/checker/differ.rb
      # checker/lib/checker/schema.rb
      # checker/spec/checker/config_spec.rb
      # checker/spec/checker/differ_spec.rb
      # checker/spec/checker/schema_spec.rb
      differ = Checker::Differ.new(
        Dir.pwd + "/..",
        "e0b1b50d4ca5636a97a5714bfb9f1618ca7a3746",
        "26c2d0190483e9ba1795dd779bfb110593c18342"
      )
      config = Checker::Config.new("spec/fixtures/self_test.yaml")
      config.parse
      builder = Checker::ActiveCheckBuilder.new(config, differ)
      @checklist = builder.build
    end

    it "filters the checklist to only include checks triggered by modified paths" do
      expect(@checklist.list).not_to be_empty
      expect(@checklist.list.first.checks).not_to be_empty

      first_check_list = @checklist.list[0].checks
      expect(first_check_list.length).to eq(1)
      expect(first_check_list[0].check).to eq("I fire for everything")

      second_check_list = @checklist.list[1].checks
      expect(second_check_list.length).to eq(2)
      expect(second_check_list[0].check).to eq("I fire for config and differ")
      expect(second_check_list[1].check).to eq("I fire for only differ")
      # Removed the unfired one
    end

    it "filters the triggers to only include ones that fired for modified paths" do
      expect(@checklist.triggers.paths).not_to be_empty
      expect(@checklist.triggers.paths).to contain_exactly("checker/lib/checker/config.rb", "checker/lib/checker/differ.rb", "checker/lib/checker/schema.rb")
      first_check_list = @checklist.list[0]
      expect(first_check_list.triggers.paths).to be_nil

      second_check_list = @checklist.list[1]
      expect(second_check_list.triggers.paths).to contain_exactly("checker/lib/checker/config.rb", "checker/lib/checker/differ.rb")
      super_filtered_check = second_check_list.checks[1]
      expect(super_filtered_check.triggers.paths).to contain_exactly("checker/lib/checker/differ.rb")
    end
  end
end
