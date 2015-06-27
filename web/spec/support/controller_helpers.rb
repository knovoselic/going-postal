module ControllerHelpers
  def sign_in_user(user = double('user'))
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  def sign_out_user
    allow(request.env['warden'])
      .to receive(:authenticate!).and_throw(:warden, scope: :user)
    allow(controller).to receive(:current_user).and_return(nil)
  end
end
