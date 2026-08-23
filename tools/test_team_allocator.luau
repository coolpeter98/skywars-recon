-- test_team_allocator.luau — Lune unit tests for queue party placement.

local TeamAllocator = require("../src/ServerScriptService/server/modes/TeamAllocator")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

local function sameTeam(assignments, party)
	local teamId = assignments[tostring(party[1])]
	for _, userId in party do
		if assignments[tostring(userId)] ~= teamId then
			return false
		end
	end
	return teamId ~= nil
end

do
	local parties = { { 1, 2 }, { 3, 4 }, { 5, 6 } }
	local assignments = TeamAllocator.assignParties(parties, { "Red", "Blue", "Green" }, 2)
	check(assignments ~= nil, "three duos fit into three two-player teams")
	check(sameTeam(assignments, parties[1]), "first party stays together")
	check(sameTeam(assignments, parties[2]), "second party stays together")
	check(sameTeam(assignments, parties[3]), "third party stays together")
end

do
	local assignments = TeamAllocator.assignParties({ { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8 } }, { "A", "B" }, 4)
	check(assignments == nil, "an impossible whole-party packing is rejected")
end

do
	local assignments = TeamAllocator.assignParties({ { 1, 2, 3, 4, 5 } }, { "A", "B" }, 4)
	check(assignments == nil, "a party larger than the team size is rejected")
end

do
	local assignments = TeamAllocator.assignParties({ { 1, 2, 3 }, { 4 }, { 5, 6 } }, { "A", "B" }, 3)
	check(assignments ~= nil, "allocator finds a valid packing")
	check(sameTeam(assignments, { 1, 2, 3 }), "the largest party stays together")
	check(sameTeam(assignments, { 5, 6 }), "the two-player party stays together")
end

do
	local assignments = TeamAllocator.assignParties(
		{ { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8 }, { 9, 10 }, { 11, 12 } },
		{ "A", "B" },
		6
	)
	check(assignments ~= nil, "backtracking finds the non-greedy 3+3 / 2+2+2 packing")
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
