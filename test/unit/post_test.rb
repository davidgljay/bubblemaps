require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "it should import from a csv" do
    url = 'http://s3.amazonaws.com/dj-projects/lilstack.csv'
    Post.csv_import(url, 'test')
    assert Tag.find_by_name('linux')
  end

  test "it should import from an XML feed" do
    #write this test later when I have a good example
    #Maybe snapshot the NYT?
  end

  test "it should import from a twitter feed" do
    Post.twitter_import('whedon')
    assert Tag.find_by_name('whedon')
  end

  test "it should bulk extract tags" do
    Post.bulk_extract_tags(Post.all)
    assert Tag.find_by_name('yellow')
    assert Tag.find_by_name('blue')
    assert Tag.find_by_name('green')
  end

  test "it should determine the most recent post" do
    assert Post.mostrecent('test') > Time.now - 5.minutes

  end

end
