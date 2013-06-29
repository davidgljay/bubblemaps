require 'spec_helper'

describe TagsController do

  describe "GET 'list_posts'" do
    it "returns js success" do
      Post.bulk_extract_tags(Post.all)
      get 'list_posts', {'source' => 'test', 'name' => 'blue'}
      @posts.count.should == 3
      @source_type.should == 'test'
      @tag.should == Tag.find_by_name('blue')

    end
  end

end
