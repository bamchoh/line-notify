class OauthController < ApplicationController
	protect_from_forgery :except => [:callback]

	require 'oauth2'
	require 'net/http'
	require 'openssl'
	require 'uri'
	require 'json'

	AUTH_SITE = 'https://notify-bot.line.me'
	API_SITE  = 'https://notify-api.line.me'

	CLIENT_ID     = APP_CONFIG["client_id"]
	CLIENT_SECRET = APP_CONFIG["client_secret"]
	CALLBACK      = File.join(APP_CONFIG["callback"], "oauth/callback")

	self.request_forgery_protection_token = :state

	def valid_request_origin?
		if forgery_protection_origin_check
			# We accept blank origin headers because some user agents don't send it.
			request.origin.nil? || request.origin == "null" || request.origin == request.base_url
		else
			true
		end
	end

	def index
		if params[:error]
			flash[:danger] = params[:error] + " / " + params[:error_description]
		end
	end

	def callback
		code = params[:code]
		client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => AUTH_SITE)
		token = client.auth_code.get_token(
			code,
			:redirect_uri => CALLBACK,
			:headers => { "Content-Type" => "application/x-www-form-urlencoded" }
		)

		session[:api_token] = token.token

		redirect_to :action => "send_message"
	end

	def get_send_message
		@result = ""
		render "oauth/send_message"
	end

	def get_authorize
		redirect_to :action => "index"
	end

	def authorize
		client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => AUTH_SITE)

		auth_url = client.auth_code.authorize_url(
			:redirect_uri => CALLBACK,
			:scope => 'notify',
			:state => form_authenticity_token,
			:response_mode => 'form_post'
		)

		redirect_to auth_url
	end

	def send_message
		res = msg(session[:api_token], params[:page][:message])

		case res
		when Net::HTTPSuccess
			@result = "successful"
		else
			j = JSON.parse(res.body)
			@result = "[status:#{j["status"]}] #{j["message"]}"
		end
	end

	def msg(token, message)
		url = URI.parse(File.join(API_SITE, 'api/notify'))
		req = Net::HTTP::Post.new(url.path)
		req.content_type = "application/x-www-form-urlencoded"
		req['Authorization'] = "Bearer #{token}"
		req.set_form_data({
			"message" => message
		})

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE


		http.start { |h|
			h.request(req)
		}
	end

end
