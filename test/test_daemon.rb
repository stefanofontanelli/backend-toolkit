# -*- encoding: utf-8 -*-
require 'test/unit'
require 'backend-toolkit/queue'
require 'backend-toolkit/daemon'

class DaemonTest < Test::Unit::TestCase

    def setup
        @inbound_queue_name = 'test_inbound_queue'
        @inbound_queue = BackendToolkit::Queue.new @inbound_queue_name
        @outbound_queue_name = 'test_outbound_queue'
        @outbound_queue = BackendToolkit::Queue.new @outbound_queue_name
        @daemon = BackendToolkit::Daemon.new @inbound_queue, @outbound_queue, :wait_for_msg => false    
    end

    def teardown
        Redis.current.del @inbound_queue_name
        Redis.current.del @outbound_queue_name
    end

    def test_process
        @inbound_queue << {'field' => 'Empty Message'}
        @daemon.run
        assert_equal @inbound_queue.size, 0
    end

end