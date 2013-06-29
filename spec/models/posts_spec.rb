require 'spec_helper'

describe "Posts" do
  it "should import a CSV" do
    url = 'https://s3.amazonaws.com/dj-projects/lilstack.csv'
    csv = CSV.new(open(url).read, :headers => true)
    csv.count.should > 90
    Post.csv_import(url, 'csv_test')
    Post.count.should > 5
    Post.where("date < '#{Date.new(2013,4,10)}'").count.should > 90
    Tag.find_by_name('linux').should be
  end

  it "should import from twitter" do
    Post.twitter_import('whedon')
    Post.last.text.downcase.include?('whedon').should be_true
    Tag.find_by_name('whedon').should be
  end

  it "should bulk extract tags" do
    Post.bulk_extract_tags(Post.all)
    Tag.find_by_name('yellow').should be
    Tag.find_by_name('blue').should be
    Tag.find_by_name('green').should be
  end

  it "should determine the most recent post" do
    Post.mostrecent('test').should > Time.now - 1.day
  end
end