--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

--------------------------------------------------------------------
----------------    SUMMARY OF LEVEL IMPLEMENTATION	----------------
--------------------------------------------------------------------
--[[
APPROACH
First of all I tried to stick to the original level spirit more than copying verbatim triggers/events. Working on top of @yuantse and @JovialFeline code

ORIGINAL VS ORA VERSION
Again the redeployable MCV changes a few things. At the start of the level the player starts with 2 mcvs. I want to change this a bit (See BALANCE).

BALANCE
First of all the second MCV the player has would only be available on EASY. In Normal the MCV will arrive after X time. In HARD there will be no extra
MCV. If the player wants to secure the right side, he/she must migrate there with the only MCV. 
The closest soviet base doesn't have sams so aircrafts can do quick work of it. I think is better to give the AI (USSR) sams but these will be built after
X time. The X amount will depend on difficulty, so, if the player is quick enough, he/she can weaken the soviet enough so they become less of a threat.


MCV-Deploy
Aircrafts
Spy
PowerPlants and island fortification 


As mentioned before, AI will send attacks occasionally but the bulk of the AI efforts will be in protecting the base and other behaviors that make it hard
for the VIP unit to leave the base. Among these changes

OTHER
No secondary objective yet


TL;DR
- Change dog locations, add a way for AI to rebuild (no inf queue usage) them to defend against spies
- Change top power plants and island fortifications to new player (not USSR and not BadGuy)
]]

local Util = {}
local Prod = {}
local Behav = {}
local BaseB = {}

local IsNaval
local CheckProductionBuildingReady --??
local AlertBadGuy
local CreateZoneTriggers
local PrepareBadGuyAlerts
local PrepareMainSubmarines
local GroupHuntOnDamaged
local OrderBlockers
local InitialAlliedReinforcements
local SendRevengeSub
local PrepareMammothPatrol
local OnMammothsDead
local AlliedMCVArrival

local StartingCashReserves = { easy = 7000, normal = 6000, hard = 5000, challenge = 5000 }

local OnlyOneMCV = { easy = false, normal = false, hard = true, challenge = true }

local McvReinforcements1 = { actors = { "mcv" }, entryPath = { MCVEntry1.Location, MCVDst1.Location } }
local McvReinforcements2 = { actors = { "mcv" }, entryPath = { MCVEntry2.Location, MCVDst2.Location } }
local McvReinforcements3 = { actors = { "mcv" }, entryPath = { MCVEntry3.Location, MCVDst3.Location } }

local EnglandLeftEarlyNavy = { actors = { "pt", "pt", "dd", "dd" }, entryPath = { EnglandLeftEntry.Location } }
local EnglandRightEarlyNavy = { actors = { "pt", "pt", "dd", "dd" }, entryPath = { EnglandRightEntry.Location } }
local EnglandLeftLateNavy = { actors = { "ca" }, entryPath = { EnglandLeftEntry.Location } }
local EnglandRightLateNavy = { actors = { "ca" }, entryPath = { EnglandRightEntry.Location } }

---@type cpos[]
local SeaLeftPatrolPath = 
{
EnglandLeftEntry.Location, EnglandLeftWP1.Location, EnglandLeftWP2.Location,
EnglandLeftWP3.Location, EnglandLeftWP4.Location, EnglandLeftWP5.Location,
EnglandLeftWP6.Location, EnglandLeftDst.Location, EnglandLeftExit.Location
}

---@type cpos[]
local SeaRightPatrolPath =
{ EnglandRightEntry.Location, EnglandRightWP1.Location, EnglandRightWP2.Location, EnglandRightWP3.Location, EnglandRightWP4.Location, EnglandRightWP5.Location, EnglandRightWP6.Location, EnglandRightDst.Location, EnglandRightExit.Location }

local SentNavy = false
local SentCruisers = false

--This function is to allow usage of outliner. Remove at some point
local function __DATA__() end

BadGuyAlerted = false
EnglandReinforced = false

---@type integer|nil Delayed objective to destroy the Forward Command.
local DestroyForwardCommand

local function __UTILS__() end

---@param actor actor
---@return boolean
function IsNaval(actor)
	return Utils.Any({ "ca", "dd", "lst", "pt", "ss" }, function(shipType)
		return actor.Type == shipType
	end)
