require 'aws-sdk'

def precede_with_check(x)
	check_digit = CheckDigit.calculate_check_digit(x)
	"#{check_digit}#{x}"
end


module Minidynamo


	# Wrap some HashModel behaviour and offers minor overrides for readability
	# and to create tables using ranges.
	class Model < AWS::Record::HashModel

		class << self

			# For all the fields with defaults
			attr_writer :write_capacity, :read_capacity

			attr_accessor :range_key

			# Use the client table creator instead of the HashModel inheritance
			def create_table
				# TODO verify it's not already created

	          create_opts = {}
	          create_opts[:hash_key] = hash_key
	          create_opts[:range_key] = range_key if range_key
	          

	          dynamo_db.tables.create 	dynamo_db_table_name,
							            read_capacity,
							            write_capacity,
							            create_opts

	        end

	        # Obtain the DynamoDB status of a table
	        def status
	        end

	        def count_total
	        	
	        	initial_q = dynamo_db.client.scan 	:table_name => dynamo_db_table_name, 
		        									:count => true
	        	count = initial_q["Count"]
	        	if initial_q["LastEvaluatedKey"]
	        		last = initial_q["LastEvaluatedKey"]
		        	begin 
		        		q = dynamo_db.client.scan 	:table_name => dynamo_db_table_name, 
		        									:count => true,
		        									:exclusive_start_key => last
		        		count += q["Count"]
		        		last = q["LastEvaluatedKey"]
		        	end while last
		        end
		        count
	        	
			end

			def ddb_client
				@client ||= AWS::DynamoDB.new.client
			end

	        

	        #
	        # TABLE THROUGHPUT HELPERS
	        #

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

	        def hash_key
	        	@hash_key || {:id => :string}
	        end

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
	        	puts "CALLING #{method_name}"
	        	send method_name, key, options
	        end

	        def hash_key=(key)
	        	@hash_key = key
	        	hk = key.keys[0]
	        	finder_method_name = "find_by_#{hk}".to_sym	        	
				self.define_singleton_method finder_method_name do |x|
					find_by_id x
				end
				type = key[hk]
				attribute_creator_method_name = "#{type.to_s}_attr".to_sym
				puts "CREATING HASH KEY ATTR #{attribute_creator_method_name}"
				send attribute_creator_method_name, hk
			end

	        # OVERLOAD THE FINDER TO USE CUSTOM HASK KEYS IN ERRORS

	        alias_method :_find_by_id, :find_by_id
	        alias_method :_find, :find

#data = table.items[id].attributes.to_h
#
#raise RecordNotFound, "no data found for id: #{id}" if data.empty?
#
#obj = self.new(:shard => table)
#obj.send(:hydrate, id, data)
#obj
#
#.query :table_name => "sample-table", :consistent_read => true, :hash_key_value => {:s => "123"} 

	        def find *args
	        	# If find(id), determine wether a query or regular find will work
	        	# convert the first argument to integer, if it's a string it'll yield 0
	        	
	        	# if the first argument is an integer and this is a table with range as main key
	        	if args.length == 1 && !args[0].is_a?(Symbol) && hash_range_table?
	        		items = rangeless_query args[0]
	        		case items.length
	        		when 0
	        			raise AWS::Record::RecordNotFound, "no data found for #{hash_key.keys[0]}: #{args[0]}"  
	        		when 1
	        			return items[0]
	        		else
	        			return items
	        		end
          		end

          		#in any other case fall back to the default HashModel
          		new_scope.find(*args)
        	end

        	# converts string > s, numeric > n
        	def hash_key_type
	        	dynamo_db_table.hash_key.type.to_s.chars.first.to_sym
        	end

        	def rangeless_query(*args)
        		# Map to string if that's the case. For any other type of hash_key
        		# you will have to provide the converted value or errors might appear
        		hash_key_type == :s ? hkv = args[0].to_s : hkv = args[0]
        		result = dynamo_db.client.query :table_name => dynamo_db_table_name, 
        								:consistent_read => true, 
        								:hash_key_value => {hash_key_type => hkv} 

        		# Convert the result to items
        		hashed_items = result["Items"]
        		items = []
        		hashed_items.each do |i|
        			i_data = {}
        			i.each do |k,v|
        				# Obtain the first key for the hash describing the value of a DDB column
        				k_data_type = i[k].keys[0]
	        			i_data[k] = i[k][k_data_type]
	        		end
	        		pt = PublicToken.new
	        		pt.send :hydrate, i_data["id"], i_data
	        		items << pt
	        	end
        		items
        	end

        	def hash_range_table?
        		! hash_key.nil?
        	end

	        def find_by_id *args
	        	begin
	        		hash_range_table? ? rangeless_query(args) : _find_by_id(args)
					
				rescue AWS::Record::RecordNotFound
					raise AWS::Record::RecordNotFound, "no data found for #{hash_key}: #{id}" 
				end
	        end

	    end
	end
end