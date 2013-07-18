require 'switch_board/datasets/redis_dataset'

module SwitchBoard

  class Configuration
    attr_accessor  :dataset

    def initialize(dataset = SwitchBoard::RedisDataset.new)
      @dataset = dataset
    end

  end
end