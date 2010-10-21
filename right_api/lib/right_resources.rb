#!/usr/bin/env ruby
# @author Satoshi Ohki

require 'rubygems'
require 'rest_client'

module RightResource
  class Base < Hash
    class << self
      attr_accessor :instances
      def connection(refresh=false)
        if defined?(@connection) || superclass == Object
          @connection = Connection.new(params) if refresh || @connection.nil?
          @connection.login(:username => user, :password => pass, :account => account)
          @connection
        else
          superclass.connection
        end
      end
      def headers
      end
      def element_path(id, prefix_options={}, query_options=nil)
      end
      def create(attributes={})
        self.new(attributes)
      end
      # CRUD Operations
      # :all, :first, :last
      # example: (servers)params = {
      #   :filter => "private_ip_address=10.1.1.1"
      #   :filter => "nickname=web-001"
      # }
      def index(params={})
        path = "#{resource_name}#{format}#{query_string(params)}"
        connection.get(path || [])
      end

      def show(id, params={})
        @connection.get()
  #      self.class.new
      end

      def format=(type)
        self.class.format = type.sub("json", "js")
        connection.format = format
      end

      def format
        self.class.format || "xml"
      end

      def resource_name
        self.class.name.downcase + "s"
      end
      def collection_path

      end

      def instantiate_collection(collection, prefix_option={})
        collection.collect! {|record| instantiate_record(record, prefix_options)}
      end

      def instantiate_record(record, prefix_options={})
        self.class.new(record)
      end

      def query_string(options)
        query = ""
        options.each do |key,value|
          query << query.empty? ? "?#{key.to_s}=#{value}" : "&#{key.to_s}=#{value}"
        end
      end
    end

    def initialize(attributes={})
      @attributes = attributes
      @id = connection.resource_id ||= attributes[:href]..match(/\d+$/)
    end

    protected
    def store
      self.class.instances ||= []
      self.class.instances << self
    end

    def connection(refresh=false)
      self.class.connection(refresh)
    end

    # get data and update
    def update(id, params={})
      @connection.put(path, encode, self.class.headers)
    end

    # get data and create(Clone)
    def create(params={})
      @connection.post(path, encode, self.class.headers) do |response|
  #      self.id = response.body
      end
    end

    def destroy(id)
      @connection.delete(path, self.class.headers)
    end
  end


  # Management API
  class Management < Base
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
  class Design < Base
  end

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
end
