---------------------------------------------------
-- SA_Def_GetLibs
---------------------------------------------------
local SomeBodysUtils;

if LibStub then
	SomeBodysUtils = LibStub:GetLibrary("SomeBodysUtils");
else
	SomeBodysUtils = require("SomeBodysUtils");
end
---------------------------------------------------
-- SA_Variables
---------------------------------------------------
StatAuras = {};
StatAuras.Vars = {};
StatAuras.Funcs = {};
if StatAurasDatabase == nil then
	StatAurasDatabase = {};
	StatAurasDatabase.PlayersAuras = {};
	StatAurasDatabase.NPCAuras = {};
	StatAurasDatabase.AurasPool = {
		["1"] = {1, "|cff942727Очки Здоровья|r", "Показатель жизненной силы персонажа.", "Interface\\ICONS\\Spell_Shadow_LifeDrain", "Player_Name", true, ""},
		["2"] = {2, "|cff277E94Очки Энергии|r", "Показатель энергии персонажа.", "Interface\\ICONS\\INV_Elemental_Mote_Mana", "Player_Name", true, ""},
		["3"] = {3, "Очки Брони", "", "Interface\\ICONS\\INV_Shield_06", "Player_Name", true, ""},
		["4"] = {4, "Очки Барьера", "", "Interface\\ICONS\\Spell_Shadow_AntiMagicShell", "Player_Name", true, ""},
		["5"] = {5, "Очки Атаки", "", "Interface\\ICONS\\INV_Sword_04", "Player_Name", true, ""}
	};
end
if StatAurasDatabase.AurasPool == nil or StatAurasDatabase.AurasPool == {} then
	StatAurasDatabase.AurasPool = {
		["1"] = {1, "|cff942727Очки Здоровья|r", "Показатель жизненной силы персонажа.", "Interface\\ICONS\\Spell_Shadow_LifeDrain", "Player_Name", true, ""},
		["2"] = {2, "|cff277E94Очки Энергии|r", "Показатель энергии персонажа.", "Interface\\ICONS\\INV_Elemental_Mote_Mana", "Player_Name", true, ""},
		["3"] = {3, "Очки Брони", "", "Interface\\ICONS\\INV_Shield_06", "Player_Name", true, ""},
		["4"] = {4, "Очки Барьера", "", "Interface\\ICONS\\Spell_Shadow_AntiMagicShell", "Player_Name", true, ""},
		["5"] = {5, "Очки Атаки", "", "Interface\\ICONS\\INV_Sword_04", "Player_Name", true, ""}
	};
end
---------------------------------------------------
-- Slash-команды
---------------------------------------------------
SLASH_SADEF1 = "/sadef" or "/SADEF" or "/saDef";
SlashCmdList.SADEF = function()
	local menu = Def_SA_MainMenu;
	menu:SetShown(not menu:IsShown());
end
SLASH_SADBCLEAR1 = "/sanpcdbclear" or "/SANPCDBCLEAR" or "/sanpdbclear" or "/SANPDBCLEAR" or "/saNPCDBClear";
SlashCmdList.SADBCLEAR = function()
	StatAurasDatabase.NPCAuras = {};
	StatAuras.Funcs.DisplayAurasUpdate("target", SA_TargetAurasAnchor)
	print("|cffBA6EE6[StatusAura]|r |cffC61E1EБаза данных аур НПЦ успешно очищена!|r");
end
SLASH_SACUS1 = "/sacustom" or "/SACUSTOM";
SlashCmdList.SACUS = function()
	local menu = Cus_SA_MainMenu;
	menu:SetShown(not menu:IsShown());
