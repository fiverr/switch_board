#define API for the persistance set
module SwitchBoard
  class AbstractPersistance

    #Get a limit of candidates, the results are later on further filterd as a result of a union with locked IDs
    def candidates(limit = 5)
      raise "not implemented in #{self.class.name}"
    end

  end
end