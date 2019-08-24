require "./src/propiary"

struct User
  include Propiary

  property! name : String
  property age : Int32

  def initialize(@name, @age)
  end
end

struct Post
  include Propiary
  getter title : String?
  property posted_at : Time?
end


pp User::Prop_Types
pp Post::Prop_Types

pp User.new("jon", 23).name
