require 'switch_board/persistance/solr_persistance'
require 'switch_board/datasets/redis_dataset'

module SwitchBoard

  class Configuration
    attr_accessor  :dataset

    def initialize(dataset = SwitchBoard::RedisDataset.new, persistance = SwitchBoard::SolrPersistance.new)
      @dataset = dataset
      @persistance = dataset.set_persistance(persistance)
    end

  end
end