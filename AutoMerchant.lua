-- Automate merchant interactions with junk selling and repair

local YELLOW_LIGHT_LUA = "|cFFFDE89B"

local merchantState = {
	junkSold = false,
	itemsRepaired = false,
	confirmationsShown = false
}

local function sellJunkItems()
	local hasJunk = false
	for bagIndex = 0, 4 do
		for slotIndex = 1, GetContainerNumSlots(bagIndex) do
			local itemLink = GetContainerItemLink(bagIndex, slotIndex)
			if itemLink then
				local _, _, itemRarity = GetItemInfo(itemLink)
				if itemRarity == 0 then
					UseContainerItem(bagIndex, slotIndex)
					hasJunk = true
				end
			end
		end
	end
	return hasJunk
end

local function repairPlayerItems()
	if not CanMerchantRepair() then
		return false
	end

	local repairCost, canRepair = GetRepairAllCost()
	if canRepair and repairCost > 0 then
		RepairAllItems()
		return true
	end
	return false
end

local function displayConfirmations()
	if merchantState.junkSold then
		print(YELLOW_LIGHT_LUA .. "[Merchant]:|r Junk Items sold.")
	end
	if merchantState.itemsRepaired then
		print(YELLOW_LIGHT_LUA .. "[Merchant]:|r Items repaired.")
	end
end

local function handleMerchantVisit()
	merchantState.junkSold = sellJunkItems()
	merchantState.itemsRepaired = repairPlayerItems()

	C_Timer.After(0, function()
		if not merchantState.confirmationsShown then
			displayConfirmations()
			merchantState.confirmationsShown = true
		end
	end)
end

local merchantFrame = CreateFrame("Frame")
merchantFrame:RegisterEvent("MERCHANT_SHOW")
merchantFrame:SetScript("OnEvent", function()
	merchantState = { junkSold = false, itemsRepaired = false, confirmationsShown = false }
	handleMerchantVisit()
end)
