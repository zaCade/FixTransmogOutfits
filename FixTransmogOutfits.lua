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

-- Store the original set function.
local OriginalSetPending = OriginalSetPending or C_Transmog.SetPending;

-- Overwrite the function.
function C_Transmog.SetPending(slotID, transmogType, visualSourceID)
	-- Since for example selecting a different legion artifact skin doesn't actually unlock the save button,
	-- we'll have to tell it there has been an update, so it unlocks.

	-- Check if the outfit dropdown exists.
	if WardrobeTransmogFrame and WardrobeTransmogFrame.OutfitDropDown then
		-- It exists, tell it to update the save button.
		WardrobeTransmogFrame.OutfitDropDown:UpdateSaveButton();
	end

	-- Call the original function.
	OriginalSetPending(slotID, transmogType, visualSourceID);
end

-- Store the original save function.
local OriginalSaveOutfit = OriginalSaveOutfit or C_TransmogCollection.SaveOutfit;

-- Overwrite the function.
function C_TransmogCollection.SaveOutfit(name, outfit, enchantOne, enchantTwo, icon)
	-- Since legion artifacts for example save as 0 instead of their actual visual id,
	-- we'll have to loop over the entire outfit table, and correct it.

	-- Check if we have an outfit to save.
	if outfit then
		-- We are saving an outfit, loop over its slots.
		for slotID = 0, #outfit do
			-- Check if we are saving something in this slot.
			if outfit[slotID] then
				-- We are saving in this slot, update it.
				outfit[slotID] = GetSlotVisualSourceID(slotID, LE_TRANSMOG_TYPE_APPEARANCE);
			end
		end
	end

	-- Call the original function.
	OriginalSaveOutfit(name, outfit, enchantOne, enchantTwo, icon);
end