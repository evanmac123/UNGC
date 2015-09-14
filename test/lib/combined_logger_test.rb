require 'test_helper'

class CombinedLoggerTest < ActiveSupport::TestCase

  setup do
    @logger_a = mock('logger_a')
    @logger_b = mock('logger_b')
    @logger = CombinedLogger.new(@logger_a, @logger_b)
  end

  context '#info' do

    should 'forward calls to #info' do
      @logger_a.expects(:info).with('hello').once
      @logger_b.expects(:info).with('hello').once

      @logger.info('hello')
    end

  end

  context '#error' do

    should 'forward calls to #error' do
      error = StandardError.new('doom')
      params = {catastrophic: true}

      @logger_a.expects(:error).with('failure', error, params)
      @logger_b.expects(:error).with('failure', error, params)

      @logger.error('failure', error, params)
    end

    should 'pass along default params' do
      @logger_a.expects(:error).with('failure', nil, {})
      @logger_b.expects(:error).with('failure', nil, {})

      @logger.error('failure')
    end

  end

end
