## switch_board

![http://makemusicals.com/2011/11/communication-101-toeing-the-party-line/switchboard1/](http://makemusicals.com/wp-content/uploads/2011/11/switchboard1-300x236.jpg "Switchboard")

### Description

**SwitchBoard** is a utility gem designed to help in the coordination of locked objects by a set of "lockers".
Think of a bank's cashiers, where customers are in line to be served, they are the dataset.

When a customer is served by a cashier, it is still in line to be served, but is now "locked".

Locking is indicated in the "Persistance" layer.

Locking expiration is allowed so that if during "serving" a cashier got some other business to do and runs home, it will go back to the queue when lock expires.


As such, the workflow has two main components:

* Dataset - Implementaion is Solr based for now, but can be replaced.
* Persistance - Implement is Redis based, but can be replaced

The overall scope of the gem is:

* Allow "lockers" to register themselves
* Allow "lockers" to set a "lock" on object, with a predefined expiration period
* Allow any client to retrive data from some persistance layer excluding the keys that are locked at the moment.
* Allow external observes to see current state of locked object


### Features

The system is light weight and is designed to have low number of "lockers" with many object to be locked.
It is pluggable and well tested so should allow extensions as needed.

### Examples

````ruby

  require 'switch_board'


  #create a new switch_board configuration
  sb = SwitchBoard::Configuration.new #default to Solr + Redis backends
  dataset = sb.dataset

  #Register Lockers (unique identifier, Name/Alias)
  dataset.register_locker(1, "Django")
  dataset.register_locker(2, "Pier")
  dataset.register_locker(3, "Mark")

  #Print out the list of active users
  p dataset.list_lockers

  #Lock IDs for Pier - IDed as 2
  dataset.lock_id(2, "qwerfggj", 5) # lock for 5 seconds
  dataset.lock_id(2, "12345", 600) #Lock for 10 minutes

  #Check to see if ID is locked
  dataset.is_id_locked?("12345") #=> true
  dataset.is_id_locked?("qwerfggj") #=> true
  dataset.is_id_locked?("not_locked_id") #=> false

  #Show all locked objects
  dataset.get_all_locked_ids #=> {"12345"=>"2", "qwerfggj"=>"2"}

  #Get next 5 items from persistance that are not locked
  [{"id"=>"21"}, {"id"=>"51"}, {"id"=>"71"}, {"id"=>"91"}, {"id"=>"121"}, {"id"=>"131"}]


````

### Install

````
  $ gem install switch_board
````
### Copyright

Copyright (c) 2013 Avner Cohen

See LICENSE.txt for details.
