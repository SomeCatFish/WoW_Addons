---------------------------------------------------
-- SA_DataStruct_Up-to-dater_GetLibs
---------------------------------------------------
local SomeBodysUtils;

if LibStub then
	SomeBodysUtils = LibStub:GetLibrary("SomeBodysUtils");
else
	SomeBodysUtils = require("SomeBodysUtils");
end
---------------------------------------------------
-- Variables and Functions
---------------------------------------------------
local currentVersion = 190;
local function UpToDate_Function()
    if StatusAuraVersion < currentVersion or not StatusAuraVersion then
        --================== Version 1.8.0 ==================--
        if StatusAuraVersion < 180 or not StatusAuraVersion then
            local newPool = {};
            for _, aura in pairs(StatAurasDatabase.AurasPool) do
                local auraID = tostring(aura[1]);
                newPool[auraID] = aura;
            end
            StatAurasDatabase.AurasPool = newPool;  -- Update AurasPool
            StatAurasDatabase.NPCAuras = {};        -- Clear NPC auras from (most likely) garbage
        
            if StatAurasSyncModule then
                StatAurasSyncModule.whitelistedSenders = {};
                StatAurasSyncModule.autoWhitelist = true;
                StatAurasSyncModule.whitelistMode = true;
            end
        end
        -------------------------------------------------------

        --================== Version 1.9.0 ==================--
        if StatusAuraVersion < 190 or not StatusAuraVersion then
            if StatAurasSyncModule then
                StatAurasSyncModule.autoWhitelist = true;
                StatAurasSyncModule.whitelistMode = false;
                StatAurasSyncModule.raidMode = true;
            end
        end
        -------------------------------------------------------
        StatusAuraVersion = currentVersion;

    end
end

local function eventHandler(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "StatusAura" then
        UpToDate_Function();
    end
end
---------------------------------------------------
-- Functionality
---------------------------------------------------
local SA_DataStructRefresher_Frame = CreateFrame("Frame");
SA_DataStructRefresher_Frame:RegisterEvent("ADDON_LOADED");

SA_DataStructRefresher_Frame:SetScript("OnEvent", eventHandler);