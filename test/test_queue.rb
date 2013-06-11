# -*- encoding: utf-8 -*-
require 'test/unit'
require 'backend-toolkit/queue'

class QueueTest < Test::Unit::TestCase

    def setup
        @queue_name = 'test_queue'
        @queue = BackendToolkit::Queue.new @queue_name
    end

    def teardown
        Redis.current.del @queue_name
    end

    def test_push_pop
        assert_equal @queue.size, 0
        assert_equal @queue.empty?, true
        (1..10).each {|i| assert_equal @queue.push(i), i} 
        assert_equal @queue.size, 10
        assert_equal @queue.empty?, false
        (1..10).each {|i| assert_equal @queue.pop, i}
        assert_equal @queue.size, 0
        assert_equal @queue.empty?, true
    end

    def test_no_blocking_pop
        assert_equal @queue.pop(false), nil
    end

    def test_process
        (1..10).each {|i| @queue.push(i)} 
        start = 1
        @queue.process(false) do |message, lock|
            assert message
            assert lock
            assert_equal message, start
            start += 1
        end
    end

end