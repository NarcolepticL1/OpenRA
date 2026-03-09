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
local IsGroundUnit
local IsGroundActor
local CheckSecuredArea
local ReverseTable
local CheckPlayerMoney
local GrantCash
local InsertBlueprints
local AvailableProducerTypeCheck
local AvailableTypeCheck

local IsHarvesterMissing
local ProduceHarvester
local SelectLandAtkPaths
local RandomizedAircraftOrigin

-- Could be moved to its own list "local base = {}"
local BuildBase
local BuildBlueprint
local OnBlueprintBuilt
local IsBuildAreaBlocked
local ScatterBlockers
local PrepareBlueprintEdges
local BeginBaseMaintenance
local MaintainBuilding
---
local SetCombatRole
local CheckBeachGuardVacancy
local SendUnits
--
local ProduceInfantry
--
local ProduceArmor
local CreateCombatGroup
local SetGuardPoint
local TransportGroup
local FindLstInArea
local LSTNeededFlag

local OnAircraftStranded
local AreSovietPlanesActive
local HasAirfield
local ScheduleAirWave
local PrepareAircraftReinforcements
---
local ProduceSubmarines
local EnemySubsReinforcements

---@alias blueprint { type: string, actor: actor, cost: integer, shape: integer[], location: cpos, owner?: player, producer?: boolean, northwestEdge?: wpos, southeastEdge?: wpos }
---@alias guard_pos { group: string[], location: cpos }

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

local USSRCashReserves = { easy = 100000, normal = 100000, hard = 100000, challenge = 100000 }
local USSRStartingCash
local BadGuyCashReserves = { easy = 100000, normal = 100000, hard = 100000, challenge = 100000 }
local BadGuyStartingCash

local AtkProductionIntervals = { easy = DateTime.Seconds(60), normal = DateTime.Seconds(40), hard = DateTime.Seconds(20), challenge = DateTime.Seconds(20) }
local AtkProductionInterval

local FirstAirDelays = { easy = DateTime.Seconds(180), normal = DateTime.Seconds(120), hard = DateTime.Seconds(60) }
local FirstAirDelay

---@type blueprint[]
local USSRBaseBlueprints =
{
	{ type = "apwr", actor = USSRPower1, cost = 500, shape = { 3, 3 }, location = CPos.New(38, 38) },
	{ type = "apwr", actor = USSRPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(49, 39) },
	{ type = "apwr", actor = USSRPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(34, 43) },
	{ type = "apwr", actor = USSRPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(30, 44) },

    { type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(38, 32) },
    { type = "silo", actor = USSRSilo1, cost = 1400, shape = { 1, 1 }, location = CPos.New(47, 36) },
    { type = "silo", actor = USSRSilo2, cost = 1400, shape = { 1, 1 }, location = CPos.New(48, 35) },
	{ type = "silo", actor = USSRSilo2, cost = 1400, shape = { 1, 1 }, location = CPos.New(49, 36) },

    { type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(39, 42), owner = USSR, producer = true },
    { type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(45, 42), owner = USSR, producer = true },
    { type = "spen", actor = USSRSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(52, 30), owner = USSR, producer = true },

	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(50, 36) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(53, 41) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(51, 43) },
	{ type = "afld", actor = USSRAfld4, cost = 500, shape = { 3, 2 }, location = CPos.New(31, 48) },

    { type = "fix", actor = USSRFix, cost = 1000, shape = { 3, 3 }, location = CPos.New(41, 30) },
    { type = "dome", actor = USSRDome, cost = 1500, shape = { 2, 3 }, location = CPos.New(52, 38) },

    { type = "ftur", actor = USSRFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(40, 49) },
    { type = "ftur", actor = USSRFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(45, 49) },
    { type = "tsla", actor = USSRTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(39, 48) },
    { type = "tsla", actor = USSRTsla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(46, 48) },

    { type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(40, 36) },
    { type = "sam", actor = USSRSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(48, 38) },
    { type = "sam", actor = USSRSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(37, 46) },
	{ type = "sam", actor = USSRSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(47, 47) }
}

---@type blueprint[]
local BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGPower1, cost = 500, shape = { 2, 3 }, location = CPos.New(102, 34) },
	{ type = "apwr", actor = BGPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(91, 30) }
}

