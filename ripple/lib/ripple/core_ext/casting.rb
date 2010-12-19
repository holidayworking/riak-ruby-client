# Copyright 2010 Sean Cribbs, Sonian Inc., and Basho Technologies, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/to_json'
require 'active_support/time_with_zone'

# @private
class Object
  def self.ripple_cast(value)
    value
  end
end

# @private
class Symbol
  def self.ripple_cast(value)
    return nil if value.blank?
    value.respond_to?(:to_s) && value.to_s.intern or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

# @private
class Numeric
  def self.ripple_cast(value)
    return nil if value.blank?
    raise Ripple::PropertyTypeMismatch.new(self,value) unless value.respond_to?(:to_i) && value.respond_to?(:to_f)
    float_value = value.to_f
    int_value = value.to_i
    float_value == int_value ? int_value : float_value
  end
end

# @private
class Integer
  def self.ripple_cast(value)
    return nil if value.nil? || (String === value && value.blank?)
    !value.is_a?(Symbol) && value.respond_to?(:to_i) && value.to_i or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

# @private
class Float
  def self.ripple_cast(value)
    return nil if value.nil? || (String === value && value.blank?)
    value.respond_to?(:to_f) && value.to_f or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

# @private
class String
  def self.ripple_cast(value)
    return nil if value.nil?
    value.respond_to?(:to_s) && value.to_s or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

boolean_cast = proc do
  def self.ripple_cast(value)
    case value
    when NilClass
      nil
    when Numeric
      !value.zero?
    when TrueClass, FalseClass
      value
    when /^\s*t/i
      true
    when /^\s*f/i
      false
    else
      value.present?
    end
  end
end

unless defined?(::Boolean)
  # Stand-in for true/false property types.
  module ::Boolean; end
end

::Boolean.module_eval(&boolean_cast)
TrueClass.module_eval(&boolean_cast)
FalseClass.module_eval(&boolean_cast)

# @private
class Time
  def as_json(options={})
    self.utc.rfc822
  end

  def self.ripple_cast(value)
    return nil if value.blank?
    value.respond_to?(:to_time) && value.to_time or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

# @private
class Date
  def as_json(options={})
    self.to_s(:rfc822)
  end

  def self.ripple_cast(value)
    return nil if value.blank?
    value.respond_to?(:to_date) && value.to_date or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

# @private
class DateTime
  def as_json(options={})
    self.utc.to_s(:rfc822)
  end

  def self.ripple_cast(value)
    return nil if value.blank?
    value.respond_to?(:to_datetime) && value.to_datetime or raise Ripple::PropertyTypeMismatch.new(self, value)
  end
end

# @private
module ActiveSupport
  class TimeWithZone
    def as_json(options={})
      self.utc.rfc822
    end
  end
end

