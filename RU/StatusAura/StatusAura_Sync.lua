---------------------------------------------------
-- SA_Sync_GetLibs
---------------------------------------------------
local LibDeflate, LibParse, AceComm, SomeBodysUtils;

if LibStub then
	LibDeflate = LibStub:GetLibrary("LibDeflate");
	LibParse = LibStub:GetLibrary("LibParse");
	AceComm = LibStub("AceComm-3.0");
	SomeBodysUtils = LibStub:GetLibrary("SomeBodysUtils");
else
	LibDeflate = require("LibDeflate");
	LibParse = require("LibParse");
	AceComm = require("AceComm-3.0");
	SomeBodysUtils = require("SomeBodysUtils");
end
---------------------------------------------------
-- Объявление переменных
---------------------------------------------------
local channel, channelID, channelName, activeSender, curMembersNumber
local inGroup = false;
local status_aura_prefix = "|cffBA6EE6[StatusAura]|r";

if StatAurasSyncModule == nil then
	StatAurasSyncModule = {};
	StatAurasSyncModule.customSender = nil;
	StatAurasSyncModule.isGM = false;
	StatAurasSyncModule.auraSenders = {};
	StatAurasSyncModule.whitelistMode = false;
	StatAurasSyncModule.blockedSenders = {};
	StatAurasSyncModule.whitelistedSenders = {};
	StatAurasSyncModule.autoWhitelist = true;
	StatAurasSyncModule.raidMode = true;
end
---------------------------------------------------
-- Локальные функции
---------------------------------------------------
local function AutoWhitelistSender(PlayerToAdd)
	if not StatAurasSyncModule.whitelistMode or not StatAurasSyncModule.autoWhitelist then
		return;
	end

	if not SomeBodysUtils:tableContains(StatAurasSyncModule.whitelistedSenders, PlayerToAdd) then
		SomeBodysUtils:addToSetTable(StatAurasSyncModule.whitelistedSenders, PlayerToAdd);
	end
end

local function AutoWhitelistPriorities()
	if StatAurasSyncModule.autoWhitelist then
		for _, name in ipairs(StatAurasSyncModule.auraSenders) do
			AutoWhitelistSender(name);
		end
	end
end

local function AurasSenderSet()
	local PlyIsLeader = UnitIsGroupLeader("PLAYER");

	for i=1, #StatAurasSyncModule.auraSenders do
		if UnitIsConnected(StatAurasSyncModule.auraSenders[i]) or #StatAurasSyncModule.auraSenders == 1 then
			activeSender = StatAurasSyncModule.auraSenders[i];
			return 0;
		end
	end
	if StatAurasSyncModule.customSender ~= nil then							-->	Костыль на случай, если в твоей группе все офф,
		activeSender = StatAurasSyncModule.customSender;					-->	а ауры нужно взять с человека не из группы
		return 0;
	end
	if not PlyIsLeader then
		print(status_aura_prefix, "|cffC61E1EВ сети нет источника новых аур! Для того, чтобы включить автообновление аур, введите команду|r |cff6339C3/sasetsender|r");
		return 1;
	end
end

local function AurasSenderSearch()
	local numMembers = GetNumGroupMembers();
	local PlyIsLeader = UnitIsGroupLeader("PLAYER");
	StatAurasSyncModule.auraSenders = {};

	if numMembers == 0 then
		inGroup = false;
		if StatAurasSyncModule.customSender ~= nil then
			StatAurasSyncModule.auraSenders[1] = StatAurasSyncModule.customSender;
			AurasSenderSet();
			return 0;
		end
		print(status_aura_prefix, "|cffC61E1EВы не состоите в группе/рейде! Для того, чтобы включить автообновление аур, введите команду|r |cff6339C3/sasetsender|r");
		return 1;
	end
	if PlyIsLeader then
		if StatAurasSyncModule.customSender ~= nil then
			StatAurasSyncModule.auraSenders[1] = StatAurasSyncModule.customSender;
		end
		inGroup = true;
	end

	for i=1, numMembers do
		local name, rank = GetRaidRosterInfo(i);
		if rank == 2 and not PlyIsLeader then
			table.insert(StatAurasSyncModule.auraSenders, 1, name);
			AutoWhitelistSender(name);
			inGroup = true;
		elseif rank == 1 then
			table.insert(StatAurasSyncModule.auraSenders, name);
			AutoWhitelistSender(name);
		end
	end
	if StatAurasSyncModule.customSender and not PlyIsLeader then
		table.insert(StatAurasSyncModule.auraSenders, 2, StatAurasSyncModule.customSender);
	end
	AurasSenderSet();
