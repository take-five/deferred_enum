require File.expand_path('../test_helper', __FILE__)

describe DeferredEnumerator do
  it "should map collections" do
    [1, 2, 3].defer.map { |i| i + 1 }.to_a.should == [2, 3, 4]
  end

  it "should filter collections" do
    [1, 2, 3].defer.select { |i| i.odd? }.to_a.should == [1, 3]
  end

  it "should reject elements from collections" do
    [1, 2, 3].defer.reject { |i| i.odd? }.to_a.should == [2]
  end

  it "should flatten collections" do
    [[1, 2], 3, [4]].defer.flatten.to_a.should == [1, 2, 3, 4]

    [[1, [2]], 3].defer.flatten(1).to_a.should == [1, [2], 3]
  end

  it "should flat and map collections" do
    [[1, 2], 3, [4]].defer.flat_map { |i| i + 1 }.to_a.should == [2, 3, 4, 5]
  end

  it "should cycle collections" do
    [1].defer.cycle(2).to_a.should == [1, 1]

    counts = 0
    [1].defer.cycle { counts += 1; break if counts == 10 }
    counts.should == 10
  end

  it "should grep collections" do
    ['abc', 'def', 'ghi'].defer.grep(/abc/).to_a.should == ['abc']
  end

  it "should compact collections" do
    [1, 2, nil].defer.compact.to_a.should == [1, 2]
  end

  it "should chain collections" do
    [1, 2].defer.chain([3], [], [4]).to_a.should == [1, 2, 3, 4]
  end

  it "should remove duplicates from collections" do
    [1, 2, 3, 4, 3, 4].defer.uniq.to_a.should == [1, 2, 3, 4]

    [1, 2, 3, 4].defer.uniq { |n| n.even? }.to_a.should == [1, 2]
  end
end