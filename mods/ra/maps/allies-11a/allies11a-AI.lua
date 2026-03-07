--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

local Util = {}
local Prod = {}
local Behav = {}
local Base = {}

------ UTILS ------
local IsNaval
local IsAircraft
local IsBuilding
local IsHarvesterMissing
local CheckPlayerMoney
local GrantCash
local InsertBlueprints
local AvailableProducerTypeCheck
local AvailableTypeCheck
local ProduceHarvester
local SelectLandAtkPaths
local ReverseTable
------ BASE MANAGEMENT ------
-- Could be moved to its own list "local base = {}"
local BuildBase
local BuildBlueprint
local OnBlueprintBuilt
local IsBuildAreaBlocked
local ScatterBlockers
local PrepareBlueprintEdges
local BeginBaseMaintenance
local MaintainBuilding
------ AI ATTACKS ------
local SetCombatRole
local CheckBeachGuardVacancy
local SendUnits
------ INF ATTACKS ------
local ProduceInfantry
------ ARMOR ATTACKS ------
local ProduceArmor
local CreateCombatGroup
local SetGuardPoint
local FetchUnitsToTransport
------ AIR ATTACKS ------
local CountAflds
local ProduceAircraft
local PrepareAircraftReinforcements
local OnAircraftStranded
local AreSovietPlanesActive
local HasAirfield
local ScheduleAirWave
------ NAVAL ATTACKS ------
local ProduceSubs
local PrepareNavalAtk
local ProduceLST
local FindLstInArea
local CheckSecuredArea
local SendLST
local EnemySubsReinforcements

---@alias blueprint { type: string, actor: actor, cost: integer, shape: integer[], location: cpos, owner?: player, producer?: boolean, northwestEdge?: wpos, southeastEdge?: wpos }

DebugMsgEnabled = true

--For Debug
D = function(msg)
	if DebugMsgEnabled then
		Media.Debug(tostring(msg))
	end
end

--------------------------------------------------------------------
-----------------	    DATA BLOCK - START	------------------------
--------------------------------------------------------------------
local function ______DATA______() end -- Used as marker for outliner. Remove when ready

------------------------------
--- Difficulty Start --------
------------------------------

local USSRCashReserves = { easy = 20000, normal = 30000, hard = 40000, challenge = 40000 }
local USSRStartingCash
local BadGuyCashReserves = { easy = 10000, normal = 20000, hard = 30000, challenge = 30000 }
local BadGuyStartingCash

local AtkProductionIntervals = { easy = DateTime.Seconds(60), normal = DateTime.Seconds(40), hard = DateTime.Seconds(20), challenge = DateTime.Seconds(20) }

------------------------------
--- Difficulty End	----------
------------------------------

---@type blueprint
local USSRBaseBlueprints =
{
	{ type = "powr", actor = USSRPower1, cost = 300, shape = { 2, 3 }, location = CPos.New(56, 42) },
	{ type = "apwr", actor = USSRPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(37, 42) },
	{ type = "apwr", actor = USSRPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(39, 39) },
	{ type = "powr", actor = USSRPower4, cost = 300, shape = { 2, 3 }, location = CPos.New(44, 39) },
	{ type = "apwr", actor = USSRPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(52, 39) },
	{ type = "apwr", actor = USSRPower6, cost = 500, shape = { 3, 3 }, location = CPos.New(55, 39) },
	{ type = "apwr", actor = USSRPower7, cost = 500, shape = { 3, 3 }, location = CPos.New(58, 41) },

	{ type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(41, 42) },

	{ type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(46, 45), owner = USSR, producer = true },
	{ type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(51, 45)  },
	{ type = "kenn", actor = USSRKenn, cost = 200, shape = { 1, 1 }, location = CPos.New(57, 45) },
	{ type = "spen", actor = USSRSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(62, 50) },

	{ type = "dome", actor = USSRDome, cost = 1400, shape = { 2, 3 }, location = CPos.New(37, 39) },
	{ type = "stek", actor = USSRStek, cost = 1500, shape = { 3, 3 }, location = CPos.New(48, 42) },

	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(38, 50) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(46, 40) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(49, 40) },
	{ type = "afld", actor = USSRAfld4, cost = 500, shape = { 3, 2 }, location = CPos.New(55, 50) },

	{ type = "ftur", actor = USSRFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(44, 53) },
	{ type = "ftur", actor = USSRFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(50, 53) },
    { type = "tsla", actor = USSRTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(43, 51) },
    { type = "tsla", actor = USSRTsla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(51, 51) }
}

