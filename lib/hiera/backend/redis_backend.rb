class Hiera
  module Backend
    class Redis_backend

      VERSION="0.1.4"

      attr_reader :redis

      def initialize

        require 'redis'
        Hiera.debug("Hiera Redis backend #{VERSION} starting")

        # default values
        options = {:host => 'localhost', :port => 6379, :db => 0, :password => nil, :timeout => 3, :path => nil}
        
        # config overrides default values
        options.each_key do |k|
          options[k] = Config[:redis][k] if Config[:redis].has_key?(k)
        end

        @redis = Redis.new(options)
      end

      def redis_query(args = {})

        Hiera.debug("Searching for #{args.inspect}")
        # convert our seperator in order to maintain yaml compatibility
        redis_key = args[:source].gsub('/', ':')

        if redis.type(redis_key) == "hash"
          redis.hget(redis_key, args[:key])
        else
          redis_key << ":#{args[:key]}"
          case redis.type(redis_key)
          when "set"
            redis.smembers(redis_key)
          when "hash"
            redis.hgetall(redis_key)
          when "list"
            redis.lrange(redis_key, 0, -1)
          when "string"
            redis.get(redis_key)
          when "zset"
            redis.zrange(redis_key, 0, -1)
          else
            Hiera.debug("No such key: #{redis_key}")
            nil
          end
        end
      end

      def lookup(key, scope, order_override, resolution_type)

        answer = Backend.empty_answer(resolution_type)

        Backend.datasources(scope, order_override) do |source|

          data = redis_query(:source => source, :key => key)
          Hiera.debug("returned data: #{data}")

          next unless data
          new_answer = Backend.parse_answer(data, scope)

          case resolution_type
          when :array
            raise Exception, "Hiera type mismatch: expected Array and got #{new_answer.class}" unless new_answer.is_a?(Array) or new_answer.is_a?(String)
            answer << new_answer
          when :hash
            raise Exception, "Hiera type mismatch: expected Hash and got #{new_answer.class}" unless new_answer.is_a?(Hash)
            answer = new_answer.merge answer
          else
            answer = new_answer
            break
          end
        end

        answer
      end
    end
  end
end