end

local function ListPlayerAdd(listTable, PlayerToAdd)
	local remove_msg, add_msg, guid;
	guid = UnitGUID("target");
	if not (GetPlayerInfoByGUID(guid)) then
		print(status_aura_prefix .. " |cffC61E1EВаша цель не является игроком!|r");
		return 1;
	end

	if listTable == StatAurasSyncModule.blockedSenders then
		remove_msg = status_aura_prefix .. " Вы вернули персонажу|cffC61E1E " .. PlayerToAdd .. "|r возможность отправлять вам ауры.";
		add_msg = status_aura_prefix .. " Вы успешно заблокировали получение аур от персонажа|cffC61E1E " .. PlayerToAdd .. "|r";
	else
		remove_msg = status_aura_prefix .. " Вы убрали персонажа|cffC61E1E " .. PlayerToAdd .. "|r из белого списка.";
		add_msg = status_aura_prefix .. " Вы успешно добавили персонажа|cffC61E1E " .. PlayerToAdd .. "|r в белый список.";
	end

	if SomeBodysUtils:tableContains(listTable, PlayerToAdd) then
		SomeBodysUtils:removeFromSetTable(listTable, PlayerToAdd);
		print(remove_msg);
		return 0;
	end

	SomeBodysUtils:addToSetTable(listTable, PlayerToAdd);
	print(add_msg);
end

local function ListPlayersGet(listTable)
	local empty_msg;
	local notempty_msg;
	if listTable == StatAurasSyncModule.blockedSenders then
		empty_msg = status_aura_prefix .. " Ваш список заблокированных отправителей пуст. |cffC61E1EДобавьте в него кого-нибудь! :)|r";
		notempty_msg = status_aura_prefix .. " |cff9CE1E6Список заблокированных вами отправителей:|r";
	else
		empty_msg = status_aura_prefix .. " Ваш белый список отправителей пуст. |cff1EC724Добавьте в него кого-нибудь! :)|r";
		notempty_msg = status_aura_prefix .. " |cff9CE1E6Белый список отправителей:|r";
	end

	if SomeBodysUtils:tableIsEmpty(listTable) then
		print(empty_msg);
		return 0;
	end

	print(notempty_msg);
	for name, _ in pairs(listTable) do
		print(status_aura_prefix, "|cff9CE1E6—|r|cffC61E1E", name, "|r");
	end
end

local function ListClear(listTable)
	if listTable == StatAurasSyncModule.blockedSenders then
		StatAurasSyncModule.blockedSenders = {};
		print(status_aura_prefix, "|cffC61E1EВы успешно очистили |cff606060чёрный список|r отправителей!|r");
	else
		StatAurasSyncModule.whitelistedSenders = {};
		print(status_aura_prefix, "|cffC61E1EВы успешно очистили |cffFFFFFFбелый список|r отправителей!|r");
	end
end
---------------------------------------------------
-- Slash-команды
---------------------------------------------------
SLASH_SAGMTog1 = "/SAGMToggle" or "/sagmtoggle" or "/SAGMTOGGLE" or "/sagmToggle";
SlashCmdList.SAGMTog = function()
	StatAurasSyncModule.isGM = not StatAurasSyncModule.isGM;

	if StatAurasSyncModule.isGM then
		print(status_aura_prefix, "Вы включили режим ведущего. Теперь вы не будете получать информацию об аурах от других игроков при входе в игру или присоединении к группе.");
	else
		print(status_aura_prefix, "Вы отключили режим ведущего. Теперь вы снова получаете информацию об аурах от других игроков при входе в игру или присоединении к группе.");
	end
