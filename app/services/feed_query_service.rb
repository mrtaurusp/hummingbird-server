class FeedQueryService
  attr_reader :params, :user

  def initialize(params, user)
    @params = params
    @user = user
  end

  def list
    return @list if @list
    list = feed.activities
    list = list.page(id_lt: cursor) if cursor
    list = list.limit(limit) if limit
    list = list.where_id(*id_query) if id_query
    list = list.mark(mark) if mark
    list = list.sfw if sfw_filter?
    list = list.blocking(blocked)
    @list = list
  end

  def feed
    @feed ||= Feed.new(params[:group], params[:id])
  end

  private

  delegate :sfw_filter?, to: :user, allow_nil: true

  def cursor
    params.dig(:page, :cursor)
  end

  def limit
    params.dig(:page, :limit).to_i
  end

  def mark
    params[:mark]
  end

  def id_query
    return unless params.dig(:filter, :id).is_a? Hash
    operator, id = params.dig(:filter, :id).to_a.flatten
    [operator.to_sym, id]
  end

  def blocked
    Block.hidden_for(user)
  end
end
