class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
    def js_authenticate_user!
        render js: "location.href='/users/sign_in';" unless user_signed_in? # 로그인 되지않은 상태로 좋아요를 누르면 /users/sign_in으로 redirection.
    end  
end
