class UserSerializer < ActiveModel::Serializer

  attributes :id, :username, :line_count, :word_count, :article_count

end
