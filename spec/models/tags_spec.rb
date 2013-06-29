require 'spec_helper'

describe "Tags" do

  it "it should set the buzz" do
    Post.bulk_extract_tags(Post.all)
    Tag.find_by_name('blue').heat1.should > 950
    Tag.find_by_name('red').heat1.should < 50
  end

  it "it should set links" do
    Post.bulk_extract_tags(Post.all)
    Tag.find_by_name('blue').heat2.should be
    Tag.find_by_name('red').heat2.should be
  end

  it "it should set postcounts" do
    Post.bulk_extract_tags(Post.all)
    Tag.find_by_name('blue').postcount.should == 1
    Tag.find_by_name('red').postcount.should == 4

  end
end