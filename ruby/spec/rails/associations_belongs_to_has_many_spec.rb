require "active_record"
require "logger"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  #
  # Note tables are created using the plural name of the model.
  #
  create_table :books, force: true do |t|
    t.belongs_to :author, foreign_key: true
  end

  create_table :authors, force: true do |t|
    # note there's no foreign key created here.
  end
end

class Author < ActiveRecord::Base
  has_many :books # note pluralization.
end

class Book < ActiveRecord::Base
  belongs_to :author # note it's in singular.
end

RSpec.describe "ActiveRecord associations" do
  describe Book do
    context "with belongs_to association" do

      #
      # belongs_to:
      # 1. Creates author_id in table book.
      # 2. The name of the model must be in singular form. Rails infers class name from this.
      # 3. If used alone produces a one-directional one-to-one connection.
      #

      let(:book) { Book.create!(author_id: Author.create!.id) }

      it "should contain an author_id" do
        expect(book).to respond_to(:author_id)
      end

      it "should be related to Author" do
        expect(book.author.class).to be Author
      end

      context "inside Author" do
        it "should not have book_id" do
          expect(book.author).to_not respond_to(:book_id)
        end
      end
    end
  end

  describe Author do
    context "with has_many association" do

      #
      # has_many:
      # 1. Does NOT create a book_id in table author.
      # 2. Often created on the "other side" of a belongs_to.
      # 3. Indicates that each instance of this model has zero or more instances of the other model.
      # 4. The name of the other model must be pluralized.
      #

      let(:author) { Author.create!(books: [Book.create!, Book.create!]) }

      it "should not have a book_id" do
        expect(author).to_not respond_to(:book_id)
      end

      it "should have books" do
        expect(author).to respond_to(:books)
      end

      it "should be associated to books" do
        author_ids = author.books.map { _1.author_id }
        expect(author_ids).to all eq(author.id)
      end
    end
  end
end