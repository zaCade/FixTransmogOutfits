if not WardrobeOutfitDropDownMixin then return end

-- Since original functions use a function 'IsSourceArtifact()' that is local to WardrobeOutfits.lua, we have to overwrite them.
-- Therefor the code below are exact duplicates of the original blizzard code, just without the function mentioned above.

-- WardrobeOutfits.lua @ #93
function WardrobeOutfitDropDownMixin:IsOutfitDressed()
	if ( not self.selectedOutfitID ) then
		return true;
	end
	local appearanceSources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetOutfitSources(self.selectedOutfitID);
	if ( not appearanceSources ) then
		return true;
	end

	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		if transmogSlot.location:IsAppearance() then
			local sourceID = self:GetSlotSourceID(transmogSlot.location);
			local slotID = transmogSlot.location:GetSlotID();
			if ( sourceID ~= NO_TRANSMOG_SOURCE_ID and sourceID ~= appearanceSources[slotID] ) then
				if ( appearanceSources[slotID] ~= NO_TRANSMOG_SOURCE_ID ) then
					return false;
				end
			end
		end
	end
	local mainHandIllusionTransmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.None);
	local mainHandSourceID = self:GetSlotSourceID(mainHandIllusionTransmogLocation);
	if ( mainHandSourceID ~= mainHandEnchant ) then
		return false;
	end
	local offHandIllusionTransmogLocation = TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.None);
	local offHandSourceID = self:GetSlotSourceID(offHandIllusionTransmogLocation);
	if ( offHandSourceID ~= offHandEnchant ) then
		return false;
	end
	return true;
end

-- WardrobeOutfits.lua @ #127
function WardrobeOutfitDropDownMixin:CheckOutfitForSave(name)
	local sources = { };
	local mainHandEnchant, offHandEnchant;
	local pendingSources = { };

	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		local sourceID = self:GetSlotSourceID(transmogSlot.location);
		if ( sourceID ~= NO_TRANSMOG_SOURCE_ID ) then
			if ( transmogSlot.location:IsAppearance() ) then
				local slotID = transmogSlot.location:GetSlotID();
				local isValidSource = C_TransmogCollection.PlayerKnowsSource(sourceID);
				if ( not isValidSource ) then
					local isInfoReady, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID);
					if ( isInfoReady ) then
						if ( canCollect ) then
							isValidSource = true;
						end
					else
						pendingSources[sourceID] = slotID;
					end
				end
				if ( isValidSource ) then
					sources[slotID] = sourceID;
				end
			elseif ( transmogSlot.location:IsIllusion() ) then
				if ( transmogSlot.location:IsMainHand() ) then
					mainHandEnchant = sourceID;
				else
					offHandEnchant = sourceID;
				end
			end
		end
	end

	-- store the state for this save
	WardrobeOutfitFrame.sources = sources;
	WardrobeOutfitFrame.mainHandEnchant = mainHandEnchant;
	WardrobeOutfitFrame.offHandEnchant = offHandEnchant;
	WardrobeOutfitFrame.pendingSources = pendingSources;
	WardrobeOutfitFrame.name = name;
	-- save the dropdown
	WardrobeOutfitFrame.popupDropDown = self;

	WardrobeOutfitFrame:EvaluateSaveState();
end