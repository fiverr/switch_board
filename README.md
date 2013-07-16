## switch_board

![http://makemusicals.com/2011/11/communication-101-toeing-the-party-line/switchboard1/](http://makemusicals.com/wp-content/uploads/2011/11/switchboard1-300x236.jpg "Switchboard")

### Description

**SwitchBoard** is a utility gem designed to help in the coordinate of locked object to a set of "lockers".
Think of a bank's cashiers, where customers are in line to be served, they are the dataset.
When a customer is served by a cashier, it is still in line to be served, but is now "locked".
Locking is indicated in the "Persistance" layer.
Locking expiration is allowed so that if during "serving" a cashier gotta run home, it will go back to the queue when released.


The workflow has two main components:

* Dataset - Implementaion is Solr based for now, but can be replaced.
* Persistance - Implement is Redis based, but can be replaced

### The Dataset

This is the main set of content from which "lockers"

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



````

### Install

````
  $ gem install switch_board
````
### Copyright

Copyright (c) 2013 Avner Cohen

See LICENSE.txt for details.