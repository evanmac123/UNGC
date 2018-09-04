# frozen_string_literal: true

require "logger"

module Docebo

  if Rails.env.test?
    require "mocha/setup"
    factory = Mocha::Mock.new("api-factory") #FakeApi
    api = Mocha::Mock.new("api")
    factory.stubs(create: api)
    Api = factory
  else
    Api = HttpApi
  end

end
