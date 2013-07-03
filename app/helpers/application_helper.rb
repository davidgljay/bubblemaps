module ApplicationHelper

  #Generate a title on a per-page basis
  def title
    base_title = "Bubblmaps"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

end