end

SLASH_SAModeSwitch1 = "/SAModeSwitch" or "/samodeswitch" or "/SAMODESWITCH" or "/saModeSwitch";
SlashCmdList.SAModeSwitch = function()
	StatAurasSyncModule.whitelistMode = not StatAurasSyncModule.whitelistMode;

	if StatAurasSyncModule.whitelistMode then
		AutoWhitelistPriorities();
		print(status_aura_prefix, "|cff6339C3Вы переключились на режим |cffFFFFFFбелого списка|r.|r Теперь вы получаете информацию об аурах только от игроков, находящихся в белом списке.");
	else
		print(status_aura_prefix, "|cff6339C3Вы переключились на режим |cff606060чёрного списка|r.|r Теперь вы получаете информацию об аурах от всех игроков, не находящихся в чёрном списке.");
	end
end

SLASH_SARaidModeToggle1 = "/SARaidMode" or "/saraidmode" or "/SARAIDMODE" or "/saRaidMode";
SlashCmdList.SARaidModeToggle = function()
	StatAurasSyncModule.raidMode = not StatAurasSyncModule.raidMode;
	StatAuras.Funcs.ChannelSet();

	if StatAurasSyncModule.raidMode then
		print(status_aura_prefix, "Вы |cff1EC724включили|r режим |cffFF6200рейдовой рассылки|r. Теперь вы обмениваетесь информацией об аурах только внутри группы/рейда.");
	else
		print(status_aura_prefix, "Вы |cffC61E1Eотключили|r режим |cffFF6200рейдовой рассылки|r. Теперь вы обмениваетесь информацией об аурах со всеми игроками в канале " .. channelName .. ".");
	end
end

SLASH_SAAWLToggle1 = "/SAAWLToggle" or "/saawltoggle" or "/SAAWLTOGGLE" or "/saawlToggle" or "/SAawlToggle" or "/saAWLToggle" or "/saAWLtoggle";
SlashCmdList.SAAWLToggle = function()
	StatAurasSyncModule.autoWhitelist = not StatAurasSyncModule.autoWhitelist;

	if StatAurasSyncModule.autoWhitelist then
		print(status_aura_prefix, "Вы включили автоматическое добавление персонажей в |cffFFFFFFбелый|r список.");
	else
		print(status_aura_prefix, "Вы отключили автоматическое добавление персонажей в |cffFFFFFFбелый|r список.");
	end
end

SLASH_SACustomSender1 = "/SASetSender" or "/sasetsender" or "/SASETSENDER" or "/saSetSender";
SlashCmdList.SACustomSender = function()
	if UnitName("TARGET") == nil and StatAurasSyncModule.customSender == nil then
		print(status_aura_prefix, "|cffC61E1EУ вас нет цели!|r");
		return 1;
	elseif UnitName("TARGET") == nil then
		print(status_aura_prefix, "Вы перестали запрашивать ауры у персонажа|cffC61E1E", StatAurasSyncModule.customSender);
		StatAurasSyncModule.customSender = nil;
		AurasSenderSearch();
		return 0;
	end

	StatAurasSyncModule.customSender = UnitName("TARGET");
	AutoWhitelistSender(StatAurasSyncModule.customSender);
	if inGroup then
		if StatAurasSyncModule.customSender ~= nil then
			StatAurasSyncModule.auraSenders[2] = StatAurasSyncModule.customSender;
		else
			table.insert(StatAurasSyncModule.auraSenders, 2, StatAurasSyncModule.customSender);
		end
	else
		StatAurasSyncModule.auraSenders[1] = StatAurasSyncModule.customSender;
	end
	print(status_aura_prefix, "Вы успешно установили персонажа|cffC61E1E", StatAurasSyncModule.customSender, "|rкак источник новых аур.");
	AurasSenderSet();
end

SLASH_SABlockSender1 = "/SABlockSender" or "/sablocksender" or "/SABLOCKSENDER" or "/saBlockSender";
SlashCmdList.SABlockSender = function()
	local PlayerToAdd = UnitName("TARGET");

	if PlayerToAdd == nil then
		print(status_aura_prefix, "|cffC61E1EУ вас нет цели!|r");
		return 1;
	end
	ListPlayerAdd(StatAurasSyncModule.blockedSenders, PlayerToAdd);
