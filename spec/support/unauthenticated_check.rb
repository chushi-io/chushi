# frozen_string_literal: true

module UnauthenticatedCheck
  def verify_unauthenticated(method, path)
    send_request(method, path)
    expect(response).to have_http_status :forbidden
  end

  def verify_not_found(method, path)
    send_request(method, path)
    expect(response).to have_http_status :not_found
  end

  private

  def send_request(method, path)
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
  end
end
