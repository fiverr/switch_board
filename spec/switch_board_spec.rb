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
  end

   it "should allow getting next 3 ids" do
    expect { dataset.get_next(3) }.not_to raise_error
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
      expect { dataset.lock_id(1, "SOME_UID")}.not_to raise_error
     end

     it "should allow checking if object is locked by any given uid" do
      dataset.register_locker(1, "Pupik")
      dataset.register_locker(2, "Raz")      
      expect { dataset.lock_id(1, "SOME_UID")}.not_to raise_error
      dataset.is_id_locked?("SOME_UID").should be_true
     end


     it "should allow should lock id only for as per expiration time" do
        raise
     end

     it "should allow should getting all the locked IDs" do
        raise
     end

  end

end

describe :SolrPersistnce do
  let!(:solr_persistance) {SwitchBoard::SolrPersistance.new}

  it "should have method get_next" do
    solr_persistance.should respond_to(:candidates)
  end
   
   it "should not raise not implemented" do
    expect {solr_persistance.candidates(3) }.not_to raise_error
  end   
end
