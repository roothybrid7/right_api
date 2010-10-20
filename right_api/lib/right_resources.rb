#!/usr/bin/env ruby
# @author Satoshi Ohki

require 'rubygems'
require 'uri'
require 'rest_client'

module RightResource
end

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

class Base
  class << self
    def connection(refresh=false)
      @connection = Connection.new(api, format) if refresh || @connection.nil?
      @connection.login(:username => user, :password => pass, :account => account)
    end
    def headers
    end
    def element_path(id, prefix_options={}, query_options=nil)
    end
    def create(attributes={})
      self.new(attributes)
    end
  end

  def initialize
    @user
  end

  # CRUD Operations
  def index(params={})
  end

  def show(id, params={})
  end

  def create(params={})
    connection.post(path, encode, self.class.headers) do |response|
#      self.id = response.body
    end
  end

  def update(id, params={})
    connection.put(path, encode, self.class.headers)
  end

  def destroy(id)
    connection.delete(path, self.class.headers)
  end
end

# Management API
class Management < Base
  def initialize(doc)
    @doc = doc
  end

  attr_reader :doc
  include RightResource
  def id(data)
    @doc.elements.each(root) do |elm|
      if elm.elements['nickname'].text == name
        yield elm.elements['nickname'].text, elm.elements['href'].text.match(/[0-9]+$/).to_s.to_i
      end
    end
  end
end

class Deployment < Management
end

class Server < Management
  attr_reader :created_at, :updated_at, :state, :server_type, :current_instance_href
  attr_accessor :nickname, :href, :deployment_href, :server_template_href
end

class Status < Management
end

class AlertSpec < Management
end

class Ec2EbsVolume < Management
end

class Ec2EbsSnapshot < Management
end

class Ec2ElasticIP < Management
end

class Ec2SecurityGroup < Management
end

class Ec2SshKeys < Management
end

class ServerArray < Management
end

class S3Bucket < Management
end

class Tag < Management
end

class VpcDhcpOption < Management
end

# Design API
class ServerTemplate < Design
end

class RightScript < Design
end

class MultiCloudImage < Design
end

class Macro < Design
end

class Credential < Design
end