---@type blueprint
local USSRBaseSamsBlueprints =
{
		-- I think these should be added to counter allies aircraft on normal/hard
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(38, 52) },
	{ type = "sam", actor = USSRSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(42, 39) },
	{ type = "sam", actor = USSRSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(55, 52) },
	{ type = "sam", actor = USSRSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(56, 38) }
}

---@type blueprint
local BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGPower1, cost = 300, shape = { 3, 3 }, location = CPos.New(98, 47) },
	{ type = "apwr", actor = BGPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(90, 51) },
}

---@type blueprint
local BGPower3, BGPower4, BGPower5, BGProc, BGBarr, BGWeap, BGDome, BGAfld1, BGAfld2, BGFtur1, BGFtur2, BGTesla1, BGTesla2, BGSam1, BGSam2, BGSam3, BGSam4 =
nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local BadGuyBaseExtraBlueprints = 
{
	{ type = "apwr", actor = BGPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) },
	{ type = "apwr", actor = BGPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 52) },
	{ type = "apwr", actor = BGPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 55) },

	{ type = "proc", actor = BGProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(100, 55) },

	{ type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(96, 60) },
	{ type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(100, 60) },

	{ type = "barr", actor = BGBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(95, 50), owner = BadGuy, producer = true },
	{ type = "weap", actor = BGWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(92, 55), owner = BadGuy, producer = true },

	{ type = "afld", actor = BGAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(88, 54) },
	{ type = "afld", actor = BGAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(88, 56) },

    { type = "tsla", actor = BGTesla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(98, 58) },
    { type = "tsla", actor = BGTesla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(97, 50) },

	{ type = "sam", actor = BGSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 51) },
	{ type = "sam", actor = BGSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 59) },
	{ type = "sam", actor = BGSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(104, 59) },
	{ type = "sam", actor = BGSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(104, 47) }
}

local VehicleAttackInterval = { easy = DateTime.Seconds(180), normal = DateTime.Minutes(150), hard = DateTime.Minutes(120), challenge = DateTime.Minutes(120)}

-------------------------
-- Land Attacks Data   --
-------------------------

local USSRAttackPaths = { { USSRAtkWP1.Location }, { USSRAtkWP1.Location, USSRAtkWP2.Location } }
local BadGuyAttackPaths = { { BadGuyAtkWP1.Location } }

local InfantryTypes = { "e1", "e2", "e4"}
local InfantryAttackGroup = { }
local InfantryAttackGroupSizes = { easy = 6, normal = 9, hard = 12, challenge = 12 }

local VehicleTypes = { "3tnk", "3tnk", "3tnk", "v2rl", "v2rl", "4tnk" }
local VehicleAttackGroup = {}
local VehicleAttackGroupSizes = { easy = 2, normal = 3, hard = 4, challenge = 4}

local VehicleUSSRAttackGroup = { }
local VehicleBadGuyAttackGroup = { }

local InfantryUSSRAttackGroup = { }
local InfantryBadGuyAttackGroup = { }

local CombatRole = "regular" -- "regular", "guard", "marine"

---@type { group: string[], location: cpos }[]
BeachGuardPositions = {
	{ group = { }, location = CPos.New(62, 58) },
    { group = { }, location = CPos.New(60, 64) },
    { group = { }, location = CPos.New(62, 70) }
}

local BeachGuardRandomPositions	= Utils.Shuffle(BeachGuardPositions)

-----------------------
-- Air Attacks Data  --
-----------------------

local CurrentAirWave = 1
local BasePlanes = {}

local AircraftTypes = { "yak", "mig" }
local PlanesAttackGroup = { }

-- Checking how this works with CVec addition
---@type { types: string[], interval: number, path: cpos[], owner?: player }[]
local SovietAirTeams = {
	{ types = { "yak" }, interval = DateTime.Seconds(120), path = { SovietAircraftOrigin1.Location + CVec.New(-1, 0) }, owner = USSR},
	{ types = { "yak", "yak" }, interval = DateTime.Seconds(110), path = { SovietAircraftOrigin1.Location + CVec.New(-1, 0) }},
	{ types = { "mig", "mig" }, interval = DateTime.Seconds(110), path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1.Location + CVec.New(-1, 0) }	},
	{ types = { "mig", "mig", "yak" }, interval = DateTime.Seconds(219),  path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1.Location + CVec.New(-1, 0) } },
	{ types = { "mig", "mig", "mig", "yak", "yak", "yak", "yak" }, interval = DateTime.Seconds(210), path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1	.Location + CVec.New(-1, 0) } }
}

