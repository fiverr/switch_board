#define API for the data set
module SwitchBoard
  class AbstractDataset

    attr_accessor :persistance

    def set_persistance(persistance)
      @persistance = persistance
    end

    #Returns the next Model/ID that is available from the dataset
    def get_next(limit = 1)
      raise "#{__method__} not implemented in #{self.class.name}"
    end

    #get the IDs that are now locked by other lockers
    def get_locked
      raise "#{__method__} not implemented in #{self.class.name}"
    end

    #setup a new switchboard, a coordination persistence schema
    def switchboard
      raise "#{__method__} not implemented in #{self.class.name}"
    end

   #Add a new locker to the switchboard for future coordination
    def register_locker(uid, name)
      raise "#{__method__} not implemented in #{self.class.name}"
    end

    #list all the lockers registerd for this switchboard
    def list_lockers
      raise "#{__method__} not implemented in #{self.class.name}"
    end 

    #list retrive data of a specific locker
    def locker(uid)
      raise "#{__method__} not implemented in #{self.class.name}"
    end 

    #Set ID of an object as locked for a specific uid
    def lock_id(locker_uid, id_to_lock, expire_in_sec = 60)
      raise "#{__method__} not implemented in #{self.class.name}"
    end

    #Set ID of an object as locked for a specific uid
    def unlock_id(locker_uid, id_to_unlock)
      raise "#{__method__} not implemented in #{self.class.name}"
    end

    #Check to see if a certain ID is locked or not
    def id_locked?(uid)
      raise "#{__method__} not implemented in #{self.class.name}"
    end

    #Retrive all the locked ids in the switchboard
    def get_all_locked_ids
      raise "#{__method__} not implemented in #{self.class.name}"
    end

  end
end