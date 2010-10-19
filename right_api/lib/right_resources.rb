#!/usr/bin/env ruby
# @author Satoshi Ohki

module RightResource

class connection
  def initialize(vars)
    @api = RightAPI.new
  #  api.log_file = RSAPI_LOG
  #  api.log = true

    @api.login(
      :username => vars[:username],
      :password => vars[:password],
      :account => vars[:account]
    )
  end

  def send(path, opts={})
    response = @api.send(path)
    unless response
      raise RightAPIError, "Failed to get RightScale info from RightScale API!!"
    end

    return response
  rescue => e
    $logger.debug(e.backtrace)
    $logger.warn("FAILED: RightAPI:\n" + e)
    raise
  end
end

class Base
  # CRUD Operations
  def index(params={})
  end

  def show(id, params={})
  end

  def create(params={})
  end

  def update(id, params={})
  end

  def destroy(id)
  end
end

# Management API
class Management
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
