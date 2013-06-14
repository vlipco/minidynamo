module Minidynamo
	class Model
		module DynamoDBOverloads

			def self.extended base
				base.send(:extend, ClassMethods)
				base.send(:include, InstanceMethods)
			end

			module ClassMethods

				# Changed: Don't accept parameters when creating, use the declared options
				# inside the model
				def create_table
					create_opts = {}
					create_opts[:hash_key] = hash_key
					create_opts[:range_key] = range_key if range_key

					dynamo_db.tables.create   dynamo_db_table_name,
					read_capacity,
					write_capacity,
					create_opts
				end

				# @return [DynamoDB::Table]
				# changed to use hash key other than id
				# @api private
				def dynamo_db_table shard_name = nil
					table = dynamo_db.tables[dynamo_db_table_name(shard_name)]
					#table.hash_key = hash_key #[:id, :string]
					#table.range_key = range_key if range_key

					#table.hash_key = {:public_token => :string }#hash_key #[:id, :string]
					#table.range_key = {:created_at => :string }#hash_key #[:id, :string]

					table.hash_key = [:public_token, :string]
					table.range_key = [:created_at, :string]
					table
				end


			end

			module InstanceMethods

				def serialize_current attr_name
					serialized_value = attributes[attr_name]
					attr_object = self.class.attribute_for(attr_name)
					serialize_attribute attr_object, serialized_value
				end

				# @return [DynamoDB::Item] Returns a reference to the item as stored in
				#   simple db.
				# obtain items ALSO if there's a range key
				# @api private
				private
				def dynamo_db_item
					hash_value = serialize_current self.class.hash_key_attribute_name
					if self.class.range_key
						range_value = serialize_current self.class.range_key_attribute_name
						dynamo_db_table.items[hash_value, range_value]
					else
						dynamo_db_table.items[hash_value]
					end
				end

			end

		end
	end
end