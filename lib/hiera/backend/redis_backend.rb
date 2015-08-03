require 'redis'

class Hiera
  module Backend
    class Redis_backend
      VERSION = '1.0.2'

      attr_reader :options

      def initialize
        Hiera.debug("Hiera Redis backend #{VERSION} starting")
        @options = { separator: ':', soft_connection_failure: false }.merge(Config[:redis] || {})
      end

      def deserialize(args = {})
        return nil if args[:data].nil?
        return args[:data] unless args[:data].is_a? String

        result = case options[:deserialize]
                 when :json
                   require 'json'
                   JSON.parse args[:data]
                 when :yaml
                   require 'yaml'
                   YAML.load args[:data]
                 else
                   Hiera.warn("Invalid configuration for :deserialize; found #{options[:deserialize]}")
                   args[:data]
                 end

        Hiera.debug("Deserialized #{options[:deserialize].to_s.upcase}")
        result

      # when we try to deserialize a string
      rescue JSON::ParserError
        args[:data]
      rescue => e
        Hiera.warn("Exception raised: #{e.class}: #{e.message}")
      end

      def lookup(key, scope, order_override, resolution_type, context = {})
        answer = nil

        Backend.datasources(scope, order_override) do |source|
          redis_key = (source.split('/') << key).join(options[:separator])
          data = redis_query(redis_key)
          data = deserialize(data: data, redis_key: redis_key, key: key) if options.include?(:deserialize)

          next unless data

          new_answer = Backend.parse_answer(data, scope, context = context)

          case resolution_type
          when :array
            raise "Hiera type mismatch: expected Array and got #{new_answer.class}" unless new_answer.is_a?(Array) || new_answer.is_a?(String)
            answer ||= []
            answer << new_answer
          when :hash
            raise "Hiera type mismatch: expected Hash and got #{new_answer.class}" unless new_answer.is_a? Hash
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

      def redis
        @redis ||= Redis.new(@options)
      end

      def redis_query(redis_key)
        case redis.type(redis_key)
        when 'set'
          redis.smembers(redis_key)
        when 'hash'
          redis.hgetall(redis_key)
        when 'list'
          redis.lrange(redis_key, 0, -1)
        when 'string'
          redis.get(redis_key)
        when 'zset'
          redis.zrange(redis_key, 0, -1)
        else
          Hiera.debug("No such key: #{redis_key}")
          nil
        end
      rescue Redis::CannotConnectError => e
        Hiera.warn('Cannot connect to Redis server')
        raise e unless options.key?(:soft_connection_failure)
        nil
      end
    end
  end
end
