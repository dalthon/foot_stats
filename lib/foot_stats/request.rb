require 'rest-client'

module FootStats
  # Class responsible to make the request to the FootStats API
  #
  # @example
  #
  #  Request.new('ListaCampeonatos')
  #
  class Request
    attr_reader :response_body, :resource_name, :resource_key, :logger

    def initialize(resource, options={})
      @resource_name = resource.resource_name
      @resource_key  = resource.resource_key
      @response_body = post(options)
      @logger        = Setup.logger
    end

    # Return the request uri based on the resource.
    #
    # @return [String]
    #
    def request_url
      "#{Setup.base_url}/#{resource_name}"
    end

    # Make the post request to the request url.
    #
    # @return [String]
    #
    def post(options)
      logger.info("POST #{request_url}") if logger.present?
      response = RestClient.post(request_url, setup_params.merge(options))
      logger.info("RESPONSE BODY:\n#{response}\n") if logger.present?
      response
    end

    # Parse the "XML"/ "JSON".
    #
    # @return [Response]
    #
    def parse
      Response.new(resource_key: @resource_key, body: @response_body)
    end

    # Passing the setup params configured in your app.
    #
    # @return [Hash]
    #
    def setup_params
      {
        :Usuario => Setup.username,
        :Senha   => Setup.password
      }
    end
  end
end