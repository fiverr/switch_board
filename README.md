## switch_board

* [Homepage](https://rubygems.org/gems/switch_board)
* [Documentation](http://rubydoc.info/gems/switch_board/frames)
* Email - mailto:israbirding at gmail.com

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

````
  require 'switch_board'
````

### Requirements

### Install

````
  $ gem install switch_board
````
### Copyright

Copyright (c) 2013 Avner Cohen

See LICENSE.txt for details.
