Minidynamo
==============

Monkey patch for AWS ruby SDK HashModel to support models backed by DynamoDB tables with hash-range keys. 

## What's minidynamo for?


As of June 2013 AWS-sdk for ruby HasModel for DynamoDB does not support working with tables having a hash-range main key. Additionally the main key in hash tables is alway called :id. 

Another well known DynamoDB ORM is Dynamoid, but they lack this as well. Most likely because they've built on top of HashModel and hence they are subject to its current functionality.

Having the ability to perform queries in hash-range tables and the recent addition of secondary indexes for this kind of tables, we monkey patched the HashModel class to offer some initial support. 

Depending on when and how Amazon supports this kind of tables, Minidynamo will continue to be supported. Since this gem is very small and mostly based on their own code, we're optimistic that Amazon will implement something similar. In the meantime, we hope this is useful.

Minidynamo offers the following compared to HashModel:

* Definition of tables and initial throughput with class methods á la Rails.
* Custom name(s) for the primary key column(s)
* For hash-range tables find() issues a rangeless query.
* find_by_#{hash_key}() is created by default when the main key hash column name isn't :id
* There's a create table method for each Model that accepts 0 parameteres and only uses the information given in the table definition.

This simple additions, even though still not offering the full range of posibilities for hash-range tables in DynamoDB current API, will cover lots of use cases. We currently use it in more than 3 internal applications. Hash-range + DynamoDB in this applications enable low latency data availability to improve response times in internal components and make scaling a matter of clicks.

## Current limitations

* There's currently no definition of extra indexes.
* Besides rangeless_query to find items in hash-range tables by only providing the hash value, there's no other querying functionality.
* Nothing has been done regarding scoping, scanning or anything related to find more than the rangeless_query method listed below.

## Instructions

Include minidynamo in your Gemfile. 

```ruby
gem 'minidynamo', '~> 0.1.0'
```

Don't forget to do `bundle install` right after.

### Defining a table

```ruby
class TestModel < Minidynamo::Model

	table 	name: "my_table", 
			hash_key: {:my_attribute => :string},
			range_key: {:my_range_name => :string}

	initial_througput read_capacity: 5, write_capacity: 5

	timestamps

	field :custom_field, :string

end
```

With `field` the valid types are those that HashModel offers in the form of `{type}_attr` methods. For example:

* string_attr, hence you can use :string as a type in field
* date_attr, hence you can use :date as a type in field
* integer_attr, hence you can use :integer as a type in field

`field` only calls those methods. This is pure synthactic sugar, but we think it resembles a lot better the way we've become used to see ruby syntax, specially if you come from the Rails world.

timestamps, as any other methods available via HashModel continue to be ready for you to use. You can check more in the [HasModel docs](http://docs.aws.amazon.com/AWSRubySDK/latest/frames.html#!http%3A//docs.aws.amazon.com/AWSRubySDK/latest/AWS/DynamoDB.html).

You can still work with hash-only tables. Just omit the range_key part in the call to `table`.

You could go and create the table by calling `TestModel.create_table`

## Contributing to minidynamo
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so we can cherry-pick around it.


NOTES
====

* only number, binary or string are accepted on the table command types
