module TweetTime
  extend self
  def time_from(id)
    case id
    when Integer
      Time.at(((id >> 22) + 1288834974657) / 1000.0)
    else
      nil
    end
  end
  alias from time_from
end