-------------------------
-- Naval Attacks Data  --
-------------------------

local SubTypes = { "ss"}

local SubUSSRAttackGroup = { }
local SubBadGuyAttackGroup = { }

local SubAttackGroupSizes = { easy = 1, normal = 2, hard = 2, challenge = 2}

local NavalAtkPath = { }

local LSTNeededFlag = false

local LSTDetectionPivot = USSRSpen
local LSTDetectionRange = WDist.FromCells(5)

local LSTPathRoute = { USSRSpen.Location, LstDst.Location }

--------------------------------------------------------------------
-----------------	    DATA BLOCK - END	------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	UTILS BLOCK - START	----------------------------
--------------------------------------------------------------------
local function ________________UTILS________________() end -- Used as marker for outliner. Remove when ready

---@param a actor
---@return boolean
function IsNaval(a)
	return Utils.Any({ "ca", "dd", "pt", "lst", "ss", "syrd", "spen" }, function(navalType)
		return a.Type == navalType
	end)
end

---@param a actor
---@return boolean
function IsAircraft(a)
	return Utils.Any({ "yak", "mig", "heli", "mh60", "tran", "hind", "badg" }, function(airType)
		return a.Type == airType
	end)
end

---@param a actor
---@return boolean
function IsBuilding(a)
	return a.HasProperty("StartBuildingRepairs")
end

---@param a actor
---@return boolean
function IsGroundUnit(a)
	return a.HasProperty("Move") and not IsNaval(a) and not IsAircraft(a)
end

---@param a actor
---@return boolean
function IsGroundActor(a)
	return IsGroundUnit(a) and IsBuilding(a)
end

---@param action fun(actor: actor): boolean
---@return boolean
function CheckSecuredArea(action)
	local nw = WPos.New( (CPos.New(61, 19)).X * 1024,  (CPos.New(61, 19)).Y * 1024, 0)
    local se = WPos.New( (CPos.New(105, 103)).X * 1024, (CPos.New(105, 103)).Y * 1024, 0)
	
	local actors = Map.ActorsInBox( nw, se, function(a)
		return (a.Owner == Greece or a.Owner == England) and action(a)
    end)

	return #actors > 0
end

---@param owner player
function IsHarvesterMissing(owner)
	return #owner.GetActorsByType("harv") == 0
end

---@param owner player
function CheckPlayerMoney(owner)
	return owner.Cash + owner.Resources
end

---@param player player
function GrantCash(player, amount)
    player.Cash = player.Cash + amount
end

--Insert blueprints[] to player base building blueprints[]
---@param blueprints blueprint[]
---@param insert blueprint[]
function InsertBlueprints(blueprints, insert)
    Utils.Do(insert, function(b)
        local index = #blueprints
		table.insert(blueprints, index, b)
        PrepareBlueprintEdges(b)
    end)
end

---@param producer actor
---@param owner player
function AvailableProducerTypeCheck(producer, owner)
	local type = producer.Type
	if #owner.GetActorsByType(type) > 0 then
		return true
	else
		return false
	end
end

--- Ignores player ownership
---@param players player[]
---@param type string
---@return boolean
function AvailableTypeCheck(players, type)
	local types_found = Utils.Any(players, function(p)
		p.GetActorsByType(type)
	end)

	if types_found then
		return true
	else
		return false
	end
end

---Issues an order to player to produce an harvester if there is enough cash
---@param producer actor
---@param owner player
---@param delay number
function ProduceHarvester(producer, owner, delay)
	if CheckPlayerMoney(owner) < Actor.Cost("harv") then
		return
	end

	local toBuild = { "harv" }
	owner.Build(toBuild, function()
		Trigger.AfterDelay(delay, function()
			ProduceArmor(producer, owner)
		end)
	end)
end

function SelectLandAtkPaths(owner)
    if owner == USSR then
        return USSRAttackPaths
    else
        return BadGuyAttackPaths
    end
end

---@param array cpos[]
---@return cpos[]
function ReverseTable(array)
	local table_to_reverse = array
	local reversed_table = { }

	for i = #table_to_reverse, 1, -1 do
		--D(table_to_reverse[i])
    	table.insert(reversed_table, table_to_reverse[i])
		--D(reversed_table[i])
	end
	return reversed_table
end

--------------------------------------------------------------------
-----------------	UTILS BLOCK - END	----------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function ________________BASE_MANAGEMENT________________() end -- Used as marker for outliner. Remove when ready

