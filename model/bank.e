note
	description: "[
		(1) A Bank consists of many customers.
		There are `count' customers.
		(2) New customers can be added to the bank by name.
		    We never delete a customer record, 
		    even after they leave the bank.
		(3) Each customer shall have a single account at the bank.
		    Initially the balance in the account is zero.
		(4) Money can be deposited to and withdrawn from customer accounts.
		    Money is deposited as a dollar amount, 
		    perhaps with more than two decimal places.
		(5) Money calculations shall be precise 
		  (e.g. adding, subtracting and multiplying 
		  money amounts must be without losing pennies or parts of pennies).
		(6) Money can also be transferred between two customer accounts.
		(7) Balances in accounts shall never be negative.
		(8) Customers are identified by name, 
		    so there cannot be two customers having the same name.	  
		(9) Customers are stored in a list sorted alpahabetically by name.
		(11) The bank has an attribute `total' that stores the total
			of all the balances in the various customer accounts.
			This can be used to check for fraud.
			
			-----------------------------------------
			You will see '--Todo' whereyou must revise
			-----------------------------------------

		]"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	BANK
inherit
	ANY
		redefine out end
create
	make

feature {NONE} -- Initialization
	make
			-- Create a bank
		do
			-- ToDo
			-- This is not guaranteed to be correct
			zero := "0"
			one := "1"
			create {SORTED_TWO_WAY_LIST[CUSTOMER]} customers.make
			customers.compare_objects
			total :="0"
			count := 0
		end

feature -- bank attributes

	-- don't change the bank attributes

	zero, one: VALUE

	count : INTEGER
		-- total number of bank customers

	total: VALUE
		-- total of all the balances in the customers accounts

	customers : LIST[CUSTOMER]
		-- list of all bank customers


feature -- Commands using a single account

	-- do not change the precondition and postcondition tags
	-- you may change the part of the contract that comes after the tag
	-- you ma change the routine implemementations

	new (name1: STRING)
			-- Add a new customer named 'name1'
			-- to the end of list `customers'
		require
			customer_not_already_present: not customer_exists(name1)

		local
			person: CUSTOMER
		do

			create person.make (name1)
			customers.extend(person)
			count := count+1

		ensure
			total_balance_unchanged:
				sum_of_all_balances = old sum_of_all_balances
			num_customers_increased:
				count = old count +1 --better check than count > old count
			total_unchanged:
				total ~ old total
			customer_added_to_list:
				customer_exists (name1)
				and then customers[customer_id (name1)].name ~ name1
				and then customers[customer_id (name1)].balance ~ zero
			other_customers_unchanged:
				customers_unchanged_other_than(name1, old customers.deep_twin)
		end

	deposit(a_name:STRING; a_value: VALUE)
			-- Deposit an amount of 'a_value' into account owned by 'a_name'.
		require
			customer_exists:
				customer_exists(a_name)
			positive_amount:
				a_value.is_greater (zero)

		do

			customer_with_name(a_name).account.deposit (a_value)
			total := total.add (a_value)


		ensure
			deposit_num_customers_unchanged:
				count = old count
			total_increased:
				total ~ old total.add (a_value)
			deposit_customer_balance_increased:
				customer_with_name(a_name).balance > old customer_with_name(a_name).balance
			deposit_other_customers_unchanged:
				customers_unchanged_other_than(a_name, old customers.deep_twin)
			total_balance_increased:
				sum_of_all_balances ~ old sum_of_all_balances.add(a_value)
		end

	withdraw (a_name:STRING; a_value: VALUE)
			-- Withdraw an amount of 'a_value' from account owned by 'a_name'.
		require
			customer_exists:
				customer_exists(a_name)
			positive_amount:
				a_value.is_greater (zero)
			sufficient_balance:
				a_value.is_less_equal (current.customer_with_name(a_name).balance)
		do
			customer_with_name(a_name).account.withdraw (a_value) --current.customer_with....?
			total := total.subtract (a_value)


		ensure
			withdraw_num_customers_unchanged:
				count = old count
			total_decreased:
				total = old total.subtract (a_value)
			withdraw_customer_balance_decreased:
				old customer_with_name(a_name).balance > customer_with_name(a_name).balance
			withdraw_other_customers_unchanged:
				customers_unchanged_other_than(a_name, old customers.deep_twin)
			total_balance_decreased:
				sum_of_all_balances ~ old sum_of_all_balances.subtract (a_value)
		end

feature -- Command using multiple accounts

	transfer (name1: STRING; name2: STRING; a_value: VALUE)
			-- Transfer an amount of 'a_value' from
			-- account `name1' to account `name2'
		require
			distinct_accounts:
				name1 /~ name2
			customer1_exists:
				current.customer_exists (name1)
			customer2_exists:
				current.customer_exists (name2)
			sufficient_balance:
				a_value.is_less_equal (current.customer_with_name (name1).balance)
		do
			current.withdraw (name1, a_value)
			current.deposit (name2, a_value)


		ensure
			same_total:
				total ~ old total
			same_count:
				count = old count --~ ?
			total_balance_unchanged:
				sum_of_all_balances = old sum_of_all_balances
			customer1_balance_decreased:
				current.customer_with_name (name1).balance.is_less_equal (old current.customer_with_name (name1).balance)
			customer2_balance_increased:
				current.customer_with_name(name2).balance.is_greater_equal (old current.customer_with_name (name2).balance)
			other_customers_unchanged:
			customers_unchanged_both(name1,name2, old customers.deep_twin)
		end

