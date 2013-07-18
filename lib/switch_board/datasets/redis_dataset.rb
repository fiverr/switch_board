require 'switch_board/datasets/abstract_dataset'
require "redis"
require 'json'

module SwitchBoard

  class RedisDataset < SwitchBoard::AbstractDataset

    SWITCHBOARD_NAME ="redis_switchbord"
    LOCK_MAP_KEY = "switch_board::locked_ids"
    attr_accessor  :con, :switchboard

    def initialize(host = "127.0.0.1", port = 6379)
      @con = Redis.new(:host => host, :port => port)
      ## clean up keys
      @con.del SWITCHBOARD_NAME
      @con.del "#{LOCK_MAP_KEY}_z"
      @con.del "#{LOCK_MAP_KEY}_h"
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
      @con.sadd SWITCHBOARD_NAME, {uid: uid, name: name, created_at: redis_time}.to_json.to_s
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
      now = redis_time
      @con.multi do
        @con.zadd("#{LOCK_MAP_KEY}_z", (now + expire_in_sec), id_to_lock)
        @con.hset("#{LOCK_MAP_KEY}_h", id_to_lock, locker_uid)
      end
    end

    #Check if key exists to see if it is locked and it has not expired
    #before getting keys, remove expired keys
    def id_locked?(id_to_check)
      @con.hexists("#{LOCK_MAP_KEY}_h", id_to_check)
    end


    def unlock_id(locker_uid, id_to_unlock)
      @con.hset("#{LOCK_MAP_KEY}_h", id_to_lock, locker_uid)
    end

    def get_all_locked_ids
      clean_old_keys
      @con.hgetall "#{LOCK_MAP_KEY}_h"
    end

    def get_all_their_locked_ids(uid)
       clean_old_keys
        res =@con.hgetall "#{LOCK_MAP_KEY}_h"
        res.reject {|key, key_uid|  key_uid.to_s == uid.to_s }
    end

    ##################### Private Methods #################
    private

    def clean_old_keys
      keys = @con.zrangebyscore("#{LOCK_MAP_KEY}_z", 0, redis_time)
      if keys.size > 0
        @con.zremrangebyscore("#{LOCK_MAP_KEY}_z", 0, redis_time)
        keys.each {|key| @con.hdel("#{LOCK_MAP_KEY}_h", key)}
      end
    end

 def redis_time
      instant = @con.time
      Time.at(instant[0], instant[1]).to_i
    end    

  end

end