require 'spec_helper'

describe Article do

  before(:each) do
    User.all.map(&:destroy)
    Article.all.map(&:destroy)
    @u = User.create!(
      :username => 'brady'
    )
    PaperTrail.whodunnit = @u.id
    @c = Chapter.create!(
      :title => 'Chapter 1'
    )
  end

  it "should have word_size and line_size of 0 with a nil body" do
    a = Article.create!(
      :title => 'Article 1',
      :chapter_id => @c.id
    )
    assert_equal a.contributions.first.word_size, 0
    assert_equal a.contributions.first.line_size, 0
  end

  it "should have word_size and line_size to match body" do
    a = Article.create!(
      :title => 'Article 1',
      :chapter_id => @c.id,
      :body => 'This is one line.'
    )
    assert_equal a.contribution_counts.select{ |c| c.user == @u }.first.word_count, 4
    assert_equal a.contribution_counts.select{ |c| c.user == @u }.first.line_count, 1
  end

  it "should have word_size and line_size to match body on update with same user" do
    a = Article.create!(
      :title => 'Article 1',
      :chapter_id => @c.id,
      :body => 'This is one line.'
    )
    a.body = "This is one line.\nThis is a second line."
    a.save
    assert_equal a.contribution_counts.select{ |c| c.user == @u }.first.word_count, 5
    assert_equal a.contribution_counts.select{ |c| c.user == @u }.first.line_count, 1
    assert_equal a.contribution_counts.select{ |c| c.user == @u }.map(&:word_count).reduce(0, :+), 9
    assert_equal a.contribution_counts.select{ |c| c.user == @u }.map(&:line_count).reduce(0, :+), 2
  end

end
