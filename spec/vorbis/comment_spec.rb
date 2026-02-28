# frozen_string_literal: true

RSpec.describe Vorbis::Comment do
  subject(:comment) { described_class.new }

  after { comment.clear }

  describe "#initialize" do
    it "creates a new Comment instance" do
      expect(comment).to be_a(described_class)
    end
  end

  describe "#add_tag" do
    it "adds a tag" do
      comment.add_tag("ARTIST", "Test Artist")
      expect(comment.query("ARTIST")).to eq("Test Artist")
    end
  end

  describe "#query" do
    before do
      comment.add_tag("ARTIST", "First")
      comment.add_tag("ARTIST", "Second")
    end

    it "returns the first tag value by default" do
      expect(comment.query("ARTIST")).to eq("First")
    end

    it "returns the tag value at the specified index" do
      expect(comment.query("ARTIST", 1)).to eq("Second")
    end

    it "returns nil for non-existent tag" do
      expect(comment.query("NONEXISTENT")).to be_nil
    end
  end

  describe "#query_count" do
    it "returns the number of tags with the given name" do
      comment.add_tag("ARTIST", "A")
      comment.add_tag("ARTIST", "B")
      comment.add_tag("TITLE", "T")
      expect(comment.query_count("ARTIST")).to eq(2)
      expect(comment.query_count("TITLE")).to eq(1)
      expect(comment.query_count("GENRE")).to eq(0)
    end
  end

  describe "#vendor" do
    it "returns nil before encoding setup" do
      expect(comment.vendor).to be_nil
    end
  end

  describe "#clear" do
    it "clears the comment" do
      comment.clear
      expect(comment).to be_cleared
    end

    it "is idempotent" do
      comment.clear
      expect { comment.clear }.not_to raise_error
    end
  end
end