end
--[[
--@return boolean
AreIslandTeslasDown = function()
	local teslas = { IslandTsla1, IslandTsla2, IslandTsla3, IslandTsla4, IslandTsla5 }

	return Turkey.PowerState ~= "Normal" or Utils.All(teslas, function(a)
		return a.IsDead
	end)
end
]]
---CHANGE: For AI. Move it there
function CheckProductionBuildingReady()

	local mainWestStructures = USSR.GetActorsByTypes({ "afld", "barr", "dome", "fact", "proc", "spen", "stek", "weap" })

	local barrack = BadGuy.GetActorsByType("barr")
	Media.Debug("A")
	local factory = BadGuy.GetActorsByType("weap")
	Media.Debug("B")
	local naval = BadGuy.GetActorsByType("spen")
	Media.Debug("C")

	if barrack then
		Media.Debug("Produce Infantry")
		ProduceInfantry(barrack[1], BadGuy)
	end

	if factory then
		Media.Debug("Produce Armor")
		ProduceArmor(factory[1], BadGuy)
	end

	if naval then
		Media.Debug("Produce Naval")
		--ProduceSubmarine(BGBarr, BadGuy)
	end

	if barrack and factory and naval then
		Media.Debug("RemovingThisCheck")
		return
	end

	CheckProductionBuildingReady()
end

--------------------------------------------------------------------
----------------	BADGUY ALERTS - START        -------------------
--------------------------------------------------------------------
local function __BADGUY_ALERTS__() end

function AlertBadGuy()
	if BadGuyAlerted then
		return
	end
	BadGuyAlerted = true
	Media.Debug("BadGuy alerted")
	
	-- CHANGE: Move this to .lua AI file
	RunBadGuyActivities()

	Trigger.AfterDelay(DateTime.Seconds(20), function()
		--CheckProductionBuildingReady()
	end)
end

--- Create an imitation of the eastern land area's original zone footprint.
---@param action fun()
function CreateZoneTriggers(action)
	local cells = { CPos.New(93, 36), CPos.New(102, 50), CPos.New(99, 63), CPos.New(99, 81), CPos.New(86, 91), CPos.New(99, 101) }
	local triggers = { }

	Utils.Do(cells, function(location)
		local id = Trigger.OnEnteredProximityTrigger(Map.CenterOfCell(location), WDist.FromCells(10), function(actor)
			if actor.Owner ~= Greece or not actor.HasProperty("Health") or actor.CenterPosition.Z > 0 or IsNaval(actor) then
				return
			end

			Utils.Do(triggers, Trigger.RemoveProximityTrigger)
			action()
		end)

		triggers[#triggers + 1] = id
	end)
end

--- Activate the east base once Allies attack it, land somewhere east of
--- the river that isn't on Turkey's beach, or do enough damage to USSR.
function PrepareBadGuyAlerts()
	CreateZoneTriggers(AlertBadGuy)
	local eastBase = BadGuy.GetActorsByTypes({ "apwr", "fact", "fcom", "powr", "brik" })

	OnAnyDamaged(eastBase, function(_, attacker)
		if attacker.Owner.Faction == "soviet" then
			return
		end

		AlertBadGuy()
	end)

	-- RA '96 behavior: wait until USSR is wiped out, including all submarines.
	local mainWestStructures = USSR.GetActorsByTypes({ "afld", "barr", "dome", "fact", "proc", "spen", "stek", "weap" })
	Utils.Do(mainWestStructures, function(structure)
		Trigger.OnKilledOrCaptured(structure, AlertBadGuy)
	end)
end

--------------------------------------------------------------------
----------------	ROAD PATROLS - START        --------------------
--------------------------------------------------------------------
local function __OTHER__() end

function PrepareMainSubmarines()
	local subs = Utils.Where(USSR.GetActorsByType("ss"), function(sub)
		return not sub.HasTag("Area Guard")
	end)

	Utils.Do(subs, function(sub)
		Trigger.OnDamaged(sub, function(self, attacker)
			if self.Owner.Faction == attacker.Owner.Faction then
				return
			end

			Trigger.Clear(sub, "OnDamaged")
			IdleHunt(sub)
		end)
	end)

	local islandSubs = { IslandSub1, IslandSub2, IslandSub3, IslandSub4, IslandSub5, IslandSub6, IslandSub7 }
	-- Trigger.OnAnyKilled(islandSubs, SendRevengeSub)
end

--------------------------------------------------------------------
----------------	ROAD PATROLS - END        --------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------	ROAD PATROLS - START        --------------------
--------------------------------------------------------------------
local function __ROAD_PATROLS__() end

---@param actors actor[]
function GroupHuntOnDamaged(actors)
	local alerted = false

	Utils.Do(actors, function(victim)
		Trigger.OnDamaged(victim, function(_, attacker)
			if alerted or attacker.Owner.Faction == "soviet" then
				return
			end
			alerted = true

			Utils.Do(actors, function(hunter)
				if hunter.IsDead or not hunter.HasProperty("Hunt") then
					return
				end

				-- Halt any patrols this group might have.
				hunter.Stop()
				hunter.RemoveTag("Area Guard")
				Trigger.Clear(hunter, "OnIdle")

				Trigger.AfterDelay(1, function()
					IdleHunt(hunter)
				end)
			end)
		end)
	end)
end

---@param actors actor[]
---@param rally? cpos
function OrderBlockers(actors, rally)
	Utils.Do(actors, function(a)
		if not rally then
			IdleHunt(a)
			return
		end

		a.AddTag("Area Guard")
		a.AttackMove(rally, 2)
	end)

	if rally then
		-- Possible TODO: add real Area Guard behavior ala The Tiberium Strain.
		-- There may be little benefit here since it's not a no-build, and ORA
		-- infantry have weapon range that roughly covers original guard range.
		-- Something for the lone base dog would be nice for spy guarding.
		GroupHuntOnDamaged(actors)
	end
end

function InitialAlliedReinforcements()
	if OnlyOneMCV[Difficulty] == false then
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(Greece, "ReinforcementsArrived")
			Reinforcements.Reinforce(Greece, McvReinforcements1.actors, McvReinforcements1.entryPath)
			Reinforcements.Reinforce(Greece, McvReinforcements2.actors, McvReinforcements2.entryPath)
		end)
	else
		Reinforcements.Reinforce(Greece, McvReinforcements3.actors, McvReinforcements3.entryPath)
	end
