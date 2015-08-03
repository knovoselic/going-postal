class CustomDeviseFailure < Devise::FailureApp
  def respond
    if request.format == :html
      super
    else
      self.status = 401
    end
  end
end
