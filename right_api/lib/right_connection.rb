#!/usr/bin/env ruby
# @author Satoshi Ohki

require 'rubygems'
require 'uri'
require 'rest_client'

module RightResource
  class Connection
    attr_accessor :api_version, :log, :api, :format
    attr_reader :headers, :resource_id

    def initialize(params={})
      @api_version = params[:version] ||= "1.0"
      @api = params[:api] ||= "https://my.rightscale.com/api/acct/"
      @format = params[:format].nil? ? "xml" : params[:format]
    end

    def login(params={})
      @username = params[:username]
      @password = params[:password]
      @account = params[:account]

      @api = @api + @account
      @api_object = RestClient::Resource.new(@api, @username, @password)
    rescue => e
      STDERR.puts e.message
      exit 0
    end

    def send(path, method="get", headers={})
      if /\?(.*)$/ =~ path
        path = URI.encode("#{path}&format=#{@format}")
      else
        path = URI.encode("#{path}?format=#{@format}")
      end
      unless method.match(/(get|put|post|delete)/)
        raise "Invalid Action: get|put|post|delete only"
      end
      api_version = {:x_api_version => @api_version, :api_version => @api_version}
      @response = @api_object[path].send(method.to_sym, api_version.merge(headers))
      @headers = @response.headers ||= {}
      @resource_id = @headers[:location].match(/\d+$/) unless @headers[:location].nil?

      @response.body
    rescue => e
      STDERR.puts e.message
      exit 0
    end

    # show|index
    def get(path, headers={})
      self.send(path, "get", headers)
    end

    # create
    def post(path, headers={})
      self.send(path, "post", params)
    end

    # update
    def put(path, headers={})
      self.send(path, "put", params)
    end

    # destory
    def delete(path, headers={})
      self.send(path, "delete", params)
    end
  end
end
