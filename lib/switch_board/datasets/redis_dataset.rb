require 'switch_board/datasets/abstract_dataset'
require "redis"
require 'json'

module SwitchBoard

  class RedisDataset < SwitchBoard::AbstractDataset

    LOCK_MAP_KEY = "switch_board::locked_ids"
    attr_accessor  :con, :switchboard, :name

    def initialize(host = "127.0.0.1", port = 6379, name = "redis_switchbord", namespace = nil)
      @con = Redis.new(:host => host, :port => port)
      @name = name
      @lock_map_key = namespace.nil? ? LOCK_MAP_KEY : "#{LOCK_MAP_KEY}::#{namespace}"
    end

    def cleanup
      ## clean up keys, used mainly for testing
      @con.del @name
      @con.del "#{@lock_map_key}_z"
      @con.del "#{@lock_map_key}_h"
    end

    def get_locked
      active_lockers = list_lockers.map { |item| JSON.parse(item)}
      active_lockers
    end

    def switchboard
      @switchboard ||= @con.smembers @name
    end

    def register_locker(uid, name)
      @con.sadd @name, {uid: uid, name: name, created_at: redis_time}.to_json.to_s
      list_lockers ## update lockers list
      true
    end

    def list_lockers
      list_lockers ||= (@con.smembers @name).map { |item| JSON.parse(item)}
    end

    def locker(uid)
      (list_lockers.select {|locker| locker["uid"] == uid}).first
    end

    #Locking mechanisem is based on sorted set, sorted set is used to allow a simulation
    # of expiration time on the keys in the map
    def lock_id(locker_uid, id_to_lock, expire_in_sec = 5)
      now = redis_time
      @con.multi do
        @con.zadd("#{@lock_map_key}_z", (now + expire_in_sec), id_to_lock)
        @con.hset("#{@lock_map_key}_h", id_to_lock, locker_uid)
      end
    end

    #Check if key exists to see if it is locked and it has not expired
    #before getting keys, remove expired keys
    def id_locked?(id_to_check)
      @con.hexists("#{@lock_map_key}_h", id_to_check)
    end


    def unlock_id(locker_uid, id_to_unlock)
      @con.hdel("#{@lock_map_key}_h", id_to_unlock)
    end

    def get_all_locked_ids
      clean_old_keys
      @con.hgetall "#{@lock_map_key}_h"
    end

    def get_all_their_locked_ids(uid)
      res = get_all_locked_ids
      res.reject {|key, key_uid|  key_uid.to_s == uid.to_s }
    end

    def get_all_my_locked_ids(uid)
      res = get_all_locked_ids
      get_all_locked_ids.select {|key, key_uid|  key_uid.to_s == uid.to_s }
    end

    ##################### Private Methods #################
    private

    def clean_old_keys
      keys = @con.zrangebyscore("#{@lock_map_key}_z", 0, redis_time)
      if keys.size > 0
        @con.zremrangebyscore("#{@lock_map_key}_z", 0, redis_time)
        keys.each {|key| @con.hdel("#{@lock_map_key}_h", key)}
      end
    end

    def redis_time
      instant = @con.time
      Time.at(instant[0], instant[1]).to_i
    end

  end

end
