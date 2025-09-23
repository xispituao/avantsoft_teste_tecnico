module PaginationHelper
  extend ActiveSupport::Concern

  # Configurações padrão de paginação
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 100

  # Extrai e valida parâmetros de paginação
  def pagination_params
    page = (params[:page] || DEFAULT_PAGE).to_i
    per_page = (params[:per_page] || DEFAULT_PER_PAGE).to_i
    
    # Validações de segurança
    page = [page, 1].max
    per_page = [per_page, MAX_PER_PAGE].min
    per_page = [per_page, 1].max
    
    { page: page, per_page: per_page }
  end

  # Aplica paginação a uma query
  def paginate_query(query)
    pagination = pagination_params
    query.page(pagination[:page]).per(pagination[:per_page])
  end

  # Gera metadados de paginação padronizados
  def pagination_metadata(paginated_collection)
    {
      current_page: paginated_collection.current_page,
      per_page: paginated_collection.limit_value,
      total_pages: paginated_collection.total_pages,
      total_count: paginated_collection.total_count,
      has_next_page: paginated_collection.next_page.present?,
      has_prev_page: paginated_collection.prev_page.present?
    }
  end

  # Renderiza resposta paginada padronizada
  def render_paginated_response(paginated_collection, serializer_class, status: :ok)
    render json: {
      data: ActiveModelSerializers::SerializableResource.new(
        paginated_collection, 
        each_serializer: serializer_class
      ).as_json,
      pagination: pagination_metadata(paginated_collection)
    }, status: status
  end
end
