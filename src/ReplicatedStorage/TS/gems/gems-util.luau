-- GemsUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local GameProducts = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").GameProducts

type GemProduct = {
	GemsReward: number,
	ProductId: string,
}

type GemsUtil = {
	getRequiredGemsProduct: (currentGems: number, requiredGems: number) -> string,
}

local gemProductIndex = 0
local sortedGemProducts: { GemProduct } = {}
local GemsUtil: GemsUtil = {}

for productIndex, product in ObjectUtils.values(GameProducts) do
	local _ = productIndex - 1
	if product.GemsReward ~= nil == true then
		gemProductIndex = gemProductIndex + 1
		sortedGemProducts[gemProductIndex] = product
	end
end

table.sort(sortedGemProducts, function(productA, productB)
	return productA.GemsReward < productB.GemsReward
end)

function GemsUtil.getRequiredGemsProduct(currentGems: number, requiredGems: number): string
	local gemsNeeded = requiredGems - currentGems
	for _, product in sortedGemProducts do
		if gemsNeeded <= product.GemsReward then
			return product.ProductId
		end
	end
	return sortedGemProducts[#sortedGemProducts].ProductId
end

return {
	["GemsUtil"] = GemsUtil
}
