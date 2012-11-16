class Hiera
  module Backend
    class Redis_backend

      VERSION="1.0.1"

      attr_reader :redis, :options

      def initialize
        Hiera.debug("Hiera Redis backend %s starting" % VERSION)
        @redis = connect
      end

      def deserialize(args = {})
        return nil if args[:string].nil?

        Hiera.debug "Found %s" % args[:redis_key]
        return args[:string] unless options.include? :deserialize

        case options[:deserialize]
        when :json
          Hiera.debug("Deserializing JSON")
          require 'json'

          JSON.parse(args[:string])
        when :yaml
          Hiera.debug("Deserializing YAML")
          require 'yaml'
          YAML::load(args[:string])
        else
          Hiera.warn("Invalid configuration for :deserialize; found %s" % options[:deserialize])
          args[:string]
        end
      # when we try to deserialize a string
      rescue JSON::ParserError
        args[:string]
      rescue => e
        Hiera.warn("Exception raised: %s: %s" % [e.class, e.message])
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = nil

        Hiera.debug("Looking up %s in Redis backend" % key)

        Backend.datasources(scope, order_override) do |source|
          redis_key = "%s" % [source.split('/'), key].join(options[:separator])
          Hiera.debug("Looking for data source %s" % source)

          data = deserialize(:string => redis_query(redis_key),
                             :redis_key => redis_key,
                             :key => key)

          next unless data

          new_answer = Backend.parse_answer(data, scope)

          case resolution_type
          when :array
            raise Exception, "Hiera type mismatch: expected Array and got #{new_answer.class}" unless new_answer.is_a? Array or new_answer.is_a? String
            answer ||= []
            answer << new_answer
          when :hash
            raise Exception, "Hiera type mismatch: expected Hash and got #{new_answer.class}" unless new_answer.is_a? Hash
            answer ||= {}
            answer = new_answer.merge answer
          else
            answer = new_answer
            break
          end
        end

        answer
      end

      private

      def connect

        # override default options
        @options = {
          :host => 'localhost',
          :port => 6379,
          :db => 0,
          :password => nil,
          :timeout => 3,
          :path => nil,
          :soft_connection_failure => false,
          :separator => ':'
        }.merge Config[:redis] || {}

        require 'redis'

        Redis.new(options)
      rescue LoadError
        retry if require 'rubygems'
      end

      def redis_query(redis_key)

        case redis.type redis_key
        when 'set'
          redis.smembers redis_key
        when 'hash'
          redis.hgetall redis_key
        when 'list'
          redis.lrange(redis_key, 0, -1)
        when 'string'
          redis.get redis_key
        when 'zset'
          redis.zrange(redis_key, 0, -1)
        else
          Hiera.debug("No such key: %s" % redis_key)
          nil
        end
      rescue Redis::CannotConnectError => e
        Hiera.warn('Cannot connect to Redis server')
        raise e unless options.has_key?(:soft_connection_failure)
        nil
      end
    end
  end
end
