#!/usr/bin/env ruby
# @author Satoshi Ohki

require 'rubygems'
require 'uri'
require 'rest_client'

module RightResource
  class Connection
    attr_accessor :api_version, :log, :api, :format
    attr_reader :headers

    def initialize(api, format="xml")
      @api_version = "1.0" if @api_version.nil?
      @api = api ||= "https://my.rightscale.com/api/acct/"
      login(params) unless params.nil?
      @format = format
    #  api.log_file = RSAPI_LOG
    #  api.log = true
    end

    def login(params={})
      @username = params[:username]
      @password = params[:password]
      @account = params[:account]

      if @account.match(/[0-9]+/)
        @api += @account
      else
        raise "Invalid account id"
      end
      @api_object = RestClient::Resource.new(@api_call, @username, @password)
    rescue => e
      STDERR::puts e.message
      exit 0
    end

    def send(path, method=:get, headers={})
      if /\?(.*)$/ =~ path
        path = URI.encode("#{path}&format=#{@format}")
      else
        path = URI.encode("#{path}?format=#{@format}")
      end
      unless method.match(/(:get|:put|:post|:delete)/)
        raise "Invalid Action: get|put|post|delete only"
      end
      api_version = {:x_api_version => @api_version, :api_version => @api_version}
      @response = @api[path].send(method, api_version.merge(headers))
      @headers = @response.headers ||= {}
      @resource_id = @headers[:location].match(/\d+$/)

      @response.body
    rescue => e
      STDERR::puts e.message
      exit 0
    end

    # show|index
    def get(path, headers={})
      @api.send(path, :get, headers)
    end

    # create
    def post(path, headers={})
      @api.send(path, :post, params)
    end

    # update
    def put(path, headers={})
      @api.send(path, :put, params)
    end

    # destory
    def delete(path, headers={})
      @api.send(path, :delete, params)
    end
  end
end
