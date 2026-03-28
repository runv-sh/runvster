module ApplicationHelper
  def invitation_signup_url(invitation)
    sign_up_url(invite: invitation.token)
  end

  def feed_params_for(page:)
    request.query_parameters.merge(page:)
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
end
