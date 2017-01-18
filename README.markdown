# YAS

YAS (Yet Another Schema) is an extensible hash validator for Ruby used to maintain hash integrity.
Using YAS, you can enforce a specific key to be required, rename them, perform automatic type conversion, and other goodies.


## Installation

    gem install yas
    require 'yas'


## Quick Example

    require 'yas'

    class MySchema < YAS::Schema
      rename :bar => :foo
    end

    h = { bar: "value" }
    h.validate! MySchema
    h[:foo]  # "value"
    h[:bar]  # nil


## Extensions

You can extend the behavior of YAS by writing your own custom extensions.
`YAS::Schema` already comes with a set of awesome default extensions that you can immediately use.
Optionally, you may also use `YAS::SchemaBase` if you want to start off from a clean slate.


### Default Extensions


#### Attribute

Declares an attribute/key with various requirements.
The Attribute extension allows you to specify certain requirements/restrictions for a given key.
`attribute` and `key` are aliases, you can use either one.

    attribute name, &block
    key name, &block

Example:

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

You can also specify multiple keys per `key`/`attribute` block.

    class MySchema < YAS::Schema
      attribute :email, :first_name do
        required
        type String
      end
    end

List of directives you can use:

* `required`

  Sets this key as required. Will raise an error if key is missing.

* `type(T)`

  Sets the type of this key. Will perform type check if specified. Can be nested if type is a `YAS::Schema`!

* `auto_convert`

  Enables auto-conversion to the specified type. This gets ignored if `type` is not specified.

* `default(&block)`

  Runs the block to set the default value for this key, if it's missing or nil.

* `alter(&block)`

  Adjust the value of this key. Can be useful if you want to enforce certain formatting, such as upper/lowercase, unique arrays, etc.
  Value returned by block will be used as the new value for this key, which then gets validated by the `validate_value` block.

* `validate_value(&block)`

  Custom validation method to check the value of a key. This is useful in cases where you only want certain values to be stored (e.g a number between 1-10 only).
  Return true to indicate value passes validation, false for fail.


#### Rename

Using `rename` to rename keys.

    rename :from => :to

Example:

    class UserSchema < YAS::Schema
      rename :username => :nickname
    end
    hash = { :username => 'jdoe' } )
    hash.validate!(UserSchema)
    hash[:nickname] # 'jdoe'


#### Migrate

Migrate the value of a key. This is useful if you have keys whose values are in the old format and you want to convert them to the new format.

    migrate :key, &block 

Example:

    class UserSchema < YAS::Schema
      migrate :nicknames do |v|
        v.class == String ? [v] : v
      end
    end
    hash = { :nicknames => 'jdoe' }
    hash.validate!(UserSchema)
    hash[:nicknames] # ['jdoe']


#### Whitelist

Whitelist allows you to remove unneeded keys.

    whitelist [keys]

Example:

    class UserSchema < YAS::Schema
      whitelist :name, :address
    end
    hash = { :name => 'jdoe', :address => '123 Main St', :phone => '9990000000', :comment => 'JDoe is cool' }
    hash.validate!(UserSchema)
    hash[:name] # ['jdoe']
    hash[:address] # ['123 Main St']
    hash[:phone] # nil
    hash[:comment] # nil


#### Symbolize

Symbolize keys in your hash.
This does not perform deep symbolize. See `type` in the Attribute section for if you want deep symbolize.

    symbolize true|false

Example:

    class UserSchema < YAS::Schema
      symbolize true
    end
    hash = { 'name' => 'jdoe', 'address' => '123 Main St' }
    hash.validate!(UserSchema)
    hash[:name] # ['jdoe']


#### Duplicate

Duplicate the values of a key.

    duplicate :source => :destination

Example:

    class UserSchema < YAS::Schema
      duplicate :name => :first_name
    end
    hash = { :name => 'john' }
    hash.validate!(UserSchema)
    hash[:name] # 'john'
    hash[:first_name] # 'john'
