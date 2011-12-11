require File.expand_path('../test_helper', __FILE__)

describe Enumerable do
  it "should have defer method" do
    ary = []
    ary.should respond_to(:defer)
  end

  it "should return DeferredEnumerable" do
    [].defer.should be_a(DeferredEnumerable)
  end
end