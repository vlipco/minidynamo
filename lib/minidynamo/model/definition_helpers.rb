module Minidynamo
	class Model
		module DefinitionHelpers

			# For all the fields with defaults
			attr_writer :write_capacity, :read_capacity

			#attr_accessor :range_key

			def table options = {}
				set_shard_name options[:name]
				self.hash_key = options[:hash_key] unless options[:hash_key].nil?
				self.range_key = options[:range_key] unless options[:range_key].nil?
			end

			#
			# TABLE STRUCTURE HELPERS
			#

			def field key, type, options = {}
				method_name = "#{type.to_s}_attr".to_sym
				send method_name, key, options
			end

			def initial_throughput options = {}
				self.read_capacity = options[:read_capacity]
				self.write_capacity = options[:write_capacity]
			end

			def read_capacity
				@read_capacity || 10
			end

			def write_capacity
				@write_capacity || 10
			end

		end
	end
end