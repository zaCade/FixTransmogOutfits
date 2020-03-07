if not C_Transmog or not C_TransmogCollection then return end

-- Function to retrieve the actual visualSourceID for a slot.
local function GetSlotVisualSourceID(slot, transmogType)
	local visualSourceID;
	local baseSourceID, _, appliedSourceID, _, pendingSourceID, _, hasPendingUndo = C_Transmog.GetSlotVisualInfo(slot, transmogType);

	if hasPendingUndo then
		visualSourceID = baseSourceID;
	elseif pendingSourceID ~= 0 then
		visualSourceID = pendingSourceID;
	elseif appliedSourceID ~= 0 then
		visualSourceID = appliedSourceID;
	else
		visualSourceID = baseSourceID;
	end

	return visualSourceID;
end

-- Store the original save function.
local OriginalSaveOutfit = OriginalSaveOutfit or C_TransmogCollection.SaveOutfit;

-- Overwrite the function.
function C_TransmogCollection.SaveOutfit(name, outfit, enchantOne, enchantTwo, icon)
	-- Checking for nil, just to make sure.
	if outfit then
		-- Are we saving something to slot 16 (main hand) and 17 (off hand)?
		-- If we are, check what we are actually changing to because for some odd reason it changes legion artifact skins as 0.
		if outfit[16] then outfit[16] = GetSlotVisualSourceID(16, LE_TRANSMOG_TYPE_APPEARANCE) end
		if outfit[17] then outfit[17] = GetSlotVisualSourceID(17, LE_TRANSMOG_TYPE_APPEARANCE) end
	end

	-- Call the original function.
	OriginalSaveOutfit(name, outfit, enchantOne, enchantTwo, icon);
end