end

--[[
---@param types string[]
---@return actor[]|nil
local function RecruitBlockers(types)
	local blockers = { }
	local typesDone = { }
	local success = true

	local pool = Utils.Where(USSR.GetGroundAttackers(), function(a)
		return a.IsIdle and not a.HasTag("Area Guard") end)

	Utils.Do(types, function(type)
		if not success or typesDone[type] then
			return
		end
		typesDone[type] = true

		-- "The request is 'apc, v2rl, e1, e1, e2'. How many e1 are needed?"
		local quota = #Utils.Where(types, function(t)
			return type == t end)

		local matches = Utils.Where(pool, function(p)
			return type == p.Type end)

		if #matches < quota then
			success = false
			return
		end

		blockers = Utils.Concat(blockers, Utils.Take(quota, matches))
	end)

	if success then
		return blockers
	end

	return nil
end

---@param types string[]
---@param producer actor
---@param rally? cpos
local function BuildBlockers(types, producer, rally)
	if producer.IsDead and #USSR.GetActorsByType(producer.Type) == 0 then
		return
	end

	USSR.Build(types, function(actors)
		OrderBlockers(actors, rally)
	end)
end
]]
--- Continue sending Submarine hunters once an island Submarine first dies.
function SendRevengeSub()
	local idleSubs = Utils.Where(USSR.GetActorsByType("ss"), function(a)
		return a.IsIdle and not a.HasTag("Area Guard") end)

	if #idleSubs == 0 then
		return
	end

	local sub = idleSubs[1]
	IdleHunt(sub)
	Trigger.OnKilled(sub, SendRevengeSub)
end

function PrepareMammothPatrol()
	-- The original tanks would Area Guard at each point, but
	-- that may be unnecessary with their default chase stance.
	local tanks = { StartMammoth1, StartMammoth2 }
	local path =
	{
		MammothPatrolWP1.Location, MammothPatrolWP2.Location, MammothPatrolWP3.Location, MammothPatrolWP4.Location,
		MammothPatrolWP5.Location, MammothPatrolWP6.Location, MammothPatrolWP7.Location, MammothPatrolWP8.Location,
		MammothPatrolWP9.Location
	}
	GroupHuntOnDamaged(tanks)
	Trigger.OnAllKilled(tanks, OnMammothsDead)

	Utils.Do(tanks, function(tank)
		tank.Patrol(path, true, DateTime.Seconds(6))
	end)
end

--- Recruit/build teams to guard the road to the USSR base.
--- Based on triggers blok and blk1 through blk3.
function OnMammothsDead()
	local teams =
	{
		{ types = { "3tnk", "v2rl" }, 				rally = MammothPatrolWP1.Location, 	producer = USSRWarFactory },
		{ types = { "e2", "e2", "e2", "e4", "e4" }, rally = MammothPatrolWP9.Location, 	producer = USSRBarracks },
		{ types = { "3tnk", "3tnk" }, 				rally = MammothPatrolWP6.Location, 	producer = USSRWarFactory },
		{ types = { "4tnk" }, 						rally = MammothPatrolWP7.Location, 	producer = USSRWarFactory },
		{ types = { "e4", "e4", "e4", "e4", "e4" }, 									producer = USSRBarracks}
	}

	local delay = 0
	Utils.Do(teams, function(team)
		Trigger.AfterDelay(delay, function()
			local units = RecruitBlockers(team.types)

			if not units then
				BuildBlockers(team.types, team.producer, team.rally)
				return
			end

			OrderBlockers(units, team.rally)
		end)

		delay = delay + 5
	end)
end

--------------------------------------------------------------------
----------------				INTRO         ----------------------
--------------------------------------------------------------------
local function __INTRO_TRIGGERS__() end



