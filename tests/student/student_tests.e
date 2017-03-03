note
	description: "Studenst write their tessts here"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STUDENT_TESTS

inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			add_violation_case (agent t1)
			add_violation_case (agent t2)
			add_violation_case (agent t3)
		end

feature -- tests
	t1

			local
			b: BANK
--			l_cst: LIST[CUSTOMER]
		do
			comment ("t1: check whether transfer is negative ")
			create b.make
			b.new ("Steve")
			b.new ("Ben")
			b.deposit ("Steve", "100")
			b.transfer ("Steve","Ben", "-100")
--			l_cst := b.customers
--			Result := l_cst[1].name ~ "Ben"
--				and l_cst[2].name ~ "Steve"
--				and l_cst[1].balance = "0"
--				and l_cst[2].balance = "100"
--			check Result end
			sub_comment("<br>Customers are sorted by name")

			--Result := false
		end


	t2
		local
			b: BANK
		do
			comment ("t2:")
			create b.make
			b.new ("Same")
			b.new ("Same")
			--b.deposit ("Same", "100")

		end

	t3
	local
		b: BANK
		do
			comment ("t3: withdraw from empty")
			create b.make
			b.new("Steve")
			b.withdraw("Steve", "1000")

		end
end
