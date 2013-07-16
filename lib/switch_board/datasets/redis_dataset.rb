require 'switch_board/datasets/abstract_dataset'
require "redis"
require 'json'

module SwitchBoard

  class RedisDataset < SwitchBoard::AbstractDataset

    SWITCHBOARD_NAME ="redis_switchbord"
    LOCK_MAP_KEY = "switch_board::locked_ids"
    attr_accessor  :con, :persistance, :switchboard

    def initialize(persistance = SwitchBoard::SolrPersistance.new, host = "127.0.0.1", port = 6379)
      @con = Redis.new(:host => host, :port => port)
      @persistance  = persistance
      ## clean up keys
      @con.del SWITCHBOARD_NAME
      @con.del "#{LOCK_MAP_KEY}_z"
      @con.del "#{LOCK_MAP_KEY}_h"
    end

    #Logic should be to get candidates from persistance layer
    #filter out the locked , if respect_locked = true
    def get_next(limit = 1, respect_locks = true)
      locked_ids = []
      if respect_locks
        locked_ids = get_all_locked_ids.keys # take just the keys, values are the UID of the lockers
      end
      #Query from persistance for results, add a buffer
      base_set = persistance.candidates(limit + locked_ids.count)
      remove_locked = base_set.reject {|item| locked_ids.include?(item["id"]) }
      remove_locked[0..limit-1]
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

    #Locking mechanisem is based on sorted set, sorted set is used to allow a simulation
    # of expiration time on the keys in the map
    def lock_id(locker_uid, id_to_lock, expire_in_sec = 5)
      @con.multi do
        @con.zadd("#{LOCK_MAP_KEY}_z", (Time.now.to_i + expire_in_sec), id_to_lock)
        @con.hset("#{LOCK_MAP_KEY}_h", id_to_lock, locker_uid)
      end
    end

    #Check if key exists to see if it is locked and it has not expired
    #before getting keys, remove expired keys
    def is_id_locked?(id_to_check)
      @con.hexists("#{LOCK_MAP_KEY}_h", id_to_check)
    end


    def unlock_id(locker_uid, id_to_unlock)
      @con.hset("#{LOCK_MAP_KEY}_h", id_to_lock, locker_uid)
    end

    def get_all_locked_ids
      clean_old_keys
      @con.hgetall "#{LOCK_MAP_KEY}_h"
    end


    ##################### Private Methods #################
    private

    def clean_old_keys
      keys = @con.zrangebyscore("#{LOCK_MAP_KEY}_z", 0, Time.now.to_i)
      if keys.size > 0
        @con.zremrangebyscore("#{LOCK_MAP_KEY}_z", 0, Time.now.to_i)
        keys.each {|key| @con.hdel("#{LOCK_MAP_KEY}_h", key)}
      end
    end

  end

end