------------------------------------------------------------------
----------------	ROAD PATROLS - END        --------------------
------------------------------------------------------------------
local function __BASE_TRIGGERS__() end

InitTriggers = function()
	Greece.Cash = StartingCashReserves[Difficulty]

	InitialAlliedReinforcements()

	PrepareMammothPatrol()
	PrepareBadGuyAlerts()

	Trigger.OnTimerExpired(function()
		SendNavalUnits()
		EnglandReinforced = true

	end)

	FinishTimer = function()
		DateTime.TimeLimit = 0
		for i = 0, 5, 1 do
			local c = TimerColor
			if i % 2 == 0 then
				c = HSLColor.White
			end
			Trigger.AfterDelay(DateTime.Seconds(i), function()
				UserInterface.SetMissionText(UserInterface.GetFluentMessage("convoy-arrived"), c)
			end)
		end
		Trigger.AfterDelay(DateTime.Seconds(6), function() UserInterface.SetMissionText("") end)
	end
end

PrepareObjectives = function()
	Trigger.OnDiscovered(BGFcom, function(actor, discoverer)
		if discoverer ~= Greece then
			return
		end
		DestroyCommandCenter = AddSecondaryObjective(Greece, "destroy-center-submarine-reinforcements") 
	end)

	Trigger.OnKilledOrCaptured(BGFcom, function()
		-- Ensure an objective since it is possible to bypass the OnDiscovered.
		DestroyCommandCenter = DestroyCommandCenter or Greece.AddSecondaryObjective(UserInterface.GetFluentMessage("destroy-center-submarine-reinforcements"))
		Greece.MarkCompletedObjective(DestroyCommandCenter)
	end)

	Trigger.OnEnteredFootprint({ EnglandNavyLeftExit1.Location, EnglandNavyRightExit2.Location }, function(actor)
		if actor.Type ~= "ca" then
			return
		end

		Greece.MarkCompletedObjective(ClearNavalChannel)
	end)

	Trigger.OnAllKilled({ Cruiser1, Cruiser2 }, function()
		if Greece.IsObjectiveCompleted(ClearNavalChannel) then
			return
		end

		Media.PlaySpeechNotification(Greece, "AlliedForcesFallen")

		Trigger.AfterDelay(DateTime.Seconds(2), function()
			Greece.MarkFailedObjective(ClearNavalChannel)
		end)
	end)
end

PrepareObjectives = function()
	InitObjectives(Greece)

	ClearNavalChannel = Greece.AddObjective("Clear the naval channel.")

	DenyAllies = AddPrimaryObjective(USSR, "Eliminate all Allied forces.")

	Trigger.OnPlayerLost(Greece, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(USSR, "MissionFailed")
		end)
	end)	
	Trigger.OnPlayerWon(Greece, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(USSR, "MissionAccomplished")
		end)
	end)

	Trigger.OnKilledOrCaptured(BGFcom, function()
		-- Ensure an objective since it is possible to bypass the OnDiscovered.
		DestroyCommandCenter = DestroyCommandCenter or Greece.AddSecondaryObjective(UserInterface.GetFluentMessage("destroy-center-submarine-reinforcements"))
		Greece.MarkCompletedObjective(DestroyCommandCenter)
	end)

end

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
local function __CORE_TRIGGERS__() end

Tick = function()
	if Greece.HasNoRequiredUnits() then
		USSR.MarkCompletedObjective(USSRObj)
	end

	--UserInterface.SetMissionText( "USSR: " .. tostring(CheckPlayerMoney(USSR)) .. " | BadGuy: " .. tostring(CheckPlayerMoney(BadGuy)) .. " | Turkey: " .. tostring(CheckPlayerMoney(Turkey)), TimerColor)

	--[[if Ticked > 0 then
		UserInterface.SetMissionText("Naval vessels arrive in " .. Utils.FormatTime(Ticked), TimerColor)
		Ticked = Ticked - 1
		if USSR.HasNoRequiredUnits() and BadGuy.HasNoRequiredUnits() and Turkey.HasNoRequiredUnits() then
			Ticked = 0
		end
	elseif Ticked == 0 then
		FinishTimer()
		TimerExpiredSendNavy()
		Ticked = Ticked - 1
	end]]
end

WorldLoaded = function()

	Camera.Position = DefaultCameraPosition.CenterPosition

	Greece = Player.GetPlayer("Greece")
	USSR = Player.GetPlayer("USSR")
	BadGuy = Player.GetPlayer("BadGuy")
	Turkey = Player.GetPlayer("Turkey")
	England = Player.GetPlayer("England")
	Neutral = Player.GetPlayer("Neutral")

	InitTriggers()
	--PrepareObjectives()
	SetupAIActivities()

	DateTime.TimeLimit = DateTime.Minutes(60)
end
