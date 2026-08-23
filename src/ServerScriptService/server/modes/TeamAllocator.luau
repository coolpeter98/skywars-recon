--!strict

local TeamAllocator = {}

function TeamAllocator.assignParties(
	parties: { { number } },
	teamIds: { string },
	teamSize: number
): { [string]: string }?
	if teamSize < 1 or #teamIds == 0 then
		return nil
	end
	local sortedParties = table.clone(parties)
	table.sort(sortedParties, function(left, right)
		return #left > #right
	end)
	local remaining = {}
	for index = 1, #teamIds do
		remaining[index] = teamSize
	end
	local placements = {}
	local failedStates = {}
	local function search(partyIndex: number): boolean
		if partyIndex > #sortedParties then
			return true
		end
		local normalizedRemaining = table.clone(remaining)
		table.sort(normalizedRemaining)
		local stateKey = tostring(partyIndex) .. ":" .. table.concat(normalizedRemaining, ",")
		if failedStates[stateKey] then
			return false
		end
		local partySize = #sortedParties[partyIndex]
		local triedCapacities = {}
		for teamIndex, capacity in remaining do
			if capacity >= partySize and not triedCapacities[capacity] then
				triedCapacities[capacity] = true
				remaining[teamIndex] -= partySize
				placements[partyIndex] = teamIndex
				if search(partyIndex + 1) then
					return true
				end
				remaining[teamIndex] += partySize
				placements[partyIndex] = nil
			end
		end
		failedStates[stateKey] = true
		return false
	end
	if not search(1) then
		return nil
	end
	local assignments = {}
	for partyIndex, party in sortedParties do
		local teamId = teamIds[placements[partyIndex]]
		for _, userId in party do
			assignments[tostring(userId)] = teamId
		end
	end
	return assignments
end

return TeamAllocator