local BGPower3, BGPower4, BGProc, BGBarr, BGWeap, BGSpen, BGAfld1, BGAfld2, BGAfld3, BGFtur1, BGFtur2, BGTsla1 =
nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
---@type blueprint[]
local BadGuyBaseExtraBlueprints =
{
    { type = "apwr", actor = BGPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(99, 33) },
	{ type = "apwr", actor = BGPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(91, 33) },

    { type = "proc", actor = BGProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(100, 36) },

    { type = "barr", actor = BGBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(97, 36), owner = BadGuy, producer = true },
    { type = "weap", actor = BGWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(91, 37),owner = BadGuy, producer = true },
    { type = "spen", actor = BGSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(80, 32),owner = BadGuy, producer = true },

	{ type = "afld", actor = BGAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 30) },
	{ type = "afld", actor = BGAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 32) },
	{ type = "afld", actor = BGAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 34) },

    { type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(95, 42) },
    { type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(99, 42) },
    { type = "tsla", actor = BGTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(97, 40) }
}

---@type blueprint[]
local TurkeyBaseBlueprints =
{
    -- Power outpost
	{ type = "apwr", actor = TurkPower1, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48)  }, 
	{ type = "apwr", actor = TurkPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower6, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) },
    -- Island
    { type = "tsla", actor = IslandTsla1, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla2, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla3, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla4, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla5, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "sam", actor = IslandSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam3, cost = 700, shape = { 2, 2 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }
}

-------------------------
-- Land Attacks Data   --
-------------------------

local VehicleAttackInterval = { easy = DateTime.Seconds(180), normal = DateTime.Minutes(150), hard = DateTime.Minutes(120), challenge = DateTime.Minutes(120)}

local USSRAttackPaths =
{
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP6.Location, Waypoint34.Location},
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP4.Location, Waypoint32.Location, Waypoint33.Location}
}
local BadGuyAttackPaths = { {BGAttackRallyWP.Location}}

local InfantryTypes = { "e1", "e2", "e4"}
local InfantryAttackGroup = { }

local InfantryAttackGroupSizes = { easy = 6, normal = 9, hard = 12, challenge = 12 }
local InfantryAttackGroupSize

---@type string[]
local VehicleTypes = { "3tnk", "3tnk", "3tnk", "v2rl", "v2rl", "4tnk" }
local VehicleAttackGroup = {}

local VehicleAttackGroupSizes = { easy = 2, normal = 3, hard = 4, challenge = 4 }
local VehicleAttackGroupSize

local VehicleUSSRAttackGroup = { }
local VehicleBadGuyAttackGroup = { }

local InfantryUSSRAttackGroup = { }
local InfantryBadGuyAttackGroup = { }

local CombatRole = "regular" -- Roles: "regular", "guard", "marine"

---@type guard_pos
BeachGuardPositions = {
	{ group = { }, location = CPos.New(62, 58) }
}

-----------------------
-- Air Attacks Data  --
-----------------------

local CurrentAirWave = 1
local BasePlanes = {}

local AircraftTypes = { "yak", "mig" }
local PlanesAttackGroup = { }

local SovietAircraftOrigin = Utils.Random({SovietAircraftEastOrigin1, SovietAircraftEastOrigin2})

