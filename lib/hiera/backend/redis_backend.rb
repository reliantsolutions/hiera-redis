class Hiera
  module Backend
    class Redis_backend
      VERSION = '2.0.0'

      attr_reader :options

      def initialize
        require 'redis'
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

      def lookup(key, scope, order_override, resolution_type, context)
        answer = nil
        found = false

        Backend.datasources(scope, order_override) do |source|
          redis_key = (source.split('/') << key).join(options[:separator])
          data = redis_query(redis_key)
          data = deserialize(data: data, redis_key: redis_key, key: key) if options.include?(:deserialize)

          next if data.nil?
          found = true

          new_answer = Backend.parse_answer(data, scope, {}, context)

          case resolution_type.is_a?(Hash) ? :hash : resolution_type
          when :array
            check_type(key, new_answer, Array, String)
            answer ||= []
            answer << new_answer
          when :hash
            check_type(key, new_answer, Hash)
            answer ||= {}
            answer = Backend.merge_answer(new_answer, answer, resolution_type)
          else
            answer = new_answer
            break
          end
        end

        throw :no_such_key unless found
        answer
      end

      private

      def check_type(key, value, *types)
        return if types.any? { |type| value.is_a?(type) }
        expected = types.map(&:name).join(' or ')
        raise "Hiera type mismatch for key '#{key}': expected #{expected} and got #{value.class}"
      end

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
      rescue Redis::CannotConnectError, Errno::ENOENT => e
        Hiera.warn('Cannot connect to Redis server')
        raise e unless options[:soft_connection_failure]
        nil
      end
    end
  end
end
