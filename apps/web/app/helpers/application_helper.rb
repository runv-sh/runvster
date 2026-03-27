module ApplicationHelper
  def invitation_signup_url(invitation)
    sign_up_url(invite: invitation.token)
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
end
