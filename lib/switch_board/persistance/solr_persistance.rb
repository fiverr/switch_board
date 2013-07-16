require 'rsolr'
require 'switch_board/persistance/abstract_persistance'

module SwitchBoard

  class SolrPersistance < SwitchBoard::AbstractPersistance

    attr_accessor :solr

    def initialize(url = "http://localhost:8983/solr")
      @solr = RSolr.connect :url => url
    end

    def candidates(limit = 5)
      resp = @solr.get 'gigs_for_search/select', :params => {:q => '*:*', :fl => "id", :rows => limit}
      resp["response"]["docs"]
    end

  end

end