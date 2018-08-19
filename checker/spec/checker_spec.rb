RSpec.describe Checker do
  it "has a version number" do
    expect(Checker::VERSION).not_to be nil
  end

  describe "#call" do
    before do
      stub_request(:post, "https://launchlist.com/api/check_lists").to_return(status: 200)
    end
    it "returns true" do
      expect(Checker.run(
        "e0b1b50d4ca5636a97a5714bfb9f1618ca7a3746",
        "26c2d0190483e9ba1795dd779bfb110593c18342",
        lists: "../lists/**/*.{yaml,yml}",
        token: "deadbeef"
      )).to be true
    end
  end
end
