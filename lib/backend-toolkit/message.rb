# -*- encoding: utf-8 -*-
require 'json'

module BackendToolkit

    class Message

        attr_accessor :data

        def self.from_json(json)
            message = JSON.parse(json)
            unless message.is_a?(Hash) && message['data']
                raise "JSON message has a wrong format." 
            end
            self.new message['data']
        end

        def initialize(data)
            @data = data
        end

        def to_json
            JSON.generate({:data => @data})
        end

    end

end