end

SLASH_SAWLSender1 = "/SAWhitelistSender" or "/saWhitelistSender" or "/SAWhitelistSender" or "/saoWhitelistSender" or "/saWhitelistSender" or "/SAWhitelistSender";
SlashCmdList.SAWLSender = function()
	local PlayerToAdd = UnitName("TARGET");

	if PlayerToAdd == nil then
		print(status_aura_prefix, "|cffC61E1EУ вас нет цели!|r");
		return 1;
	end
	ListPlayerAdd(StatAurasSyncModule.whitelistedSenders, PlayerToAdd);
end

SLASH_SAGetSender1 = "/SAGetSender" or "/sagetsender" or "/SAGETSENDER" or "/saGetSender";
SlashCmdList.SAGetSender = function()
	if activeSender then
		print(status_aura_prefix, "При входе в игру вы получаете ауры от персонажа|cffC61E1E", activeSender, "|r");
	else
		print(status_aura_prefix, "При входе в игру вы не получаете ауры ни от кого.");
	end
end

SLASH_SAGetPriority1 = "/SAGetPriority" or "/sagetpriority" or "/SAGETPRIORITY" or "/saGetPriority";
SlashCmdList.SAGetPriority = function()
	if #StatAurasSyncModule.auraSenders ~= 0 then
		print(status_aura_prefix, "|cff9CE1E6Приоритет отправителей аур:|r");
		for priority_num, sender in ipairs(StatAurasSyncModule.auraSenders) do
			print(priority_num .. ")|cffC61E1E", sender, "|r");
		end
	else
		print(status_aura_prefix, "При входе в игру вы не получаете ауры ни от кого.");
	end
end

SLASH_SAGetCustomSender1 = "/SAGetCustomSender" or "/sagetcustomsender" or "/SAGETCUSTOMSENDER" or "/saGetCustomSender";
SlashCmdList.SAGetCustomSender = function()
	if StatAurasSyncModule.customSender then
		print(status_aura_prefix, "Ваш пользовательский источник аур — персонаж|cffC61E1E", StatAurasSyncModule.customSender, "|r");
	else
		print(status_aura_prefix, "У вас нет пользовательского источника аур.");
	end
end

SLASH_SAGetBlockedSenders1 = "/SAGetBlockedSenders" or "/sagetblockedsenders" or "/SAGETBLOCKEDSENDERS" or "/saGetBlockedSenders";
SlashCmdList.SAGetBlockedSenders = function()
	ListPlayersGet(StatAurasSyncModule.blockedSenders)
end

SLASH_SAGetWhitelistedSenders1 = "/SAGetWhitelistedSenders" or "/sagetwhitelistedsenders" or "/SAGETWHITELISTEDSENDERS" or "/saGetWhitelistedSenders" or "/SAGetWhiteListedSenders" or "/saGetWhiteListedSenders";
SlashCmdList.SAGetWhitelistedSenders = function()
	ListPlayersGet(StatAurasSyncModule.whitelistedSenders)
end

SLASH_SAClearBlacklist1 = "/SAClearBlacklist" or "/saclearblacklist" or "/SACLEARBLACKLIST" or "/saClearBlacklist" or "/SAClearBlacklist" or "/saClearBlacklist";
SlashCmdList.SAClearBlacklist = function()
	ListClear(StatAurasSyncModule.blockedSenders);
end

SLASH_SAClearWhitelist1 = "/SAClearWhitelist" or "/saclearwhitelist" or "/SACLEARWHITELIST" or "/saClearWhitelist" or "/SAClearWhitelist" or "/saClearWhitelist";
SlashCmdList.SAClearWhitelist = function()
	ListClear(StatAurasSyncModule.whitelistedSenders);
end
---------------------------------------------------
-- Функции
---------------------------------------------------
function StatAuras.Funcs.ChannelSet()
	channelID = GetChannelName("xtensionxtooltip2");
	if StatAurasSyncModule.raidMode or channelID == 0 then
		channel = "RAID";
		channelID = nil;
	else
		channel = "CHANNEL";
		channelName = "xtensionxtooltip2";
	end
