require "rails_helper"

RSpec.describe Webhooks::UrlGuard do
  def stub_dns(host, ip)
    allow(Resolv).to receive(:getaddress).with(host).and_return(ip)
  end

  it "accepts a public https url and returns the pinned ip" do
    stub_dns("hooks.example.com", "93.184.216.34")
    r = described_class.check("https://hooks.example.com/wh")
    expect(r).to be_ok
    expect(r.ip).to eq("93.184.216.34")
  end

  [
    ["http://10.0.0.5/x", "10.0.0.5"],
    ["http://192.168.1.9/x", "192.168.1.9"],
    ["http://172.16.3.2/x", "172.16.3.2"],
    ["http://169.254.169.254/meta", "169.254.169.254"],
  ].each do |url, ip|
    it "rejects private/reserved address #{ip}" do
      stub_dns(URI(url).host, ip)
      expect(described_class.check(url)).not_to be_ok
    end
  end

  it "rejects non-http schemes" do
    expect(described_class.check("ftp://example.com/x")).not_to be_ok
  end

  it "rejects unresolvable hosts" do
    allow(Resolv).to receive(:getaddress).and_raise(Resolv::ResolvError)
    expect(described_class.check("https://nope.invalid/x")).not_to be_ok
  end

  it "allows localhost outside production (dev-mode carve-out)" do
    stub_dns("localhost", "127.0.0.1")
    allow(Rails.env).to receive(:production?).and_return(false)
    r = described_class.check("http://localhost/x")
    expect(r).to be_ok
    expect(r.ip).to eq("127.0.0.1")
  end

  it "rejects localhost in production" do
    stub_dns("localhost", "127.0.0.1")
    allow(Rails.env).to receive(:production?).and_return(true)
    expect(described_class.check("http://localhost/x")).not_to be_ok
  end
end
