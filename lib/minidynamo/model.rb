# Based on AWS::Record::HashModel from aws-sdk gem. 
# Check the license file included in this gem or the original version at:
# http://aws.amazon.com/apache2.0/

module Minidynamo 
	class Model < AWS::Record::HashModel

		require 'minidynamo/model/keys'
		require 'minidynamo/model/definition_helpers'
		require 'minidynamo/model/dynamo_db_overloads'
		require 'minidynamo/model/finder_overloads'

		#require 'aws/record/hash_model/attributes'
		#require 'aws/record/hash_model/finder_methods'
		#require 'aws/record/hash_model/scope'

		#extend AWS::Record::AbstractBase
		
		extend Keys
		extend DefinitionHelpers
		extend DynamoDBOverloads
		extend FinderOverloads



		class << self

			#

		end

		#private
		#def create_storage
		#	attributes = serialize_attributes.merge('id' => @_id)
		#	dynamo_db_table.items.create(attributes, opt_lock_conditions)
		#end
#
		#private
		#def update_storage
		#	# Only enumerating dirty (i.e. changed) attributes.  Empty
		#	# (nil and empty set) values are deleted, the others are replaced.
		#	dynamo_db_item.attributes.update(opt_lock_conditions) do |u|
		#		changed.each do |attr_name|
		#			attribute = self.class.attribute_for(attr_name)
		#			value = serialize_attribute(attribute, @_data[attr_name])
		#			if value.nil? or value == []
		#				u.delete(attr_name)
		#			else
		#				u.set(attr_name => value)
		#			end
		#		end
		#	end
		#end
#
		#private
		#def delete_storage
		#	dynamo_db_item.delete(opt_lock_conditions)
		#end
#
		#private
		#def deserialize_item_data data
		#	data.inject({}) do |hash,(attr_name,value)|
		#		if attribute = self.class.attributes[attr_name]
		#			hash[attr_name] = value.is_a?(Set) ?
		#			value.map{|v| attribute.deserialize(v) } :
		#			attribute.deserialize(value)
		#		end
		#		hash
		#	end
		#end

	end

end