end
SLASH_SAHELP1 = "/sahelp" or "/SAHELP" or "/SAHelp" or "/SAhelp" or "/saHelp";
SlashCmdList.SAHELP = function()
	print("|cffBA6EE6[StatusAura]|r |cffFFB266Доступные команды:|r");
	print("|cff9CE1E61.|r |cff9CE1E6/saDef|r |cffFFB266- открыть меню со стандартными аурами.|r");
	print("|cff9CE1E62.|r |cff9CE1E6/saNPCDBClear|r |cffFFB266- очистить базу данных аур НПЦ.|r");
	if StatAurasSyncModule then
		print();
		print("|cffBA6EE6[StatusAura |cff9CE1E6Sync_Module|r|cff6339C3]|r |cffFFB266Доступные команды:|r");
		print("|cff9CE1E61.|r |cff9CE1E6/sagmToggle|r |cffFFB266- включить/отключить |cff9CE1E6режим ведущего|r|cffFFB266.|r");
		print("|cff9CE1E62.|r |cff9CE1E6/saModeSwitch|r |cffFFB266- переключить режим получения аур на |cff606060чёрный|r/|cffFFFFFFбелый|r список.|r");
		print("|cff9CE1E63.|r |cff9CE1E6/saRaidMode|r |cffFFB266- включить/отключить режим |cffFF6200рейдовой рассылки|r.");
		print("|cff9CE1E64.|r |cff9CE1E6/saAWLtoggle|r |cffFFB266- включить/отключить |cff9CE1E6автоматическое добавление|r избранного отправителя аур, лидера рейда и его помощников в |cffFFFFFFбелый|r список|cffFFB266.|r");
		print("|cff9CE1E65.|r |cff9CE1E6/saSetSender|r |cffFFB266- указать персонажа-цель как предпочтительный источник новых аур.|r");
		print("|cff9CE1E66.|r |cff9CE1E6/saBlockSender|r |cff9CE1E6- |cffC61E1Eзаблокировать|cffFFB266 получение новых/обновление старых аур от персонажа-цели.|r");
		print("|cff9CE1E67.|r |cff9CE1E6/saWhitelistSender|r |cff9CE1E6- |cff1EC724разрешить|cffFFB266 получение новых/обновление старых аур от персонажа-цели.|r");
		print("|cff9CE1E68.|r |cff9CE1E6/saGetSender|r |cffFFB266- выписать персонажа, от которого вы получаете ауры при входе в игру.|r");
		print("|cff9CE1E69.|r |cff9CE1E6/saGetPriority|r |cffFFB266- выписать список персонажей-отправителей аур в порядке приоритета.|r");
		print("|cff9CE1E610.|r |cff9CE1E6/saGetCustomSender|r |cffFFB266- выписать персонажа, который является предпочтительным для получения аур при входе в игру.|r");
		print("|cff9CE1E611.|r |cff9CE1E6/saGetBlockedSenders|r |cffFFB266- выписать персонажей, получение аур от которых вы |cffC61E1Eзаблокировали|r.|r");
		print("|cff9CE1E612.|r |cff9CE1E6/saGetWhitelistedSenders|r |cffFFB266- выписать персонажей, получение аур от которых вы |cff1EC724разрешили|r.|r");
		print("|cff9CE1E613.|r |cff9CE1E6/saClearBlacklist|r |cffFFB266- очистить |cff606060чёрный список|r отправителей.|r");
		print("|cff9CE1E614.|r |cff9CE1E6/saClearWhitelist|r |cffFFB266- очистить |cffFFFFFFбелый список|r отправителей.|r");
	end
end
---------------------------------------------------
-- Функции
---------------------------------------------------
StatAuras.Vars.CurAuraNum_Std = nil;
StatAuras.Vars.CurAuraNum_Cus = nil;

function StatAuras.Funcs.SwitchFrame(targetFrame)
	if TargetFrameBuff1:IsVisible() then
		targetFrame:Hide();
	else
		targetFrame:Show();
	end
end

function StatAuras.Funcs.typeRadio(targetButton)
	HP_Radio:SetChecked(false);
	MP_Radio:SetChecked(false);
	AR_Radio:SetChecked(false);
	BAR_Radio:SetChecked(false);
	ATK_Radio:SetChecked(false);
	targetButton:SetChecked(true);
end

function StatAuras.Funcs.StdAuraType(num_key)
	StatAuras.Vars.CurAuraNum_Std = num_key;
end

function StatAuras.Funcs.CusAuraType(num_key)
	StatAuras.Vars.CurAuraNum_Cus = num_key;
end

