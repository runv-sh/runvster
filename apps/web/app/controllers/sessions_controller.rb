class SessionsController < ApplicationController
  def new
    redirect_to root_path, notice: "Voce ja esta conectade." if authenticated?
  end

  def create
    user = User.find_by(email: session_params[:email].to_s.strip.downcase)

    if user&.authenticate(session_params[:password])
      start_session_for(user)
      redirect_to root_path, notice: "Bem-vinde de volta."
    else
      flash.now[:alert] = "Email ou senha invalidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    end_session
    redirect_to root_path, notice: "Sessao encerrada."
  end

  private

  def session_params
    params.expect(session: %i[email password])
  end
end
