require 'ipaddr'

class ClicktaleController < ApplicationController
  def show
    if clicktale_config[:allowed_addresses] && ip_allowed?(request.remote_ip)
      send_file(File.join(Rails.root, "tmp/clicktale", params[:filename] + ".html"), :type => :html, :disposition => "inline")
    else
      render :text => "Not Found", :status => 404
    end
  end

  private
  def ip_allowed?(ip)
    clicktale_config[:allowed_addresses].split(",").any? do |ip_string|
      IPAddr.new(ip_string).include?(ip)
    end
  end
end

