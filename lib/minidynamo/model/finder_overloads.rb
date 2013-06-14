module Minidynamo
	class Model
		module FinderOverloads

			def find_by_id id, options = {}

				table = dynamo_db_table(options[:shard])

				data = table.items[id].attributes.to_h

				raise RecordNotFound, "no data found for id: #{id}" if data.empty?

				obj = self.new(:shard => table)
				obj.send(:hydrate, id, data)
				obj
			end

			alias_method :[], :find_by_id
			
			#def find *args
			#	new_scope.find(*args)
			#end

			def find *args
				# If find(id), determine wether a query or regular find will work
				# convert the first argument to integer, if it's a string it'll yield 0

				# if the first argument is an integer and this is a table with range as main key
				if args.length == 1 && !args[0].is_a?(Symbol) && hash_range_table?
					items = rangeless_query args[0]
					case items.length
					when 0
						raise AWS::Record::RecordNotFound, "no data found for #{hash_key_attribute}: #{args[0]}"  
					when 1
						return items[0]
					else
						return items
					end
				end

				#in any other case fall back to the default HashModel
				new_scope.find(*args)
			end

			def rangeless_query(*args)
				hkv = args[0]
				result = dynamo_db.client.query 	:table_name => dynamo_db_table_name, 
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
					#puts "SEL CLASS #{self.class}"

					pt = new
					pt.send :hydrate, i_data["id"], i_data
					items << pt
				end

				items
			end

		end
	end
end