function StatAuras.Funcs.DeleteAura(guid, aura_index, aura_database)
	table.remove(aura_database[guid], aura_index);
	if #aura_database[guid] == 0 then
		SomeBodysUtils:removeFromSetTable(aura_database, guid);
	end
	return aura_database;
end

function StatAuras.Funcs.UnstackableCheck(aura, stacks, operation)
	if aura[6] then							-- || If aura IS, in fact, stackable
		return stacks;
	end

	if (operation == "set" or operation == "change_nil") and stacks > 0 then
		stacks = 1;
		aura[7] = stacks;
		return stacks;
	end

	if operation == "change" and stacks >= 0 then
		stacks = 0;
		aura[7] = stacks;
		return stacks;
	end

	return stacks;							-- || Just for safety, in case stacks value will SOMEHOW be negative
end

function StatAuras.Funcs.SetAura(aura, guid, stacks, aura_database)
	local OwnerName = UnitName("player");
	local temp_aura_table = {};
	stacks = tonumber(stacks);
	temp_aura_table = SomeBodysUtils:AuraTableCopy(aura);
	temp_aura_table[7] = stacks;
	stacks = StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "set");
	local auraToAdd_ID = temp_aura_table[1];

	if SomeBodysUtils:tableContains(aura_database, guid) then
		local guid_auras = aura_database[guid];
		for i, aura in ipairs(guid_auras) do
			if auraToAdd_ID == aura[1] then								-- || If target_guid exists, aura exists
				if stacks > 0 then
					aura[5] = OwnerName;								-- Смена "владельца" навешенной ауры
					aura[7] = stacks;									-- Стаки
					return aura_database;
				else
					return StatAuras.Funcs.DeleteAura(guid, i, aura_database);
				end
			end
		end
		if stacks > 0 then											-- || If target_guid exists, aura doesn't exist
			table.insert(guid_auras, temp_aura_table);
			local aura_num = #guid_auras;
			guid_auras[aura_num][5] = OwnerName;					-- Смена "владельца" навешенной ауры
		end
		return aura_database;
	end
	if stacks > 0 then												-- || If target_guid does not exist in DB
		aura_database[guid] = {temp_aura_table};
		local aura_num = #aura_database[guid];
		aura_database[guid][aura_num][5] = OwnerName;				-- Смена "владельца" навешенной ауры
	end
	return aura_database;
end

function StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, aura_database, math_symbol)
	local OwnerName = UnitName("player");
	local temp_aura_table = {};
	stacks = tonumber(stacks) * math_symbol;
	temp_aura_table = SomeBodysUtils:AuraTableCopy(aura);
	temp_aura_table[7] = stacks;
	local auraToAdd_ID = temp_aura_table[1];
	local guid_auras = aura_database[guid];

	if SomeBodysUtils:tableContains(aura_database, guid) then
		local guid_auras = aura_database[guid];
		for i, aura in ipairs(guid_auras) do
			if auraToAdd_ID == aura[1] then							-- || If target_guid exists, aura exists
				if (aura[7] + stacks) > 0 then
					stacks = StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "change");
					aura[5] = OwnerName;							-- Смена "владельца" навешенной ауры
					aura[7] = (aura[7] + stacks);					-- Стаки
					return aura_database;
				else
					return StatAuras.Funcs.DeleteAura(guid, i, aura_database);
				end
			end
		end
		if stacks > 0 then											-- || If target_guid exists, aura doesn't exist
			StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "change_nil");
			table.insert(guid_auras, temp_aura_table);
			local aura_num = #guid_auras;
			guid_auras[aura_num][5] = OwnerName;					-- Смена "владельца" навешенной ауры
		end
		return aura_database;
	end
	if stacks > 0 then												-- || If target_guid does not exist in DB
		StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "change_nil");
		aura_database[guid] = {temp_aura_table};
		local aura_num = #aura_database[guid];
		aura_database[guid][aura_num][5] = OwnerName;				-- Смена "владельца" навешенной ауры
	end
	return aura_database;
end

