class Hiera
  module Backend
    class Redis_backend

      VERSION="0.1.3"

      def initialize

        require 'redis'
        Hiera.debug("Hiera Redis backend starting")

        # default values
        options = {:host => 'localhost', :port => 6379, :db => 0, :password => nil, :timeout => 3, :path => nil}
        
        # config overrides default values
        options.each_key do |k|
          options[k] = Config[:redis][k] if Config[:redis].has_key?(k)
        end

        @r = Redis.new(options)
      end

      def lookup(key, scope, order_override, resolution_type)

        answer = Backend.empty_answer(resolution_type)

        Backend.datasources(scope, order_override) do |source|

          # convert our seperator in order to maintain yaml compatibility
          rkey = []
          rkey << source.split('/')
          rkey << key
          rkey = rkey.join(':')

          data = case @r.type(rkey)
          when "set"
            @r.smembers(rkey)
          when "hash"
            @r.hgetall(rkey)
          when "list"
            @r.lrange(rkey, 0, -1)
          when "string"
            @r.get(rkey)
          when "zset"
            @r.zrange(rkey, 0, -1)
          else
            Hiera.debug("No such key: #{rkey}")
            next
          end

          next if data.empty?
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
