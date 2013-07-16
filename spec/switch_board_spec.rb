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
  it "should have method get_next" do
    dataset.should respond_to(:get_next)
  end

  it "should allow getting next ids with default" do
    expect { dataset.get_next }.not_to raise_error
    dataset.get_next.count.should eq 1
  end

  it "should allow getting next 3 ids" do
    expect { dataset.get_next(3) }.not_to raise_error
    dataset.get_next(3).count.should eq 3
  end

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
      is_locked = dataset.is_id_locked?("SOME_ID_E")
      is_locked.should eq true
    end


    it "should allow should lock id only for as per expiration time" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      expect { dataset.lock_id(1, "SOME_ID_2", 1) }.not_to raise_error
      dataset.is_id_locked?("SOME_ID_2").should be_true
      sleep(2)
      dataset.is_id_locked?("SOME_ID_3").should be_false
    end

    it "should return unlocked of unlocked key" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.is_id_locked?("SOME_ID_8").should be_false
    end    

    it "should allow getting all the locked IDs" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      expect { dataset.lock_id(1, "SOME_ID_4") }.not_to raise_error
      expect { dataset.lock_id(1, "SOME_OTHER_ID") }.not_to raise_error
      expect { dataset.lock_id(2, "SOME_THIRD_ID") }.not_to raise_error      
      expect { dataset.lock_id(2, "SOME_FOURTH_ID") }.not_to raise_error      
      dataset.get_all_locked_ids.count.should eq 4
    end

    it "should get clean results when no IPs are locked" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")
      dataset.get_all_locked_ids.count.should eq 0
    end

    ##@TODO need to stub Solr so that test is not Solr dependent
    #Converting to array in this check, because rspec can't compare ennumarators
    it "should give consistent results when no lockers present" do
      call1 = dataset.get_next(2)
      call2 = dataset.get_next(2)
      call1.should be_eql(call2)
    end

    it "should respect limit when lock present" do
      dataset.register_locker(2, "Raz")
      dataset.lock_id(2, "61", 2) 
      dataset.get_next(2).count.should eq 2
    end

    it "should filter out results" do
      call1 = dataset.get_next(5)
      call1.count.should eq 5
      dataset.register_locker(3, "Raz")
      dataset.lock_id(3, "61", 3) 
      call2 = dataset.get_next(5)
      call2.count.should eq 5
      call1.should_not eq call2
    end    

  end

end

describe :SolrPersistnce do
  let!(:solr_persistance) {SwitchBoard::SolrPersistance.new}

  it "should have method candidates" do
    solr_persistance.should respond_to(:candidates)
  end

  it "should not raise not implemented" do
    expect {solr_persistance.candidates(3) }.not_to raise_error
  end
end
