# -*- encoding: utf-8 -*-
require 'time'

Gem::Specification.new do |s|
    s.name        = 'backend-toolkit'
    s.version     = '0.0.0'
    s.date        = Time.now.to_date.to_s
    s.authors     = ['Stefano Fontanelli']
    s.email       = ['s.fontanelli@gmail.com']
    s.homepage    = 'https://github.com/stefanofontanelli/backend-toolkit'
    s.summary     = 'A set of classes that simplify building a scalable backend for your app.'
    s.description = File.new('README.md').read

    s.add_dependency "redis", "~> 3.0.4"
    s.add_dependency "json", "~> 1.8.0"

    s.add_development_dependency "rake", "~> 10.0.4"
end
