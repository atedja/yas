# Defines specific rules for keys
#

class YAS::AttributeExt

  module ClassMethods

    def key attr, &block
      attr = attr.to_s.to_sym
      new_attr = Attribute.new(attr)
      new_attr.instance_eval &block if block
      attributes[attr] = new_attr
      new_attr
    end
    alias_method :attribute, :key


    def attributes
      @attributes ||= {}
    end
  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    superschema.attributes.each do |key, attr|
      subschema.attributes[key] = attr
    end
  end


  def self.apply schema, hash
    schema.attributes.each do |key, attr|
      raise YAS::ValidationError, "Key #{key} is required" if attr.required? && !hash.has_key?(key)
      hash.has_key?(key) and
        hash[key] = attr.validate(hash[key])
    end
  end


  class Attribute

    attr_reader :name

    @required = false
    @type = nil
    @auto_convert = false
    @default_block = nil
    @check_value_block = nil


    def initialize name
      @name = name.to_s.to_sym
    end


    # Directive to mark this Attribute as required.
    #
    def required
      @required = true
      self
    end


    def required?
      @required
    end


    # Directive to enforce the data type of this Attribute.
    #
    def type t
      @type = t
      self
    end


    # Attempts to auto convert values to the type specified by the {type}
    # directive if the value is not of the same type.
    # Has no effect if {type} is not specified.
    #
    def auto_convert
      @auto_convert = true
      self
    end


    # Directive to set the default value of this Attribute. Once specified, if
    # this Attribute does not exist during the Document initialization, whether
    # that's from {Document.get} or {Document#initialize}, the value of the
    # Attribute will be set to the value returned by the block.
    #
    # @yield Sets the value of this Attribute to the value returned by the
    #   block.
    #
    def default &block
      @default_block = block
      self
    end


    def has_default?
      @default_block != nil
    end


    # Perform a validation over the value of this Attribute.
    #
    # @yield [v] Value of the Attribute.
    #
    # @example
    #   validate_value { |v| v == "John" }
    #
    def validate_value &block
      @check_value_block = block
      self
    end


    # Check the default value.
    #
    # @param value The value of this attribute to validate.
    #
    def trigger_default_directive
      @default_block.call if has_default?
    end


    # Check value.
    #
    def trigger_content_directive value
      if @check_value_block
        raise YAS::ValidationError, "Content validation error: #{value}" unless
          @check_value_block.call(value)
      end
      value
    end


    # Check type.
    #
    def trigger_type_directive value
      if @type
        # Run auto-conversion first.
        value = trigger_auto_convert_directive(value)

        msg = "Type mismatch for attribute #{@name}"
        if @type == TrueClass || @type == FalseClass
          raise YAS::ValidationError, msg unless !!value == value
        else
          raise YAS::ValidationError, msg unless value.is_a?(@type)
        end
      end

      value
    end


    # Auto convert the value
    #
    def trigger_auto_convert_directive value
      if @auto_convert
        if @type == Integer
          value = Integer(value)
        elsif @type == Float
          value = Float(value)
        elsif @type == String
          value = String(value)
        elsif @type == Array
          value = Array(value)
        elsif @type == Time && !value.is_a?(Time)
          value = Time.parse(value)
        elsif @type == TrueClass || @type == FalseClass
          value = value == "1" || value == 1 || value.to_s.downcase == "true" || value == true ? true : false
        end
      end
      value
    end


    # Validates attribute, except the required directive.
    # First it executes the {default} directive, then {auto_convert} to type,
    # then {type} validation, then finally the {validate} directive.
    #
    # @return The final value after the validation.
    #
    def validate value
      value = trigger_default_directive if value.nil?
      trigger_content_directive(trigger_type_directive(value))
    end

  end
end