feature -- queries for contracts

	-- You may find the following queries helpful.
	-- Change them as necessary, or add your own
	-- if you add your own, contract them, and test them

	sum_of_all_balances : VALUE
			-- Summation of the balances in all customer accounts
		do
			from
				Result := Result.zero
				customers.start
			until
				customers.after
			loop
				Result := Result + customers.item.balance
				customers.forth
			end
		ensure
			comment("Result = (SUM i : 1..count: customers[i].balance)")
		end

	customer_exists(a_name: STRING): BOOLEAN
			-- Is customer `a_name' in the list?
		do
			from
				customers.start
			until
				customers.after or Result
			loop
				if customers.item.name ~ a_name then
					Result := true
				end
				customers.forth
			end
		ensure
			comment("EXISTS c in customers: c.name = a_name")
		end

	customer_id(a_name:STRING):INTEGER
			-- return index of `a_name' into customers

			local

				stop : BOOLEAN
				i : INTEGER
		do
			i:=1
			from customers.start
			until customers.after or stop
			loop
				if customers.item.name ~ a_name then
					stop := true
					else
						i := i+1
						customers.forth
				end
			end
			Result := i
		end

	customer_with_name (a_name: STRING): CUSTOMER
			-- return customer with name `a_name'
		require
			customer_exists (a_name)
		local

				stop : BOOLEAN
				c : CUSTOMER
		do
			Result := customers[1]
			-- The above is needed to remove the VEVI compile error
			-- of void safety

			from customers.start
			until customers.after or stop
			loop
				if customers.item.name ~ a_name then
					stop := true
					else
						customers.forth

				end
			end
			c := customers.item
			Result := c


		ensure
			correct_Result: Result.name ~ a_name
		end

	customers_unchanged_other_than (a_name: STRING; old_customers: like customers): BOOLEAN
			-- Are customers other than `a_name' unchanged?
		local
			c_name: STRING
		do
			from
				Result := true
				customers.start
			until
				customers.after or not Result
			loop
				c_name := customers.item.name
				if c_name /~ a_name then
					Result := Result and then
						old_customers.has (customers.item)
				end
				customers.forth
			end
		ensure
			Result =
				across
					customers as c
				all
					c.item.name /~ a_name IMPLIES
						old_customers.has (c.item)
				end
		end


	customers_unchanged_both(name1: STRING; name2: STRING; old_customers: like customers): BOOLEAN
	--slight change to check both name 1 and name 2
		local
			c_name: STRING
		do
			from
				Result := true
				customers.start
			until
				customers.after or not Result
			loop
				c_name := customers.item.name
				if c_name /~ name1 and c_name /~ name2 then
					Result := Result and then
						old_customers.has (customers.item)
				end
				customers.forth
			end
		ensure
			Result =
				across
					customers as c
				all
					c.item.name /~ name1 and c.item.name /~ name2 IMPLIES
						old_customers.has (c.item)
				end
		end
feature -- invariant queries
	unique_customers: BOOLEAN
		do
			-- ToDo


		ensure
			Result = across
				1 |..| count as i
			all
				across 1 |..| count as j
				all
					customers[i.item] ~ customers[j.item]
					implies i.item = j.item
				end
			end
		end
feature -- Queries on string representation.

	customers_string: STRING
			-- Return printable state of `customers'.
		local
			sorted_customers: TWO_WAY_LIST[CUSTOMER]
		do
			create sorted_customers.make
			across
				customers as c
			loop
				sorted_customers.extend (c.item)
			end

			create Result.make_empty
			across
				sorted_customers as c
			loop
				Result := Result + c.item.out + "%N"
			end
		end


	out : STRING
			-- Return a sorted list of customers.
		do
			Result := customers_string
		end

	comment(s:STRING): BOOLEAN
		do
			Result := true
		end

invariant
	value_constraints:
		zero = zero.zero and one = one.one
	consistent_count:
		count = customers.count
	consistent_total:
		total = sum_of_all_balances

	customer_names_unique: --ToDo
		comment("Need some invariant here")
		-- cannot have duplicate names in `customers'

	customers_are_sorted: --ToDo
		comment("Need some invariant here")
		-- customers must be in sorted order
end



--%Exported from SVN%
--%2017-01-16:17:31:10%
--%narbehn%
