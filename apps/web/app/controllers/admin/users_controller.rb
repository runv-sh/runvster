module Admin
  class UsersController < ApplicationController
    before_action :require_staff!
    before_action :require_admin!, only: :destroy

    def index
      @users = User.order(created_at: :desc)
    end

    def update
      user = find_user
      previous_role = user.role
      previous_state = user.account_state
      next_role = user_params[:role].to_s

      if current_user.moderator? && user.admin?
        return redirect_to admin_users_path, alert: "Moderadores nao podem alterar contas administrativas."
      end

      if current_user.admin? && previous_role == "admin" && next_role.present? && next_role != "admin" && User.admin.count == 1
        return redirect_to admin_users_path, alert: "Nao e possivel remover o ultimo administrador da plataforma."
      end

      if user.update(user_params)
        Notification.notify_account_state_changed!(user, actor: current_user) if user.saved_change_to_account_state?
        AdminAction.create!(
          admin: current_user,
          action_type: "user_updated",
          target_type: "User",
          target_id: user.id,
          details: "Usuario editado. Role: #{previous_role} -> #{user.role}. Estado: #{previous_state} -> #{user.account_state}."
        )
        redirect_to admin_users_path, notice: "Permissao de @#{user.username} atualizada."
      else
        redirect_to admin_users_path, alert: user.errors.full_messages.to_sentence
      end
    end

    def destroy
      user = find_user

      if user == current_user
        return redirect_to admin_users_path, alert: "Nao e possivel excluir a propria conta por este painel."
      end

      if user.admin? && User.admin.count == 1
        return redirect_to admin_users_path, alert: "Nao e possivel excluir o ultimo administrador da plataforma."
      end

      username = user.username
      user.destroy!

      AdminAction.create!(
        admin: current_user,
        action_type: "user_deleted",
        target_type: "User",
        target_id: user.id,
        details: "Conta @#{username} excluida."
      )
      redirect_to admin_users_path, notice: "Usuario excluido."
    end

    private

    def user_params
      if current_user.admin?
        params.expect(user: [ :username, :email, :bio, :role, :account_state, :moderation_note, :suspended_until ])
      else
        params.expect(user: [ :account_state, :moderation_note, :suspended_until ])
      end
    end

    def find_user
      User.find_by(id: params[:id]) || User.find_by!(username: params[:id].to_s.downcase)
    end
  end
end
