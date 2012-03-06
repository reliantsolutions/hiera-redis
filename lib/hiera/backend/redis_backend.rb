class Hiera
  module Backend
    class Redis_backend

      VERSION="0.1.1"

      def initialize

        require 'redis'
        Hiera.debug("Hiera Redis backend starting")

        # better error checking needed here?
        path = Config[:redis][:path]
        port = Config[:redis][:port] || 6397
        host = Config[:redis][:host] || '127.0.0.1'

        if path.nil?
          @r = Redis.new(:host => host, :port => port)
        else
          @r = Redis.new(:path => path)
        end
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
