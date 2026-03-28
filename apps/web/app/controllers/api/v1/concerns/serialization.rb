module Api
  module V1
    module Concerns
      module Serialization
        private

        def serialize_user(user, include_private: false)
          payload = {
            id: user.id,
            username: user.username,
            bio: user.bio,
            role: user.role,
            posts_count: user.posts_count,
            account_state: user.account_state,
            created_at: user.created_at
          }

          if include_private
            payload.merge!(
              email: user.email,
              email_verified: user.email_verified?,
              digest_frequency: user.digest_frequency,
              notify_on_comments: user.notify_on_comments,
              notify_on_replies: user.notify_on_replies,
              notify_on_invites: user.notify_on_invites,
              notify_on_moderation: user.notify_on_moderation,
              unread_notifications_count: user.unread_notifications_count,
              available_invites_count: user.available_invites_count,
              invite_unlocks_at: user.invite_unlocks_at
            )
          end

          payload
        end

        def serialize_tag(tag)
          {
            id: tag.id,
            name: tag.name,
            slug: tag.slug,
            description: tag.description,
            posts_count: tag.posts_count
          }
        end

        def serialize_comment(comment, current_user: nil)
          {
            id: comment.id,
            body: comment.body,
            edited_at: comment.edited_at,
            hidden_at: comment.hidden_at,
            hidden_reason: comment.hidden_reason,
            created_at: comment.created_at,
            updated_at: comment.updated_at,
            replies_count: comment.replies_count,
            parent_id: comment.parent_id,
            can_edit: current_user.present? && comment.editable_by?(current_user),
            user: serialize_user(comment.user),
            replies: comment.replies.map { |reply| serialize_comment(reply, current_user:) }
          }
        end

        def serialize_post(post, current_user: nil, include_comments: false)
          payload = {
            id: post.id,
            title: post.title,
            url: post.url,
            body: post.body,
            score: post.score,
            votes_count: post.votes_count,
            comments_count: post.comments_count,
            edited_at: post.edited_at,
            hidden_at: post.hidden_at,
            hidden_reason: post.hidden_reason,
            thumbnail_url: post.thumbnail_url,
            thumbnail_fetched_at: post.thumbnail_fetched_at,
            created_at: post.created_at,
            updated_at: post.updated_at,
            display_host: post.display_host,
            link_post: post.link_post?,
            current_user_vote: post.score_for(current_user),
            can_edit: current_user.present? && post.editable_by?(current_user),
            user: serialize_user(post.user),
            tags: post.tags.map { |tag| serialize_tag(tag) }
          }

          payload[:comments] = post.all_comments.visible.root_level.includes(:user, replies: :user).chronological.map do |comment|
            serialize_comment(comment, current_user:)
          end if include_comments

          payload
        end

        def serialize_notification(notification)
          {
            id: notification.id,
            kind: notification.kind,
            message: notification.message,
            read_at: notification.read_at,
            created_at: notification.created_at,
            actor: notification.actor.present? ? serialize_user(notification.actor) : nil,
            record_type: notification.record_type,
            record_id: notification.record_id
          }
        end
      end
    end
  end
end
