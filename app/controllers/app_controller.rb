class AppController < ApplicationController

	require 'net/http'

	# App list page
	def list

		# Get app versions
		url = URI.parse($base_url + "/v2/apps/versions?developerId=1&query=" + '{$or: [{"status.value":"rejected",isLatestVersion:true},{isLive:true},{"status.value":{$in:["inDevelopment","inReview","pending"]}}]}')
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true

		req = Net::HTTP::Get.new(url.to_s, initheader = {'Content-Type' => 'application/json', 'Authorization' => $auth})
		res = Net::HTTP.start(url.host, url.port) { |https|
			http.request(req)
		}
		@apps = ActiveSupport::JSON.decode(res.body)['list']

		# Get statistics after retrieving app versions
		url = URI.parse($base_url + '/v2/stats/series/month/views?query={developerId: "1"}');
		req = Net::HTTP::Get.new(url.to_s, initheader = {'Content-Type' => 'application/json', 'Authorization' => $auth})
		res = Net::HTTP.start(url.host, url.port) { |https| 
			http.request(req)
		}
		@statistics = ActiveSupport::JSON.decode(res.body)

		@views = 0
		@statistics.each do |statistic|
			@views += statistic[1]
		end
	end

	def create

	end

	#Edit page
	def update

		# Get app version
		url = URI.parse($base_url + '/v2/apps/' + params[:appId] + '/versions/' + params[:version] + '?developerId=' + $developer_id)
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true

		req = Net::HTTP::Get.new(url.to_s, initheader = {'Authorization' => $auth})
		res = Net::HTTP.start(url.host, url.port) { |https|
			http.request(req)
		}

		@app = ActiveSupport::JSON.decode(res.body)

		# Set file list and image list if exists
		if ( @app['customData']['files'] )
			@app['customData']['fileList'] = @app['customData']['files'].split(',')
		end
		if ( @app['customData']['images'] )
			@app['customData']['imageList'] = @app['customData']['images'].split(',')
		end

		# Get app statistics after retrieving app version
		url = URI.parse($base_url + '/v2/stats/series/month/views?query={developerId: "1", appId: "' + @app['appId'].to_s + '"}');
		req = Net::HTTP::Get.new(url.to_s, initheader = {'Content-Type' => 'application/json', 'Authorization' => $auth})
		res = Net::HTTP.start(url.host, url.port) { |https| 
			http.request(req)
		}
		@statistics = ActiveSupport::JSON.decode(res.body)

		@views = 0
		@statistics.each do |statistic|
			@views += statistic[1]
		end
	end
end
