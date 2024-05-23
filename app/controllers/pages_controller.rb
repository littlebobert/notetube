class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def index
    raise NoMethodError, "This method is defined just because otherwise we'll error visiting #home we do after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?"
  end
end