---@type { types: string[], interval: number, path: cpos[], owner?: player }[]
local SovietAirTeams = {
	{ 
		types = { "yak" },
		interval = DateTime.Seconds(105),
		path = { SovietAircraftOrigin.Location + CVec.New(2, 0), SovietAircraftOrigin.Location + CVec.New(-1, 0) },
		owner = USSR
	},
	{ 
		types ={ "yak", "yak" },
		interval = DateTime.Seconds(115),
		path = { SovietAircraftOrigin.Location + CVec.New(2, 0), SovietAircraftOrigin.Location + CVec.New(-1, 0) }
	},
	{ 
		types = { "mig", "mig" },
		interval = DateTime.Seconds(165),
		path = { SovietAircraftOrigin.Location + CVec.New(2, 0), SovietAircraftOrigin.Location + CVec.New(-1, 0) },
		onWaveDefeated = function()
			if Difficulty ~= "hard" then
				return
			end
			SendBomber(SovietAircraftTopOrigin1.Location)
			SendBomber(SovietAircraftTopOrigin2.Location)
		end
	},
		{ types = { "mig", "mig", "yak" },
		interval = DateTime.Seconds(220),
		path = { SovietAircraftOrigin.Location + CVec.New(2, 0), SovietAircraftOrigin.Location + CVec.New(-1, 0) }
	},
	{ 
		types = { "mig", "mig", "mig", "yak", "yak", "yak", "yak" },
		interval = DateTime.Seconds(210),
		path = { SovietAircraftOrigin.Location + CVec.New(2, 0), SovietAircraftOrigin.Location + CVec.New(-1, 0) },
		onWaveDefeated = function()

			SendBomber(SovietAircraftTopOrigin1.Location)
			SendBomber(SovietAircraftTopOrigin2.Location)
		end
	},
		{ types = { "mig", "mig", "yak", "yak" },
		interval = DateTime.Seconds(210),
		path = { SovietAircraftOrigin.Location + CVec.New(2, 0), SovietAircraftOrigin.Location + CVec.New(-1, 0) }
	}
}

-------------------------
-- Naval Attacks Data  --
-------------------------

local SubTypes = { "ss"}

local SubUSSRAttackGroup = { }
local SubBadGuyAttackGroup = { }

local SubAttackGroupSizes = { easy = 1, normal = 1, hard = 2, challenge = 2}

local NavalAtkPath = { }

local LSTNeededFlag = false

local LSTDetectionPivot = LstDetectionZone
local LSTDetectionRange = WDist.FromCells(5)

local LSTPathRoute = { LstDetectionZone.Location, USSRUnloadUnits.Location }

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

---@param array cpos[]
---@return cpos[]
function ReverseTable(array)
	local table_to_reverse = array
	local reversed_table = { }

	for i = #table_to_reverse, 1, -1 do
    	table.insert(reversed_table, table_to_reverse[i])
	end
	return reversed_table
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

---@param owner player
---@return boolean
function IsHarvesterMissing(owner)
	return #owner.GetActorsByType("harv") == 0 -- true / false
end

---Issues an order to player to produce a harvester if there is enough cash
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

function RandomizedAircraftOrigin()
	SovietAircraftOrigin = Utils.Random({SovietAircraftEastOrigin1, SovietAircraftEastOrigin2})
end

--------------------------------------------------------------------
-----------------	UTILS BLOCK - END	----------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function ______________BASE_MANAGEMENT______________() end

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
			--ProduceAircraft(actor, owner)
		elseif blueprint.type == "spen" then
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
		if CombatRole == "regular" then
			CombatRole = "marine"
		else
			CombatRole = "regular"
		end
	end
end

---@return integer|nil
function CheckBeachGuardVacancy()
	local points = BeachGuardPositions
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
local function ________________Infantry_Attacks________________() end

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

-- Didn't add a Dog production func() cuz there is no kenn on USSR main base. Added extra dogs instead

-----------------------
-----------------------
--- Armor Attacks   ---
-----------------------
-----------------------
local function ________________Tank_Attacks________________() end

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