function StatAuras.Funcs.RemoveAura(auraToRemove_ID, unit_type)
	local guid;
	if unit_type == "ply" then
		guid = UnitGUID("player");
	else
		guid = UnitGUID("target");
	end
	if guid == nil then	
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ вас нет цели!|r");
		return 1;
	end
	local aura_database;
	if (GetPlayerInfoByGUID(guid)) then
		aura_database = StatAurasDatabase.PlayersAuras;
	else
		aura_database = StatAurasDatabase.NPCAuras;
	end
	auraToRemove_ID = tonumber(auraToRemove_ID);
	----------------------------------------------------------------------
	if SomeBodysUtils:tableContains(aura_database, guid) then
		local guid_auras = aura_database[guid];
		for i, aura in ipairs(guid_auras) do
			if auraToRemove_ID == aura[1] then
				aura_database = StatAuras.Funcs.DeleteAura(guid, i, aura_database);
				if (GetPlayerInfoByGUID(guid)) then
					StatAurasDatabase.PlayersAuras = aura_database;
				else
					StatAurasDatabase.NPCAuras = aura_database;
				end
				return 0;
			end
		end
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ цели нет выбранной ауры!|r");
		return 2;
	end
	print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ цели нет активных аур!|r");
	return 3;
end

function StatAuras.Funcs.ModifyAura(stacks, operation, auraID, unit_type)
	local aura = StatAurasDatabase.AurasPool[auraID];
	local guid;
	if unit_type == "ply" then
		guid = UnitGUID("player");
	else
		guid = UnitGUID("target");
	end
	if guid == nil then	
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ вас нет цели!|r");
		return 1;
	end
	if operation == "set" then
		if (GetPlayerInfoByGUID(guid)) then
			StatAurasDatabase.PlayersAuras = StatAuras.Funcs.SetAura(aura, guid, stacks, StatAurasDatabase.PlayersAuras);
		else
			StatAurasDatabase.NPCAuras = StatAuras.Funcs.SetAura(aura, guid, stacks, StatAurasDatabase.NPCAuras);
		end
	elseif operation == "increase" then
		if (GetPlayerInfoByGUID(guid)) then
			StatAurasDatabase.PlayersAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.PlayersAuras, 1);
		else
			StatAurasDatabase.NPCAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.NPCAuras, 1);
		end
	elseif operation == "decrease" then
		if (GetPlayerInfoByGUID(guid)) then
			StatAurasDatabase.PlayersAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.PlayersAuras, -1);
		else
			StatAurasDatabase.NPCAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.NPCAuras, -1);
		end
	end
	return 0;
end

function StatAuras.Funcs.TargetAurasAnchorUpdate()
	local anchor_yOffset = (32 - (SA_TargetAura1:GetHeight() + 6) * (TargetFrame.auraRows));
	SA_TargetAurasAnchor:ClearAllPoints();
	SA_TargetAurasAnchor:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, anchor_yOffset);
end

function StatAuras.Funcs.PlayerAurasAnchorUpdate()
	local PlayerAurasAmount = 0;
	AuraUtil.ForEachAura("player", "HELPFUL", nil, function()
		PlayerAurasAmount = PlayerAurasAmount + 1;
	end);

	local PlayerAurasRows = (PlayerAurasAmount - mod(PlayerAurasAmount, 8)) / 8;
	if (math.fmod(PlayerAurasAmount, 8) > 0) then
		PlayerAurasRows = PlayerAurasRows + 1;
	end
	local anchor_yOffset = (0 - (SA_PlayerAura1:GetHeight() + 15) * (PlayerAurasRows));
	SA_PlayerAurasAnchor:ClearAllPoints();
	SA_PlayerAurasAnchor:SetPoint("TOPRIGHT", "BuffFrame", "TOPRIGHT", 0, anchor_yOffset);
end

