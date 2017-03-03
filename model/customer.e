note
	description: "A customer has a name and an account with a balance"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CUSTOMER
inherit
	COMPARABLE
	redefine is_equal, is_less, out end

create
	make

feature{NONE} -- Creation

	make(a_name:STRING)
			-- Create a customer with an `account'
		local
			l_account: ACCOUNT
			l_name: IMMUTABLE_STRING_8
		do
			l_name := a_name
			name := l_name
			create l_account.make_with_name (a_name)
			account := l_account
		ensure
			correct_name: name ~ a_name
			correct_balance: balance = balance.zero
		end

feature -- queries

	name: IMMUTABLE_STRING_8

	balance: VALUE
		do
			Result := account.balance
		end

	account: ACCOUNT

	is_equal(other: like Current): BOOLEAN
		--redefining is_equal so it is relevant to the customer class so t5 passes.
			do
				--referred to slide 59 for help on syntax
				 Result:= name ~ other.name and balance ~ other.balance
		end


	is_less alias "<" (other: like Current): BOOLEAN
			-- Is current object less than `other'?
		do
			if  name < other.name then
				Result := true
			elseif name ~ other.name and balance < other.balance then
				Result := true
			else
				Result := false
			end
		ensure then
			Result =  (name < other.name)
				or else (name ~ other.name and balance < other.balance )
		end


	out : STRING
			-- Return a sorted list of customers.
		do
			Result := "name: " + name + ", balance: " + balance.out
		end



invariant
	name_consistency: name ~ account.name
	balance_consistency: balance = account.balance
end
