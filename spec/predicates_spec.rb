require File.expand_path('../test_helper', __FILE__)

describe DeferredEnumerator do
  it "should lazily execute all? method" do
    counts = 0

    [2, 3, 4].all? { |e| counts += 1; e.even? }.should == false
    counts.should == 2
  end

  it "should lazily execute any? method" do
    counts = 0

    [2, 3, 4].any? { |e| counts += 1; e.odd? }.should == true
    counts.should == 2
  end

  it "should lazily execute none? method" do
    counts = 0

    [2, 3, 4].none? { |e| counts += 1; e.odd? }.should == false
    counts.should == 2
  end
end