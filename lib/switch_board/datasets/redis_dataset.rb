require 'switch_board/datasets/abstract_dataset'
require "redis"
require 'json'

module SwitchBoard

  class RedisDataset < SwitchBoard::AbstractDataset

    SWITCHBOARD_NAME ="redis_switchbord"
    attr_accessor  :con, :persistance, :switchboard
    
    def initialize(persistance = SwitchBoard::SolrPersistance.new, host = "127.0.0.1", port = 6379)
      @con = Redis.new(:host => host, :port => port)
      @persistance  = persistance
    end

    #Logic should be to get candidates from persistance layer
    #filter out the locked , if respect_locked = true
    def get_next(limit = 1, respect_locks = true)
    locked_ids = []
    base_set = persistance.candidates
      if respect_locks
        locked_ids = get_locked
      end

    available = base_set - locked_ids
    end

    def get_locked
      active_lockers = list_lockers.map { |item| JSON.parse(item)}
      active_lockers
    end

    def switchboard
        @switchboard ||= ( 
            @con.del SWITCHBOARD_NAME
            @con.smembers SWITCHBOARD_NAME
          )
    end

    def register_locker(uid, name)
      @con.sadd SWITCHBOARD_NAME, {uid: uid, name: name, created_at: Time.now}.to_json.to_s
      list_lockers ## update lockers list
      true
    end

    def list_lockers
      list_lockers ||= (@con.smembers SWITCHBOARD_NAME).map { |item| JSON.parse(item)}
    end 

    def locker(uid)
      (list_lockers.select {|locker| locker["uid"].to_i == uid}).first
    end 

    def lock_id(locker_uid, id_to_lock, expire_in_sec = 5)
      raise
    end

    def unlock_id(locker_uid, id_to_unlock)
      raise
    end    

    def get_all_locked_ids
      raise
    end


    ##################### Private Methods #################
    private


  end

end