function StatAuras.Funcs.DisplayAurasUpdate(unitID, AurasAnchor)
	if UnitGUID(unitID) == nil then
		AurasAnchor:Hide();
		return 0;
	end

	local guid = UnitGUID(unitID);
	local aura_database = {};
	if (GetPlayerInfoByGUID(guid)) then
		aura_database = StatAurasDatabase.PlayersAuras;
	else
		aura_database = StatAurasDatabase.NPCAuras;
	end

	local tooltip_anchor = "ANCHOR_BOTTOMLEFT";											-- Tooltip anchoring
	local tooltip_xoff = 0;
	local tooltip_yoff = 0;
	if unitID == "target" then
		tooltip_anchor = "ANCHOR_BOTTOMRIGHT";
		tooltip_xoff = 15;
		tooltip_yoff = -25;
	end

	if SomeBodysUtils:tableContains(aura_database, guid) then
		local guid_auras = aura_database[guid];
		local active_auras_num = #guid_auras;
		local aura_buffs_container = { AurasAnchor:GetChildren() };
		for i, aura in ipairs(guid_auras) do										-- Показывает активные ауры.
			local aura_elements_container = { aura_buffs_container[i]:GetChildren() };
			local aura_element = { aura_elements_container[1]:GetRegions() };		-- [1] стаки; [2] иконка
			aura_element = aura_element[1];
			if aura[7] == 1 then
				aura_element:SetText("");
			else
				aura_element:SetText(tostring(aura[7]));
			end
			
			aura_element = { aura_elements_container[2]:GetRegions() };
			aura_element = aura_element[1];
			aura_element:SetTexture(aura[4]);
			
			aura_buffs_container[i]:SetScript("OnEnter", function()							--	Установка скриптов для тултипов
				GameTooltip:SetOwner(aura_buffs_container[i], tooltip_anchor, tooltip_xoff, tooltip_yoff)
				GameTooltip:AddLine(aura[2])
				GameTooltip:AddLine(aura[3], 1, 1, 1, true)
				GameTooltip:AddDoubleLine("AuraID:", aura[1], nil, nil, nil, 0.71, 1, 1)
				GameTooltip:AddDoubleLine("Владелец:", aura[5], nil, nil, nil, 0.71, 1, 1)
				GameTooltip:Show()
			end)
			aura_buffs_container[i]:SetScript("OnLeave", function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end)
			aura_buffs_container[i]:SetAttribute("auraID", aura[1]);				-- Добавить ID ауры к фрейму этой ауры
			aura_buffs_container[i]:SetAttribute("aura_index", i);					-- Добавить порядочный номер ауры 
			aura_buffs_container[i]:Show();											-- к фрейму этой ауры

			i = i + 1;
		end
		for n = active_auras_num+1, #aura_buffs_container do						-- Скрывает ненужные ауры.
			aura_buffs_container[n]:Hide();
		end
		AurasAnchor:Show();
		return 0;
	end
	AurasAnchor:Hide();
	return 0;
end

function StatAuras.Funcs.DisplayAuraCrementByOne(auraBuffFrame, button, unitID)
	local aura_index = auraBuffFrame:GetAttribute("aura_index");
	local guid = UnitGUID(unitID);
	local aura_database = {};
	if (GetPlayerInfoByGUID(guid)) then
		aura_database = StatAurasDatabase.PlayersAuras;
	else
		aura_database = StatAurasDatabase.NPCAuras;
	end
	local auras_pointer;
	if SomeBodysUtils:tableContains(aura_database, guid) then		-- THEORETICALLY db_table will ALWAYS contain sub-table
		auras_pointer = aura_database[guid];						-- of guid index. But I added a check just in case.
	else
		return;
	end
	local aura = auras_pointer[aura_index];

	if button == "LeftButton" then
		aura_database = StatAuras.Funcs.ChangeAuraStacks(aura, guid, 1, aura_database, 1);
	elseif button == "RightButton" then
		aura_database = StatAuras.Funcs.ChangeAuraStacks(aura, guid, 1, aura_database, -1);
	end

	if UnitGUID("target") == UnitGUID("player") then
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_PlayerAurasAnchor);
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_TargetAurasAnchor);
	elseif unitID == "player" then
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_PlayerAurasAnchor);
	else
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_TargetAurasAnchor);
	end
	return 0;
end

function StatAuras.Funcs.UI_Scaling()
	local UI_scale = UIParent:GetEffectiveScale();
	SA_TargetAurasAnchor:SetScale(UI_scale);
	SA_PlayerAurasAnchor:SetScale(UI_scale);
	Def_SA_MainMenu:SetScale(UI_scale);
	return 0;
end
---------------------------------------------------