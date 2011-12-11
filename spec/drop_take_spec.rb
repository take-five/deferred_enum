require File.expand_path('../test_helper', __FILE__)

describe DeferredEnumerator do
  it "should drop elements from collections" do
    [1, 2, 3, 4, 3].defer.drop(3).to_a.should == [4, 3]

    [1, 2, 3, 4, 3].defer.drop_while {|n| n <= 3 }.to_a.should == [4, 3]
  end

  it "should take first elements from collections" do
    [4, 3, 2, 1, 4].defer.take(3).to_a.should == [4, 3, 2]

    [4, 3, 2, 1, 4].defer.take_while { |n| n > 1 }.to_a.should == [4, 3, 2]
  end
end