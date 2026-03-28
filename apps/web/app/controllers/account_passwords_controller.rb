class AccountPasswordsController < ApplicationController
  before_action :require_authentication!

  def edit
  end

  def update
    unless current_user.authenticate(password_params[:current_password])
      flash.now[:alert] = "Senha atual invalida."
      return render :edit, status: :unprocessable_entity
    end

    if current_user.update(password: password_params[:password], password_confirmation: password_params[:password_confirmation])
      redirect_to edit_account_path, notice: "Senha atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.expect(user: %i[current_password password password_confirmation])
  end
end
