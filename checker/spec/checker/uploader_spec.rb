require "webmock"
require "webmock/rspec"

RSpec.describe Checker::Uploader do
  describe "#upload" do
    context "with a valid ResultSet" do
      before do
        stub_request(:post, "https://launchlist.com/api/check_lists").to_return(status: 200)
      end

      it "converts to JSON and hits the default endpoint" do
        config = Checker::Config.new("spec/fixtures/upload_test.yaml")
        config.parse
        results = [config]
        result_set = Checker::ResultSet.new("abcdef", 1, results)
        uploader = Checker::Uploader.new(result_set)
        expect(uploader.upload).to eq true
        expect(WebMock).to have_requested(:post, "https://launchlist.com/api/check_lists")
          .once
          .with(body: hash_including({
            token: "abcdef",
            results: [
              {
                "path" => "spec/fixtures/upload_test.yaml",
                "config" => {
                  "name" => "Test On Myself",
                  "version" => 1,
                  "triggers" => {
                    "paths" => ["checker/lib/checker/**/*.rb"]},
                    "list" => [
                      {
                        "category" => nil,
                        "checks" => [
                          {
                            "check" => "I fire for everything",
                            "triggers" => {"paths" => nil}
                          }
                        ],
                        "triggers" => {"paths" => nil}
                      },
                      {
                        "category" => "General",
                        "checks" => [
                          {
                            "check" => "I dont fire at all",
                            "triggers" => {"paths" => ["gobbledegook.rb"]}
                          }
                        ],
                        "triggers" => {"paths" => ["checker/lib/checker/{c,d}*.rb"]}
                      }
                    ]
                  },
                  "errors" => []
                }
              ]
            }
          ))
      end
    end
  end
end
