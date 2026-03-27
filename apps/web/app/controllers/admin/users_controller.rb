module Admin
  class UsersController < ApplicationController
    before_action :require_admin!

    def index
      @users = User.order(created_at: :desc)
    end

    def update
      user = User.find(params[:id])
      previous_role = user.role
      next_role = user_params[:role].to_s

      if previous_role == "admin" && next_role != "admin" && User.admin.count == 1
        return redirect_to admin_users_path, alert: "Nao e possivel remover o ultimo administrador da plataforma."
      end

      if user.update(user_params)
        AdminAction.create!(
          admin: current_user,
          action_type: "user_role_updated",
          target_type: "User",
          target_id: user.id,
          details: "Usuario editado. Role alterada de #{previous_role} para #{user.role}."
        )
        redirect_to admin_users_path, notice: "Permissao de @#{user.username} atualizada."
      else
        redirect_to admin_users_path, alert: user.errors.full_messages.to_sentence
      end
    end

    def destroy
      user = User.find(params[:id])

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
      params.expect(user: [ :username, :email, :bio, :role ])
    end
  end
end
