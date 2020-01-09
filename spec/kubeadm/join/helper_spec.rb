require "spec_helper"

describe Kubeadm::Join::Helper do
  it "has a version number" do
    expect(Kubeadm::Join::Helper::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
