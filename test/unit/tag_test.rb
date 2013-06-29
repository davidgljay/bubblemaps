require 'test_helper'

class TagTest < ActiveSupport::TestCase
   test "it should set the buzz" do
     Post.bulk_extract_tags(Post.all)
     Tag.set_buzz('test')
     assert Tag.find_by_name('blue').heat1 > 950
     assert Tag.find_by_name('red').heat1 < 50
   end

  test "it should set links" do
    Post.bulk_extract_tags(Post.all)
    Tag.set_links('test')
    assert Tag.find_by_name('blue').heat2
    assert Tag.find_by_name('red').heat2g
  end

  test "it should set postcounts" do
    Post.bulk_extract_tags(Post.all)
    Tag.set_postcounts('test')
    assert Tag.find_by_name('blue').postcount == 1
    assert Tag.find_by_name('red').postcount == 4

  end
end