end

function StatAuras.Funcs.InfoQuery()
	AceComm:SendCommMessage("SA_CharOnEnterQ", "Auras get query.", "WHISPER", activeSender, "ALERT");
end

function StatAuras.Funcs.SendAurasOnSet(unit_type)
	local database_entity_to_send;
	local guid;
	if unit_type == "ply" then
		guid = UnitGUID("player");
	else
		guid = UnitGUID("target");
	end
	if guid == nil then
		return 1;													--> Нет цели
	end
	if (GetPlayerInfoByGUID(guid)) then
		database_entity_to_send = {guid, "PLY", StatAurasDatabase.PlayersAuras[guid]};
	else
		database_entity_to_send = {guid, "NPC", StatAurasDatabase.NPCAuras[guid]};
	end

	local SoR = LibParse:JSONEncode(database_entity_to_send);				-->	SoR = Send or Receive
	SoR = LibDeflate:CompressDeflate(SoR);
	SoR = LibDeflate:EncodeForWoWAddonChannel(SoR);

	AceComm:SendCommMessage("SA_SendOnSetQ", SoR, channel, channelID, "ALERT");
end

function StatAuras.Funcs.QueryHandler(prefix, message, distribution, sender)
	if ( prefix == "SA_SendOnSetQ" ) and ( sender ~= UnitName("PLAYER") ) then
		if not (distribution == channel) and not (UnitInParty(sender)) then
			return 3;
		end
		if StatAurasSyncModule.whitelistMode then
			if not SomeBodysUtils:tableContains(StatAurasSyncModule.whitelistedSenders, sender) then	--> Проверка, в вайтлисте ли отправляющий
				return 1;
			end
		else
			if SomeBodysUtils:tableContains(StatAurasSyncModule.blockedSenders, sender) then			--> Проверка, не заблокирован ли отправляющий
				return 2;
			end
		end

		local SoR = LibDeflate:DecodeForWoWAddonChannel(message);	-->	SoR = Send or Receive
		SoR = LibDeflate:DecompressDeflate(SoR);
		SoR = LibParse:JSONDecode(SoR);

		local guid = SoR[1];
		local UnitType = SoR[2];
		if UnitType == "PLY" then
			StatAurasDatabase.PlayersAuras[guid] = SoR[3];
		elseif UnitType == "NPC" then
			StatAurasDatabase.NPCAuras[guid] = SoR[3];
		end

		StatAuras.Funcs.DisplayAurasUpdate("player", SA_PlayerAurasAnchor);
		StatAuras.Funcs.DisplayAurasUpdate("target", SA_TargetAurasAnchor);
	--=====================================================================================--
	elseif ( prefix == "SA_CharOnEnterQ" ) then
		local SoR = LibParse:JSONEncode(StatAurasDatabase);			-->	SoR = Send or Receive
		SoR = LibDeflate:CompressDeflate(SoR);
		SoR = LibDeflate:EncodeForWoWAddonChannel(SoR);

		AceComm:SendCommMessage("SA_CharOnEnterR", SoR, "WHISPER", sender, "BULK");
	--=====================================================================================--
	elseif ( prefix == "SA_CharOnEnterR" ) and ( sender == activeSender ) then
		if StatAurasSyncModule.whitelistMode then
			if not SomeBodysUtils:tableContains(StatAurasSyncModule.whitelistedSenders, sender) then	--> Проверка, в вайтлисте ли отправляющий
				return 1;
			end
		else
			if SomeBodysUtils:tableContains(StatAurasSyncModule.blockedSenders, sender) then			--> Проверка, не заблокирован ли отправляющий
				return 2;
			end
		end

		local SoR = LibDeflate:DecodeForWoWAddonChannel(message);	-->	SoR = Send or Receive
		SoR = LibDeflate:DecompressDeflate(SoR);
		SoR = LibParse:JSONDecode(SoR);

		StatAurasDatabase = SoR;
		StatAuras.Funcs.DisplayAurasUpdate("player", SA_PlayerAurasAnchor);
		StatAuras.Funcs.DisplayAurasUpdate("target", SA_TargetAurasAnchor);
	end
