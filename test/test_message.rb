# -*- encoding: utf-8 -*-
require 'test/unit'
require 'backend-toolkit/message'

class MessageTest < Test::Unit::TestCase

  def test_standard_use_case
    data = { 'string' => 'a string value', 'int' => 100, 'hash' => {}, 'array' => [] }
    message = BackendToolkit::Message.new data
    assert_not_equal message.to_json, ''
    assert_equal BackendToolkit::Message.from_json(message.to_json).data, data
  end

end