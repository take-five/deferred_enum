require File.expand_path('../test_helper', __FILE__)

describe DeferredEnumerator do
  it "should zip collections" do
    seq1 = [2, 3, 4]
    seq2 = [3, 4]

    [1, 2, 3].defer.zip(seq1, seq2).to_a.should == [[1, 2, 3], [2, 3, 4], [3, 4, nil]]
  end
end