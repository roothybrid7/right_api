#!/usr/bin/env ruby
# @author Satoshi Ohki

require 'rubygems'
require 'uri'
require 'rexml/document'
require 'rest_client'
require 'json/pure'

module RightResource
  class Connection
    attr_accessor :api_version, :log, :api, :format
    attr_reader :headers, :resource_id

    def initialize(format)
      @api_version = "1.0"
      @api = "https://my.rightscale.com/api/acct/"
      @format = format ||= "xml"
    end

    def login(params={})
      @username = params[:username]
      @password = params[:password]
      @account = params[:account]

      @api = @api + @account
      @api_object = RestClient::Resource.new(@api, @username, @password)
    rescue => e
      STDERR.puts e.message
    end

    def login?
      @username.nil? ? false : true
    end

    def send(path, method="get", headers={})
      raise "Not Login!!" unless self.login?
      if /\.(xml|js)\?/ =~ path
        path = URI.encode(path)
      elsif /\?(.*)$/ =~ path
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

      if @format == "xml"
        @response.body
      else
        JSON.parse(@response.body)
      end
    rescue => e
      STDERR.puts e.message
    end

    # HTTP methods
    # show|index
    def get(path, headers={})
      self.send(path, "get", headers)
    end

    # create
    def post(path, headers={})
      self.send(path, "post", headers)
    end

    # update
    def put(path, headers={})
      self.send(path, "put", headers)
    end

    # destory
    def delete(path, headers={})
      self.send(path, "delete", headers)
    end
  end
end
