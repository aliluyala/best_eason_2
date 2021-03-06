class Manage::Shop::FundingsController < Manage::PatternsController
  before_action :get_ticket_categories, only: [:new, :edit]

  def index
    render text: '', layout: true and return if controller_name.match(/application/)
    if ((params["where"] || {})["title"] || {})["like"].present?
      query = []
      limit = (params[:per_page] || 15).to_i
      offset = ((params[:page] || 1).to_i - 1) * limit
      query_option = {where: {active: true, shop_type: "Shop::Funding"}, fields: [:title], limit: limit, offset: offset, page: params[:page] || 1}
      query_option[:where] = query_option[:where].merge({shop_id: params[:where][:id]}) if (params["where"] || {})[:id].present?
      query_option[:where] = query_option[:where].merge({user_id: params[:where][:user_id]}) if (params["where"] || {})[:user_id].present?
      query << params[:where][:title][:like] if ((params["where"] || {})["title"] || {})["like"].present?
      created_at_query = {}
      created_at_query.merge!({gte: params[:where][:created_at][">="].to_time}) if ((params["where"] || {})[:created_at] || {})[">="].present?
      created_at_query.merge!({lte: params[:where][:created_at]["<="].to_time}) if ((params["where"] || {})[:created_at] || {})["<="].present?
      query_option[:where] = query_option[:where].merge({created_time: created_at_query}) if created_at_query.present?
      order_option = params[:order].present? ? params[:order].split(" ") : ["id", "desc"]
      query_option[:order] = Hash[order_option[0] == 'id' ? 'created_time' : order_option[0], order_option[1]] if order_option.present?
      query << query_option
      @records = Shop::Task.search(*query)
      @tasks = model.where(id: @records.map(&:shop_id)).includes(:ticket_types, :shop_task)
      @tasks = @tasks.order(params[:order] || "id desc") if order_option.present?
    else
      @records = @tasks = model.default(params).includes(:ticket_types, :shop_task)
    end
  end

  private
  def get_ticket_categories
    @categories = ::Shop::PriceCategory.active
  end
end
