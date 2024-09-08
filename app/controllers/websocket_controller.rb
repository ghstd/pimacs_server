class WebsocketController < ApplicationController
  def index
    html_content = "<h1>server started</h1>"
    render html: html_content.html_safe
  end
end
