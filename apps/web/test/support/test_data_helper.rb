module TestDataHelper
  DEFAULT_PASSWORD = 'password123!'.freeze

  def default_password
    DEFAULT_PASSWORD
  end

  def unique_token(prefix)
    @unique_counter ||= 0
    @unique_counter += 1
    "#{prefix}_#{@unique_counter}"
  end

  def create_bootstrap_admin
    User.find_by(email: 'bootstrap@example.com') || begin
      admin = User.create!(
        username: 'bootstrap_admin',
        email: 'bootstrap@example.com',
        password: default_password,
        password_confirmation: default_password,
        bio: 'Bootstrap admin',
        email_verified_at: Time.current
      )
      admin.update_columns(created_at: 90.days.ago, updated_at: 90.days.ago)
      admin
    end
  end

  def create_user(role: :member, verified: true, created_at: 45.days.ago, account_state: :active, suspended_until: nil, ensure_admin: true, **attrs)
    create_bootstrap_admin if ensure_admin && User.count.zero? && role.to_s != 'admin'

    sequence = unique_token('user')
    user = User.new(
      {
        username: attrs.delete(:username) || sequence,
        email: attrs.delete(:email) || "#{sequence}@example.com",
        password: attrs.delete(:password) || default_password,
        password_confirmation: attrs.delete(:password_confirmation) || default_password,
        bio: attrs.delete(:bio) || 'Conta de teste',
        email_verified_at: verified ? Time.current : nil,
        account_state: account_state,
        suspended_until: suspended_until
      }.merge(attrs)
    )
    user.role = role
    user.save!
    user.update_columns(created_at: created_at, updated_at: created_at) if created_at.present?
    user
  end

  def create_post(user:, title: nil, body: 'Contexto de teste para a comunidade.', url: nil, tag_names: 'rails,infra')
    post = user.posts.build(
      title: title || "Post #{unique_token('title')}",
      body: body,
      url: url
    )
    post.assign_tag_names(tag_names)
    post.save!
    post
  end

  def sign_in_as(user, password: default_password)
    post session_path, params: { session: { email: user.email, password: password } }
  end

  def auth_headers(token)
    {
      'Authorization' => "Bearer #{token}",
      'Accept' => 'application/json'
    }
  end
end
