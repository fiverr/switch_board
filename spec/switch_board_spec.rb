describe SwitchBoard do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end

  it "should have a logger defined" do
    subject.logger.should_not be_nil
  end

  it "should have good working logger" do
    subject.logger.should respond_to(:info, :error, :debug)
  end
end

describe :Configuration do
  it "should have a dataset" do
    conf = SwitchBoard::Configuration.new
    conf.should respond_to(:dataset)
  end
end

describe :RedisDataset do
  let!(:dataset) {SwitchBoard::Configuration.new.dataset }

  it "should implemenet get_locked" do
    expect { dataset.get_locked }.not_to raise_error
  end

  describe :RedisDatasetSwitchBoard do
    let!(:switchboard) {SwitchBoard::Configuration.new.dataset.switchboard }

    it "should be able to create a new locking set" do
      switchboard.should match_array([])
    end

    it "should have clean locker board on startup" do
      lockers = dataset.list_lockers
      lockers.count.should eq 0
    end

    it "should allow registering lockers" do
      dataset.register_locker(1, "Moshe")
      dataset.register_locker(2, "Raz")
      dataset.register_locker(3, "Pupik")
      lockers = dataset.list_lockers
      lockers.count.should eq 3
    end

    it "should allow registering with strings" do
      dataset.register_locker("muke", "Moshe")
      dataset.register_locker("uke", "Raz")
      lockers = dataset.list_lockers
      lockers.count.should eq 2
    end

    it "should allow getting a locker registerd with a non int UID" do
      dataset.register_locker("muke", "Moshe")
      dataset.locker("muke")["name"].should eq("Moshe")
    end    

    it "should allow getting name of a registered locker by uid" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.register_locker(3, "Moshe")
      dataset.locker(3)["name"].should eq "Moshe"
    end

    it "should return nil for non existing uid" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.register_locker(3, "Moshe")
      dataset.locker(4).should be_nil
    end

    it "should allow locking object id for specific locker" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      expect { dataset.lock_id(1, "SOME_ID") }.not_to raise_error
    end

    it "should allow checking lock state for a given id " do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      expect { dataset.lock_id(1, "SOME_ID_E") }.not_to raise_error
      is_locked = dataset.id_locked?("SOME_ID_E")
      is_locked.should eq true
    end


    it "should allow should lock id only for as per expiration time" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      expect { dataset.lock_id(1, "SOME_ID_2", 1) }.not_to raise_error
      dataset.id_locked?("SOME_ID_2").should be_true
      sleep(2)
      dataset.id_locked?("SOME_ID_3").should be_false
    end

    it "should return unlocked of unlocked key" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.id_locked?("SOME_ID_4").should be_false
    end    

    it "should allow getting all the locked IDs" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      expect { dataset.lock_id(1, "SOME_ID_5") }.not_to raise_error
      expect { dataset.lock_id(1, "SOME_OTHER_ID") }.not_to raise_error
      expect { dataset.lock_id(2, "SOME_THIRD_ID") }.not_to raise_error      
      expect { dataset.lock_id(2, "SOME_FOURTH_ID") }.not_to raise_error      
      dataset.get_all_locked_ids.count.should eq 4
    end

    it "should get clean results when no IDs are locked" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.get_all_locked_ids.count.should eq 0
    end

    it "should allow users to get all IDs not locked by itself" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.lock_id(1, "SOME_ID_6")
      dataset.lock_id(1, "SOME_ID_7")
      dataset.lock_id(1, "SOME_ID_8")
      dataset.lock_id(2, "SOME_ID_9")
      dataset.get_all_their_locked_ids(2).count.should eq 3

    end


  end

end