class User < ActiveRecord::Base

  validates :email, uniqueness: true

  has_many :reviews
  has_many :suggestions

  # uni direction relationship
  has_and_belongs_to_many(
    :users,
    join_table: "user_connections",
    foreign_key: "user_a_id",
    association_foreign_key: "user_b_id")

  # we can assess friends on user object
  alias_attribute :friends, :users

  def to_s
    puts "[User] email: #{self.email}"
  end

end
