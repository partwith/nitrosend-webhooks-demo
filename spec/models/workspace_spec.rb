require "rails_helper"

RSpec.describe Workspace do
  it "generates a token on create" do
    w = Workspace.create!
    expect(w.token).to match(/\Aws_[a-z0-9]{24}\z/)
  end
end
