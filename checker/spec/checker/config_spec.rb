RSpec.describe Checker::Config do
  it "parses all checklists OK" do
    dir = Dir.new("../lists")
    configs = Checker::Config.parse_all(dir)
    configs.each do |config|
      expect(config.errors).to(
        be_empty,
        "expected no errors for #{config.path}, got #{config.errors.join("\n")}"
      )
      expect(config).to be_valid
    end
  end

  context "exercise with a complex checklist" do
    before(:all) do
      path = Pathname.new("spec/fixtures/rails_mysql.yaml")
      @config = Checker::Config.new(path)
    end
    describe "#parse" do
      subject { @config.parse }
      it { is_expected.to be_truthy }
    end
    describe "#config" do
      # Avoid re-parsing for every test
      before(:all) { @config.parse }
      subject { @config }
      describe "#name" do
        subject { super().name }
        it { is_expected.to eq "Rails MySQL Migration" }
      end
      describe "#version" do
        subject { super().version }
        it { is_expected.to eq 1 }
      end
      describe "#triggers" do
        subject { super().triggers }
        it { is_expected.not_to be_nil }
        describe "#paths" do
          subject { super().paths }
          it { is_expected.to contain_exactly("db/migrations/**/*.rb") }
        end
      end
      describe "#list" do
        subject { super().list }
        describe "first check set in list" do
          subject { super().first }
          describe "#category" do
            subject { super().category }
            it { is_expected.to eq "General" }
          end
          describe "#triggers" do
            subject { super().triggers }
            it { is_expected.not_to be_nil }
            describe "#paths" do
              subject { super().paths }
              it { is_expected.to contain_exactly("one_path", "another_path") }
            end
          end
          describe "#checks" do
            subject { super().checks }
            describe "simple check" do
              subject { super()[0] }
              describe "#check" do
                subject { super().check }
                it { is_expected.to eq "Migrations are reversible" }
              end
            end
            describe "complex check" do
              subject { super()[1] }
              describe "#check" do
                subject { super().check }
                it { is_expected.to eq "Arguments / Input Objects prefer strong types" }
              end
              describe "#triggers" do
                subject { super().triggers }
                it { is_expected.not_to be_nil }
                describe "#paths" do
                  subject { super().paths }
                  it { is_expected.to contain_exactly("argument", "input_field") }
                end
              end
            end
          end
        end
      end
    end
  end
end
