module ApplicationHelper
  def member_section_nav_items
    [
      { label: "Dashboard", path: dashboard_path },
      { label: "Conta", path: edit_account_path },
      { label: "Inbox", path: notifications_path }
    ]
  end

  def admin_section_nav_items
    items = [
      { label: "Painel", path: dashboard_path },
      { label: "Usuarios", path: admin_users_path },
      { label: "Posts", path: admin_posts_path },
      { label: "Comentarios", path: admin_comments_path },
      { label: "Moderacao", path: admin_moderation_cases_path }
    ]

    if current_user&.admin?
      items << { label: "Convites", path: admin_invitations_path }
      items << { label: "Tags", path: admin_tags_path }
    end

    items
  end

  def invitation_signup_url(invitation)
    sign_up_url(invite: invitation.token)
  end

  def feed_params_for(page:)
    request.query_parameters.merge(page:)
  end

  def rss_feed_params_for(tab: nil)
    request.query_parameters
      .except("page")
      .merge(tab: normalized_rss_tab(tab))
      .compact_blank
  end

  def moderation_action_options_for(reportable)
    case reportable
    when User
      [
        [ "Somente registrar", "none" ],
        [ "Suspender conta", "suspend_user" ],
        [ "Banir conta", "ban_user" ],
        [ "Reativar conta", "reactivate_user" ]
      ]
    else
      [
        [ "Somente registrar", "none" ],
        [ "Ocultar conteudo", "hide_content" ],
        [ "Restaurar conteudo", "restore_content" ]
      ]
    end
  end

  def moderation_subject_label(record)
    case record
    when Post
      "post"
    when Comment
      "comentario"
    when User
      "perfil"
    else
      record.class.name.downcase
    end
  end

  def social_image_url_for(post)
    return if post.thumbnail_url.blank?

    post.thumbnail_url
  end

  def social_description_for(post)
    truncate(post.social_description, length: 220)
  end

  private

  def normalized_rss_tab(tab)
    tab = tab.presence
    return if tab.blank? || tab == "recentes"

    tab
  end
end
