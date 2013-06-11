# -*- encoding: utf-8 -*-
require 'test/unit'
require 'backend-toolkit/lock'

class LockTest < Test::Unit::TestCase

  def test_standard_use_case
    obj = { 'string' => 'a string value', 'int' => 100, 'hash' => {}, 'array' => [] }
    lock = BackendToolkit::Lock.new
    assert lock.acquire(obj) { |l| assert l == lock }
  end

  def test_release_with_exception
    obj = { 'string' => 'a string value', 'int' => 100, 'hash' => {}, 'array' => [] }
    lock = BackendToolkit::Lock.new
    assert_raise RuntimeError do
    	assert lock.acquire(obj) { |l| raise "OMG! It is an error!" }
	end
    assert lock.acquire(obj) { |l| assert l == lock }
  end

  def test_acquire_release
    obj = { 'string' => 'a string value', 'int' => 100, 'hash' => {}, 'array' => [] }
  	lock = BackendToolkit::Lock.new
    assert lock.acquire(obj)
    assert !lock.acquire(obj)
    assert lock.release(obj)
    assert lock.acquire(obj)
    assert lock.release(obj)
  end

end