---@param blueprints blueprint[]
---@param cyard any
---@param owner player
function BuildBase(blueprints, cyard, owner)
	for _, blueprint in ipairs(blueprints) do
		if not blueprint.actor then
			BuildBlueprint(blueprints, blueprint, cyard, owner)
			return
		end
	end
	Trigger.AfterDelay(DateTime.Seconds(10), function()
		BuildBase(blueprints, cyard, owner)
	end)
end

---@param blueprints blueprint[]
---@param blueprint blueprint
---@param cyard actor
---@param owner player
function BuildBlueprint(blueprints, blueprint, cyard, owner)
	Trigger.AfterDelay(Actor.BuildTime(blueprint.type), function()
		if cyard.IsDead or cyard.Owner ~= owner then
			return
		elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
			return
		end

		if IsBuildAreaBlocked(owner, blueprint) then
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				BuildBlueprint(blueprints, blueprint, cyard, owner)
			end)
			return
		end

		local actor = Actor.Create(blueprint.type, true, { Owner = owner, Location = blueprint.location })
		OnBlueprintBuilt(actor, blueprint, owner)
		Trigger.AfterDelay(DateTime.Seconds(10), function()
			BuildBase(blueprints, cyard, owner)
		end)
	end)
end

---@param actor actor
---@param blueprint blueprint
---@param owner player
function OnBlueprintBuilt(actor, blueprint, owner)
	owner.Cash = owner.Cash - blueprint.cost
	blueprint.actor = actor
	MaintainBuilding(actor, blueprint, 0.75)

	Trigger.AfterDelay(1, function()
		if blueprint.type ~= "barr" and blueprint.type ~= "weap" and blueprint.type ~= "afld" and blueprint.type ~= "spen" then
			return
		end

		if blueprint.type == "barr" then
			ProduceInfantry(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceArmor(actor, owner)
		elseif blueprint.type == "afld" then
			Media.Debug("Check for air production")
			--ProduceAircraft(actor, owner)
		elseif blueprint.type == "spen" then
			Media.Debug("Check for subs production")
			--CheckForSubs()
			ProduceSubs(actor, owner)
		end
	end)
end

---@param blueprint blueprint
---@param owner player
function IsBuildAreaBlocked(owner, blueprint)
	local nw = blueprint.northwestEdge --[[@as wpos]]
	local se = blueprint.southeastEdge --[[@as wpos]]
	local blockers = Map.ActorsInBox(nw, se, function(actor)
		-- Neutral check is for ignoring trees near the refinery.
		return actor.Owner ~= Neutral and actor.CenterPosition.Z == 0 and actor.HasProperty("Health")
	end)

	if #blockers == 0 then
		return false
	end

	ScatterBlockers(blockers, owner)
	return true
end

---@param actors actor[]
---@param owner player
function ScatterBlockers(actors, owner)
	Utils.Do(actors, function(a)
		if a.IsIdle and a.Owner == owner and a.HasProperty("Scatter") then
			a.Scatter()
		end
	end)
end

---@param blueprint blueprint
function PrepareBlueprintEdges(blueprint)
	local shapeX, shapeY = blueprint.shape[1], blueprint.shape[2]
	local northwestEdge = Map.CenterOfCell(blueprint.location) + WVec.New(-512, -512, 0)
	local southeastEdge = northwestEdge + WVec.New(shapeX * 1024, shapeY * 1024, 0)
	blueprint.northwestEdge = northwestEdge
	blueprint.southeastEdge = southeastEdge
end

---@param blueprints blueprint[]
---@param owner player
function BeginBaseMaintenance(blueprints, owner)
	Utils.Do(blueprints, function(blueprint)
		MaintainBuilding(blueprint.actor, blueprint, 0.75)
	end)
	Utils.Do(owner.GetActors(), function(actor)
		if actor.HasProperty("StartBuildingRepairs") then
			MaintainBuilding(actor, nil, 0.75)
		end
	end)
end

---@param actor actor
---@param blueprint? blueprint
---@param repairThreshold number
function MaintainBuilding(actor, blueprint, repairThreshold)
	if blueprint then
		Trigger.OnKilled(actor, function() blueprint.actor = nil end)
		Trigger.OnSold(actor, function() blueprint.actor = nil end)
		if not blueprint.northwestEdge then
			PrepareBlueprintEdges(blueprint)
		end
	end

	if repairThreshold then
		local original = actor.Owner

		Trigger.OnDamaged(actor, function()
			if actor.Owner ~= original or actor.Health > actor.MaxHealth * repairThreshold then
				return
			end

			actor.StartBuildingRepairs()
		end)
	end
end

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - END	--------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------		ATTACKING BLOCK - START	--------------------
--------------------------------------------------------------------
local function ________________AI_ATTACKS________________() end -- Used as marker for outliner. Remove when ready

function SetCombatRole()
	if CheckBeachGuardVacancy() and CombatRole == "regular" then
		CombatRole = "guard"
	else
		if CheckSecuredArea(IsBuilding) and CombatRole == "regular" then
			CombatRole = "marine"
		else
			CombatRole = "regular"
		end
	end
end

---@return integer|nil
function CheckBeachGuardVacancy()
	local points = BeachGuardRandomPositions
	for index, guardPoint in ipairs(points) do
		if #guardPoint.group == 0 then
			return index
		end
	end
end

---@param units actor[]
---@param path cpos[]
function SendUnits(units, path)
	Utils.Do(units, function(unit)
		if unit.IsDead then
			return
		end

		unit.Patrol(path, false)
		IdleHunt(unit)
	end)
end

-----------------------
-----------------------
--- Inf Attacks     ---
-----------------------
-----------------------
local function ________________Inf_Attacks________________() end -- Used as marker for outliner. Remove when ready

---@param producer actor
---@param owner player
function ProduceInfantry(producer, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(2), DateTime.Seconds(4))

    if not AvailableProducerTypeCheck(producer, owner) then
        return
	elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
        return
	end

    local toBuild = { Utils.Random(InfantryTypes) }
    local path = Utils.Random(SelectLandAtkPaths(owner))

	if owner == BadGuy and not CheckSecuredArea(IsGroundActor)  then
		Trigger.AfterDelay(DateTime.Minutes(2), function()
			ProduceInfantry(producer, owner)
		end)
		return
	end

	owner.Build(toBuild, function(units)
        if owner == USSR then
            table.insert(InfantryUSSRAttackGroup, units[1])
            if #InfantryUSSRAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryUSSRAttackGroup, path)
                InfantryUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceInfantry(producer, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(producer, owner)
			    end)
            end
        else
            table.insert(InfantryBadGuyAttackGroup, units[1])
            if #InfantryBadGuyAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryBadGuyAttackGroup, path)
                InfantryBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceInfantry(producer, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(producer, owner)
			    end)
            end
        end
	end)
end

-----------------------
-----------------------
--- Armor Attacks   ---
-----------------------
-----------------------
local function ________________Tank_Attacks________________() end -- Used as marker for outliner. Remove when ready


---@param producer actor
---@param owner player
function ProduceArmor(producer, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if not AvailableProducerTypeCheck(producer, owner) then
		return
	elseif IsHarvesterMissing(owner) then
        ProduceHarvester(producer, owner, delay)
        return
    end

	if owner == BadGuy and not CheckSecuredArea(IsGroundActor)  then
		Trigger.AfterDelay(DateTime.Minutes(2), function()
			ProduceArmor(producer, owner)
		end)
		return
	end

	local toBuild = { Utils.Random(VehicleTypes) }
    local path = Utils.Random(SelectLandAtkPaths(owner))

	owner.Build(toBuild, function(units)
        local unit = units[1]
        CreateCombatGroup(producer, owner, unit)
    end)
end

---@param producer actor
---@param owner player
---@param unit actor
function CreateCombatGroup(producer, owner, unit)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	local allPaths = {}
	--local path = Utils.Random( USSRAttackPaths )
	if owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end
	local path = Utils.Random(allPaths)
	if owner == USSR then
		table.insert(VehicleUSSRAttackGroup, unit)
		if #VehicleUSSRAttackGroup < VehicleAttackGroupSize then
			Trigger.AfterDelay(delay, function()
				ProduceArmor(producer, owner)
			end)
		else
			local index = CheckBeachGuardVacancy()
			SetCombatRole()
			if CombatRole == "regular" then -- REGULAR
				SendUnits(VehicleUSSRAttackGroup, path)
			elseif CombatRole == "guard" --[[and index]] then -- GUARD
				SetGuardPoint(index)
			elseif CombatRole == "marine" then -- MARINE
				--add these for b scenario
				FetchUnitsToTransport(VehicleUSSRAttackGroup, LstLoad.Location)
			end
			VehicleUSSRAttackGroup = { }
			Trigger.AfterDelay(DateTime.Minutes(2), function()
				ProduceArmor(producer, owner)
			end)
		end
	elseif owner == BadGuy then
		table.insert(VehicleBadGuyAttackGroup, unit)
		if #VehicleBadGuyAttackGroup < VehicleAttackGroupSize then
			Trigger.AfterDelay(delay, function()
				ProduceArmor(producer, owner)
			end)
		else -- Combat role conditionals
			SendUnits(VehicleBadGuyAttackGroup, path)
			Trigger.AfterDelay(DateTime.Minutes(2), function()
				ProduceArmor(producer, owner)
			end)
		end
	end
end

---@param index integer
function SetGuardPoint(index)
	D(index)
	BeachGuardRandomPositions[index].group = VehicleUSSRAttackGroup
	local units = BeachGuardRandomPositions[index].group
	local pos = BeachGuardRandomPositions[index].location

	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Utils.Do(units, function(u)
			

			if not u.IsDead then
				u.Stance = "Defend"
				u.Move(pos)
				u.Move(pos + CVec.New(-2, 0))
			end
		end)

		OnAnyDamaged(units, function(u, attacker)
			if attacker.Owner == Greece and u.Health <= u.MaxHealth * 0.75 then
				--u.Stance = "Defend"
				Trigger.Clear(u, "OnDamaged")
				Utils.Do(units, function(u)
					IdleHunt(u)
				end)
			end
		end)

		Trigger.OnAllKilled(units, function()
			BeachGuardRandomPositions[index].group = { }
		end)
	end)
end

---@param units actor[]
---@param load_loc cpos
function FetchUnitsToTransport(units, load_loc)
	local lst = FindLstInArea(LSTDetectionPivot)

	if not lst then
		LSTNeededFlag = true
		local path = Utils.Random(USSRAttackPaths)
		SendUnits(units, path)
		return
	end

	lst.Move(load_loc)

	Utils.Do(units, function(u)
		if not u.IsDead then
			u.Move(TransportPoint.Location)
			u.EnterTransport(lst)

			Trigger.OnAddedToWorld(u, function()
				IdleHunt(u)
				if lst.PassengerCount == 0 then
					lst.Move(LSTDetectionPivot.Location)
				end
			end)
		end
	end)

	Trigger.OnAllRemovedFromWorld(units, function()
		if lst.PassengerCount == 0 then
			return
		end
		SendLST(lst, LSTPathRoute)
	end)
end

-----------------------
-----------------------
--- Air Attacks     ---
-----------------------
-----------------------

local function ________________Air_Attacks________________() end -- Used as marker for outliner. Remove when ready

---@return actor[]
---@param owner player
function CountAflds(owner)
	local aflds = owner.GetActorsByType("afld")
	return aflds
end

---@param producer actor
---@param owner player
function ProduceAircraft(producer, owner)
    if not AvailableProducerTypeCheck(producer, owner) then
        return
    end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(AircraftTypes) }

    USSR.Build(toBuild, function(units)
        local plane = units[1]
		table.insert(BasePlanes, plane)
        PlanesAttackGroup[#PlanesAttackGroup + 1] = plane

        Trigger.OnKilled(plane, function()
			table.remove(BasePlanes)
			Trigger.AfterDelay(delay, function()
				ProduceAircraft(producer, owner)
			end)
		end)
        InitializeAttackAircraft(plane, Greece)
    end)
end

function SendParabombs()
	if AvailableTypeCheck({USSR, BadGuy}, "afld") then
		return
	end

	local airfield = USSR.GetActorsByType("afld")[1] or BadGuy.GetActorsByType("afld")[1]
	local targets = Utils.Where(Greece.GetActors(), function(actor)
		return
			actor.HasProperty("Sell") and
			actor.Type ~= "brik" and
			actor.Type ~= "sbag" or
			actor.Type == "pdox" or
			actor.Type == "atek"
	end)
	if #targets > 0 then
		airfield.TargetAirstrike(Utils.Random(targets).CenterPosition, Angle.NorthEast)
	end

	Trigger.AfterDelay(DateTime.Minutes(4)--[[ParabombDelay]], SendParabombs)
end

---@param delay integer
function SendParadrop(delay)
	if AvailableTypeCheck({USSR, BadGuy}, "afld") then
		return
	end

	local LZ = KosyginExtractPoint
	local aircraft = powerproxy.TargetParatroopers(LZ.CenterPosition)

	Utils.Do(aircraft, function(a)
		Trigger.OnPassengerExited(a, function(t, p)
			IdleHunt(p)
		end)
	end)
	Trigger.AfterDelay(delay, SendParadrop)--[[]]
end

function PrepareAircraftReinforcements()
	local delay = DateTime.Seconds(10)--FirstAirDelays[Difficulty] or FirstAirDelays["normal"]

	Trigger.AfterDelay(delay, function()
		ScheduleAirWave(1)
	end)
end

---@param aircraft actor
---@param exit cpos
function OnAircraftStranded(aircraft, exit)
	local oldOwner = aircraft.Owner

	if oldOwner == USSR and HasAirfield(BadGuy) then
		aircraft.Owner = BadGuy
	elseif oldOwner == BadGuy and HasAirfield(USSR) then
		aircraft.Owner = USSR
	end

	if oldOwner == aircraft.Owner then
		aircraft.Stop()
		aircraft.Move(exit)
		aircraft.Destroy()
	end
end

function AreSovietPlanesActive()
	local planes = { "mig", "yak" }
	return #USSR.GetActorsByTypes(planes) > 0
end

---@param player player
function HasAirfield(player)
	return player.HasPrerequisites({ "afld" })
end

---@param wave integer
function ScheduleAirWave(wave)
	local team = SovietAirTeams[wave]
	if not team then
		team = SovietAirTeams[#SovietAirTeams]
		--return
	end
	Trigger.AfterDelay(team.interval, function()
		-- The last team was defeated before its scheduled repeat.
		if CurrentAirWave > wave then
			return
		end

		local units = Reinforcements.Reinforce(team.owner or USSR, team.types, team.path)
		ScheduleAirWave(wave)
		Utils.Do(units, function(unit)
			InitializeAttackAircraft(unit, Greece)

			Trigger.OnIdle(unit, function()
				if unit.AmmoCount() > 0 then
					table.insert(BasePlanes, unit)
					return
				elseif HasAirfield(unit.Owner) and #BasePlanes < #CountAflds(unit.Owner) then
					return
				end
				OnAircraftStranded(unit, team.path[1])

			end)
		end)

		Trigger.OnAllRemovedFromWorld(units, function()
			if AreSovietPlanesActive() then
				return
			end

			-- Activate this at a later point
			--[[
			if team.onWaveDefeated then
				team.onWaveDefeated()
			end
			]]

			CurrentAirWave = CurrentAirWave + 1
			ScheduleAirWave(CurrentAirWave)
		end)
	end)
end

-----------------------
-----------------------
--- Naval Attacks   ---
-----------------------
-----------------------
local function ________________Naval_Attacks________________() end -- Used as marker for outliner. Remove when ready

---@param producer actor
---@param owner player
function ProduceSubs(producer, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if not AvailableProducerTypeCheck(producer, owner) then
        return
	elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
        return
	end

	if LSTNeededFlag == true then
		ProduceLST(producer, owner)
		return
	end

	if CheckSecuredArea(IsNaval) then
		local toBuild = { Utils.Random(SubTypes) }
		local path = { }
		owner.Build(toBuild, function(units)
			if owner == USSR then
				table.insert(SubUSSRAttackGroup, units[1])
				if #SubUSSRAttackGroup >= SubAttackGroupSize then
					SendUnits(SubUSSRAttackGroup, NavalAtkPath)
					SubUSSRAttackGroup = { }
					Trigger.AfterDelay(AtkProductionInterval, function()
						ProduceSubs(producer, owner)
					end)
				else
					Trigger.AfterDelay(delay, function()
						ProduceSubs(producer, owner)
					end)
				end
			else
				table.insert(SubBadGuyAttackGroup, units[1])
				if #SubBadGuyAttackGroup >= SubAttackGroupSize then
					SendUnits(SubBadGuyAttackGroup, NavalAtkPath)
					SubBadGuyAttackGroup = { }
					Trigger.AfterDelay(AtkProductionInterval, function()
						ProduceSubs(producer, owner)
					end)
				else
					Trigger.AfterDelay(delay, function()
						ProduceSubs(producer, owner)
					end)
				end

			end
		end)
	else
		Trigger.AfterDelay(delay, function()
			ProduceSubs(producer, owner)
		end)
	end
end

---@param producer actor
---@param owner player
function ProduceLST(producer, owner)
	local toBuilt = { "lst" }
	LSTNeededFlag = false

	if not AvailableProducerTypeCheck(producer, owner) then
		owner.Build(toBuilt, function(units)
			Trigger.AfterDelay(AtkProductionInterval, function()
				ProduceSubs(producer, owner)
			end)
		end)
	end
end

---@return actor|nil
---@param waypoint actor
function FindLstInArea(waypoint)
	local CenterPos = waypoint.CenterPosition

	local lst = Map.ActorsInCircle(CenterPos, LSTDetectionRange, function(actor)		
		return actor.Type == "lst" and actor.Owner == USSR and actor.PassengerCount <= 0
	end)[1]

	if lst then
		return lst
	else
		ProduceLST(USSRSpen, USSR)
	end
end

-- Similar to "SendUnits" but for lst unload passengers at last waypoint and going back following the same path. ATTEMPT 2
---@param lst actor
---@param path cpos[]
function SendLST(lst, path)
	local go_path = path
	local return_path = ReverseTable(path)

	Trigger.OnIdle(lst, function()
		if not lst.IsDead then
			if FindLstInArea(USSRSpen) then
				Utils.Do(path, function(p)
					lst.Move(p)
				end)
				--Trigger.Clear(lst, "OnIdle")
			else
				lst.UnloadPassengers(path[#path])
				Utils.Do(return_path, function(p)
					lst.Move(p)
				end)
				Trigger.Clear(lst, "OnIdle")
			end
		end
	end)
end

-- Constant out of map attack if eastern Forward Command is not dead
function EnemySubsReinforcements()
    if BGFcom.IsDead then
		return
	end

	if CheckSecuredArea(IsNaval) then
		local leftSpawnPoint = EnglandLeftExit.Location
		local rightSpawnPoint = EnglandRightExit.Location
		local subs = { }

		Trigger.AfterDelay(DateTime.Seconds(2), function()
			local subsLeft = Reinforcements.Reinforce(USSR, {"ss", "ss"}, { leftSpawnPoint, leftSpawnPoint + CVec.New(0, 2) })
			local subsRight = Reinforcements.Reinforce(USSR, {"ss", "ss"}, { rightSpawnPoint, rightSpawnPoint + CVec.New(0, 2) })
			--This could be refactored
			subs = { subsLeft[1], subsRight[1] }
			Utils.Do(subs, function(u)
				if not u.IsDead then
					IdleHunt(u)
				end
			end)
		end)
	end

    Trigger.AfterDelay(DateTime.Minutes(4), function()
        EnemySubsReinforcements()
    end)
end

--------------------------------------------------------------------
----------------		ATTACKING BLOCK - END	--------------------
--------------------------------------------------------------------
local function ________________AI_SETUP________________() end -- Used as marker for outliner. Remove when ready

function SetAIDifficulty()
	USSRStartingCash = USSRCashReserves[Difficulty]
    BadGuyStartingCash = BadGuyCashReserves[Difficulty]

	AtkProductionInterval = AtkProductionIntervals[Difficulty]

	InfantryAttackGroupSize = InfantryAttackGroupSizes[Difficulty]
	VehicleAttackGroupSize = VehicleAttackGroupSizes[Difficulty]

	SubAttackGroupSize = SubAttackGroupSizes[Difficulty]

end

SetupAIActivities = function()
	SetAIDifficulty()

	USSR.Cash = USSRStartingCash
    BadGuy.Cash = BadGuyStartingCash

	powerproxy = Actor.Create("powerproxy.paratroopers", false, { Owner = USSR })

	-- To randomize location of beach guards
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		local index = CheckBeachGuardVacancy()
		if index then
			-- D(CheckBeachGuardVacancy())
		end
	end)

	BeginBaseMaintenance(USSRBaseBlueprints, USSR)
	BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

	BuildBase(USSRBaseBlueprints, USSRFact, USSR)

	Trigger.AfterDelay(DateTime.Minutes(4), function()
		EnemySubsReinforcements()
	end)

	Trigger.AfterDelay(DateTime.Minutes(2), function()
		PrepareAircraftReinforcements()
	end)
end

-- Activated once USSR is alerted
function RunUSSRActivities()
	Trigger.AfterDelay(DateTime.Minutes(2), function()
		InsertBlueprints(USSRBaseBlueprints, USSRBaseSamsBlueprints)
	end)

	ProduceInfantry(USSRBarr, USSR)
	ProduceArmor(USSRWeap, USSR)

	ProduceSubs(USSRSpen, USSR)
end

-- Activated once BadGuy is alerted
function RunBadGuyActivities()
	InsertBlueprints(BadGuyBaseBlueprints, BadGuyBaseExtraBlueprints)
	BuildBase(BadGuyBaseBlueprints, BadGuyFact, BadGuy)
end
