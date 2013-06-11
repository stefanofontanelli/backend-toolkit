# -*- encoding: utf-8 -*-
require 'json'
require 'redis'
require "#{File.dirname(__FILE__)}/message"
require "#{File.dirname(__FILE__)}/lock"

module BackendToolkit

    class Queue

        def initialize(name, opts = {})

            unless name.is_a?(String) && !name.empty?
                msg = 'First argument must be a not empty String.'
                raise ArgumentError, msg
            end

            @list_name = name
            opts[:redis] ||= Redis.current
            @redis = opts[:redis]
            opts[:plist] ||= "_processing_list_for_#{@list_name}"
            @plist_name = opts[:plist]
            @lock = BackendToolkit::Lock.new @redis
        end

        def length
            @redis.llen @list_name
        end

        def empty?
            length <= 0
        end

        def push(obj)
            @redis.lpush @list_name, BackendToolkit::Message.new(obj).to_json
        end

        def pop(blocking=true)
            json = @redis.send (blocking ? :brpoplpush : :rpoplpush), @list_name, @plist_name
            BackendToolkit::Message.from_json(json).data if json
        end

        def process(blocking = true)
            while obj = pop(blocking)
                lock_acquired = @lock.acquire(obj) do |lock|
                    begin
                        yield obj, lock
                    rescue Exception => e
                        self << obj
                        raise e
                    ensure
                        msg = BackendToolkit::Message.new(obj).to_json
                        @redis.lrem @plist_name, 1, msg
                    end
                end
                self << obj unless lock_acquired
            end
        end

        alias :size  :length
        alias :<<    :push

    end

end