end
---------------------------------------------------
-- Подключение регистрации ивентов
---------------------------------------------------
local SA_Sync_Frame = CreateFrame("FRAME", "SA_Sync_Frame")	-- Создание фрейма для регистрации событий
local StatAuras_Funcs = StatAuras.Funcs;					-- Создание "указателя" на таблицу с функциями (чтобы eventHandler знал, откуда их брать)

local function eventHandler(self, event, arg1, ...)
	--======================================================================
	--	Включение регистрации сообщений между клиентами после загрузки UI
	--======================================================================
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		AceComm:RegisterComm("SA_CharOnEnterQ", StatAuras_Funcs.QueryHandler);
		AceComm:RegisterComm("SA_CharOnEnterR", StatAuras_Funcs.QueryHandler);
		AceComm:RegisterComm("SA_SendOnSetQ", StatAuras_Funcs.QueryHandler);
	--======================================================================
	--		Подключение каналов для передачи аур + проверка в рейде ли
	--
	--	Почти то же, что и выше, НО регистрация этого события нужна
	--	ПОТОМУ что только после него клиент получает имена членов рейда.
	--======================================================================
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		SA_Sync_Frame:RegisterEvent("CHANNEL_UI_UPDATE");
		StatAuras_Funcs.ChannelSet();
		curMembersNumber = GetNumGroupMembers();
		AurasSenderSearch();
		if not StatAurasSyncModule.isGM and not UnitIsGroupLeader("PLAYER") then
			StatAuras_Funcs.InfoQuery();
		end
	--======================================================================
	--				Проверка того, не пропал ли xtensionxtooltip2
	--						  после изменения каналов
	--======================================================================
	elseif ( event == "CHANNEL_UI_UPDATE" ) then
		StatAuras_Funcs.ChannelSet();
	--======================================================================
	--	   Проверка того, нужно ли перевешивать "крюк" автообновления аур 
	--		   на другого игрока, если кто-то зашёл/вышел в игру/рейд
	--				+ запрос на ауры при присоединении к рейду
	--======================================================================
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( curMembersNumber == nil or curMembersNumber == 0 ) and ( curMembersNumber ~= GetNumGroupMembers() ) then	-- Присоединение к рейду
			curMembersNumber = GetNumGroupMembers();
			AurasSenderSearch();
			if not StatAurasSyncModule.isGM and not UnitIsGroupLeader("PLAYER") then
				StatAuras_Funcs.InfoQuery();
			end
			return 0;

		elseif curMembersNumber ~= GetNumGroupMembers() then	-- Свидетельствует о том, что игрок зашёл/вышел в/из рейд(а) ИЛИ другой человек вышел/зашёл в/из рейд(а)
			curMembersNumber = GetNumGroupMembers();
			AurasSenderSet();
			return 0;
		end
	--======================================================================
	--	   Добавление нового лидера/помощника рейда в список целей для 
	--							автообновления
	--======================================================================
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) and ( curMembersNumber > 0 ) then
		AurasSenderSearch();
		if not StatAurasSyncModule.isGM and not UnitIsGroupLeader("PLAYER") then
			StatAuras_Funcs.InfoQuery();
		end
	end
end

SA_Sync_Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
SA_Sync_Frame:RegisterEvent("CHAT_MSG_ADDON");
SA_Sync_Frame:RegisterEvent("UPDATE_INSTANCE_INFO");	-- Использовать для AurasSenderSearch(), ChannelSet() и InfoQuery() вместо PLY_ENTERING_WORLD
SA_Sync_Frame:RegisterEvent("GROUP_ROSTER_UPDATE");		-- Кто-то выходит/заходит/присоединяется к группе ...
SA_Sync_Frame:RegisterEvent("PLAYER_ROLES_ASSIGNED");	-- Запускается при смене лидера/выдаче ассистов
SA_Sync_Frame:SetScript("OnEvent", eventHandler);
---------------------------------------------------