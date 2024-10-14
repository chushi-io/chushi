# frozen_string_literal: true

module UnauthenticatedCheck
  def verify_unauthenticated(method, path)
    case method
    when 'get'
      get path
    when 'patch'
      patch path
    when 'put'
      put path
    when 'post'
      post path
    when 'delete'
      delete path
    else
      raise ArgumentError
    end
    expect(response).to have_http_status :forbidden
  end
end
