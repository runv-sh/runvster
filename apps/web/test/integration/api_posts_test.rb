require 'test_helper'

class ApiPostsTest < ActionDispatch::IntegrationTest
  test 'api token can create a post' do
    user = create_user(verified: true)
    token = ApiToken.issue!(user: user, name: 'CLI').plain_text_token

    assert_difference('Post.count', 1) do
      post api_v1_posts_path,
        params: { post: { title: 'API post de teste', body: 'Abrindo uma discussao pela API.', tag_names: 'api,rails' } },
        headers: auth_headers(token),
        as: :json
    end

    assert_response :created
    payload = JSON.parse(response.body)
    assert_equal 'API post de teste', payload.dig('post', 'title')
  end

  test 'api blocks posting when verified email is required' do
    CommunitySetting.current.update!(require_email_verification_for_posting: true)
    user = create_user(verified: false)
    token = ApiToken.issue!(user: user, name: 'CLI').plain_text_token

    assert_no_difference('Post.count') do
      post api_v1_posts_path,
        params: { post: { title: 'Post bloqueado', body: 'Nao deve passar.', tag_names: 'api,rails' } },
        headers: auth_headers(token),
        as: :json
    end

    assert_response :forbidden
    payload = JSON.parse(response.body)
    assert_equal 'email_verification_required', payload.dig('error', 'code')
  end
end
