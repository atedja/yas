# YAS

YAS (Yet Another Schema) is an extensible hash validator for Ruby.
Using YAS, you can enforce a specific key to be required, rename them, perform automatic type conversion, and other goodies.


## Installation

    gem install yas


## Quick Start

    require 'yas'

    class MySchema < YAS::Schema
      rename :bar => :foo
    end

    h = { bar: "value" }
    h.validate! MySchema
    puts h[:foo]  # "value"
    puts h[:bar]  # nil


## Extensions

You can extend the behavior of YAS by writing your own custom extensions, but `YAS::Schema` already comes with a set of awesome default extensions that you can immediately use:

* `attribute name, &block` or `key name, &block`

  Declares an attribute/key with various requirements.

* `rename`

  Rename keys.

* `migrate`

  Migrate the value of a key.

* `whitelist`

  Provide a set of keys that you only care to see.

* `symbolize`

  Symbolize keys in the hash.

Optionally, you may also use `YAS::SchemaBase` if you want to start off from a clean slate.

### Attribute Extension

The Attribute extension allows you to specify certain requirements/restrictions for a given key:

    class MySchema < YAS::Schema
      key :email do
        required
      end

      key :first_name do
        type String
      end
    end

    hash = { :first_name => 'John' }
    hash.validate! MySchema # raises YAS::ValidationError "Key 'email' is missing"
    hash.merge!(:email => 'john@email.com')
    hash.validate! MySchema # Success!

List of directives you can use:

* `required`

  Sets this key as required. Will raise an error if key is missing.

* `type(T)`

  Sets the type of this key. Will perform type check if specified. Can be nested if type is a `YAS::Schema`!

* `auto_convert`

  Enables auto-conversion to the specified type. This gets ignored if `type` is not specified.

* `default(&block)`

  Runs the block to set the default value for this key, if it's missing or nil.

* `validate_value(&block)`

  Custom validation method to check the value of a key. This is useful in cases where you only want certain values to be stored (e.g a number between 1-10 only)


### Rename Extension

Using `rename` to rename keys. Useful to maintain hash integrity.

    class UserSchema < YAS::Schema
      rename :username => :nickname
    end
    hash = { :username => 'jdoe' } )
    hash.validate!(UserSchema)
    hash[:nickname] # 'jdoe'


### Migrate Extension

You can also migrate the values. This is useful if you have hash whose values are in the old format and you want to convert them to the new format.

    class UserSchema < YAS::Schema
      migrate :nicknames do |v|
        v.class == String ? [v] : v
      end
    end
    hash = { :nicknames => 'jdoe' }
    hash.validate!(UserSchema)
    hash[:nicknames] # ['jdoe']


### Whitelist Extension

Whitelist allows you to remove unneeded keys.

    class UserSchema < YAS::Schema
      whitelist :name, :address
    end
    hash = { :name => 'jdoe', :address => '123 Main St', :phone => '9990000000', :comment => 'JDoe is cool' }
    hash.validate!(UserSchema)
    hash[:name] # ['jdoe']
    hash[:address] # ['123 Main St']
    hash[:phone] # nil
    hash[:comment] # nil


### Symbolize Extension

Symbolize keys in your hash.  This does not perform deep symbolize. See nested Attribute validation if you want deep symbolize.

    class UserSchema < YAS::Schema
      symbolize true
    end
    hash = { 'name' => 'jdoe', 'address' => '123 Main St' }
    hash.validate!(UserSchema)
    hash[:name] # ['jdoe']