--@param producer actor
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
			elseif CombatRole == "guard" and index then -- GUARD
				SetGuardPoint(index)
			elseif CombatRole == "marine" then -- MARINE
				--add these for b scenario
				FetchUnitsToTransport(VehicleUSSRAttackGroup, USSRLoadUnits.Location)
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
	BeachGuardPositions[index].group = VehicleUSSRAttackGroup
	local units = BeachGuardPositions[index].group
	local pos = BeachGuardPositions[index].location

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
				u.Stance = "AttackAnything"
				Trigger.Clear(u, "OnDamaged")
				Utils.Do(units, function(u)
					IdleHunt(u)
				end)
			end
		end)

		Trigger.OnAllKilled(units, function()
			BeachGuardPositions[index].group = { }
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
local function ________________Air_Attacks________________() end

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

---@param spawn_loc cpos
function SendBomber(spawn_loc)
	if AvailableTypeCheck({USSR, BadGuy}, "afld") then
		return
	end

	local proxy = Actor.Create("powerproxy.parabombs", false, { Owner = USSR })
	local targets = Utils.Where(Greece.GetActors(), function(actor)
		return
			actor.HasProperty("Sell") and
			actor.Type ~= "brik" and
			actor.Type ~= "sbag"
	end)

	if #targets > 0 then
		local target = Utils.Random(targets)
		local angle = BomberAngle( target.Location, spawn_loc)
		proxy.TargetAirstrike( target.CenterPosition, angle )
		proxy.Destroy()
	end
end

---@param origin cpos
---@param dst cpos
---@return wangle
function BomberAngle(origin, dst)

	local X_to_angle = origin.X - dst.X 
	local Y_to_angle = dst.Y - origin.Y 

	local rad = math.atan2( Y_to_angle, X_to_angle )
	local deg = math.deg( rad )

	local wangle_units = (1024 * deg / 360)
	local new_angle = math.floor( ( ( wangle_units - 256 ) % 1024 ) )

	return Angle.New(new_angle)
end

function PrepareAircraftReinforcements()
	local delay = FirstAirDelay

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
	RandomizedAircraftOrigin()

	if not team then
		team = SovietAirTeams[#SovietAirTeams]
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

			if team.onWaveDefeated then
				team.onWaveDefeated()
			end

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
local function _______________Naval_Attacks_______________() end

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
		local path = NavalAtkPath
		owner.Build(toBuild, function(units)
			if owner == USSR then
				table.insert(SubUSSRAttackGroup, units[1])
				if #SubUSSRAttackGroup >= SubAttackGroupSize then
					Trigger.AfterDelay(DateTime.Seconds(2), function() -- Added time to check way this works sometimes doesn't. Still no clue
						SendUnits(SubUSSRAttackGroup, NavalAtkPath)
						Trigger.AfterDelay(DateTime.Seconds(2), function()
							SubUSSRAttackGroup = { }
						end)
					end)
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
					SendUnits(SubBadGuyAttackGroup, path)
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
	local center_pos = waypoint.CenterPosition

	local lst = Map.ActorsInCircle(center_pos, LSTDetectionRange, function(actor)	
		return actor.Type == "lst" and actor.Owner == USSR and actor.PassengerCount <= 0
	end)[1]

	if lst then
		return lst
	else
		ProduceLST(USSRSpen, USSR)
	end
end

-- Similar to "SendUnits" but for lst to unload passengers at last waypoint and going back following the same path.
---@param lst actor
---@param path cpos[]
function SendLST(lst, path)
	local go_path = path
	local return_path = ReverseTable(path)

	Trigger.OnIdle(lst, function()
		if not lst.IsDead then
			if FindLstInArea(LSTDetectionPivot) then
				Utils.Do(path, function(p)
					lst.Move(p)
				end)
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

--------------------------------------------------------------------
----------------	AI ATTACKING BLOCK - END        ----------------
--------------------------------------------------------------------
local function ______________AI_SETUP______________() end

function SetAIDifficulty()
	USSRStartingCash = USSRCashReserves[Difficulty]
    BadGuyStartingCash = BadGuyCashReserves[Difficulty]

	AtkProductionInterval = AtkProductionIntervals[Difficulty]

	InfantryAttackGroupSize = InfantryAttackGroupSizes[Difficulty]
	VehicleAttackGroupSize = VehicleAttackGroupSizes[Difficulty]

	FirstAirDelay = FirstAirDelays[Difficulty]

	SubAttackGroupSize = SubAttackGroupSizes[Difficulty]

end

function SetupAIActivities()
	SetAIDifficulty()

    USSR.Cash = USSRStartingCash
    BadGuy.Cash = BadGuyStartingCash
    
    BeginBaseMaintenance(USSRBaseBlueprints, USSR)
    BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

    BuildBase(USSRBaseBlueprints, USSRFact, USSR)

	PrepareAircraftReinforcements()

end

-- Activated once USSR is alerted
function RunUSSRActivities()

    ProduceInfantry(USSRBarr, USSR)
	ProduceArmor(USSRWeap, USSR)

    --ProduceSubs(USSRSpen, USSR)
end

-- Activated once BadGuy is alerted
function RunBadGuyActivities()
    InsertBlueprints(BadGuyBaseBlueprints, BadGuyBaseExtraBlueprints)
    BuildBase(BadGuyBaseBlueprints, BadGuyFact, BadGuy)

	-- Attack creation is started upon producer building creation
end
