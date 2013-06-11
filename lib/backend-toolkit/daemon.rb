# -*- encoding: utf-8 -*-
require 'logger'
require 'redis'
require "#{File.dirname(__FILE__)}/queue"

module BackendToolkit

    class Daemon

        def initialize(input, output, opts = {})

            unless input.is_a?(BackendToolkit::Queue) && \
                   output.is_a?(BackendToolkit::Queue)
                raise 'You must specify input and output queues!'
            end

            @logger = Logger.new STDOUT
            @queues = {:input => input, :output => output}
            @wait_for_msg = opts[:wait_for_msg].nil? ? true : opts[:wait_for_msg]

        end

        def run
            @queues[:input].process(@wait_for_msg) do |obj, lock|
                begin
                    self.process obj, lock
                rescue Exception => e
                    @logger.error { "#{e}. Skip message: #{obj}" }
                end
            end
        end

        def process(obj, lock)
            raise NotImplementedError
        end

    end

end