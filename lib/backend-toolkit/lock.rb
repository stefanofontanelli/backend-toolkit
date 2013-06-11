# -*- encoding: utf-8 -*-
require 'digest/md5'
require 'json'
require 'logger'
require 'redis'
require 'time'
require "#{File.dirname(__FILE__)}/message"

module BackendToolkit

	class Lock

		def initialize(opts = {})
			@redis = opts[:redis] || Redis.current
			@ttl = opts[:ttl] || 180
			@logger = opts[:logger] || Logger.new(nil)
			@basekey = "BackendToolkit::Lock::"
		end

		def generate_key(obj)
			key = BackendToolkit::Message.new(obj).to_json
			digest = Digest::MD5.hexdigest "#{@basekey}#{key}"
			"_backendtoolkit_lock_#{digest}"
		end

		def acquire(obj, &block)
			is_acquired = _acquire obj
			return is_acquired unless block && is_acquired
			begin
				block.call self
			rescue Exception => e
				raise e
			ensure
				self.release obj
			end
			true
		end

		def release(obj)
			key = self.generate_key obj
			@redis.del key
			true
		end

		def keep_alive(obj, ttl = nil)
			key = self.generate_key obj
			ttl ||= @ttl
			ttl = Time.now.to_i + ttl + 1
			@redis.set key, ttl
			@redis.expireat key, ttl + @ttl
		end

		private
		def _acquire(obj)
			key = self.generate_key obj
			now = Time.now.to_i
			ttl = (now + @ttl + 1)
			lock = @redis.setnx key, ttl
			if lock
				@logger.debug { "Lock acquired on #{obj}: #{key}, #{ttl}" }
				@redis.expireat key, ttl + @ttl
				return true
			end
			@logger.debug { "Lock not acquired on #{obj}: #{key}, #{ttl}." }
			if @redis.get(key).to_i < now && @redis.getset(key, ttl).to_i < now
				@logger.debug { "Deadlock found: lock acquired on #{obj}" }
				@redis.expireat key, ttl + @ttl
				return true
			end
			false
		end

	end

end