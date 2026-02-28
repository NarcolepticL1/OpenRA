--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

---@class blueprint
---@field type string
---@field actor actor
---@field cost integer
---@field shape integer[]
---@field location cpos 
---@field owner? player
---@field produce? string
---@field northwestEdge? wpos
---@field southeastEdge? wpos
-- Could add a new field for when to SellBuilding

---@class airWave
---@field types string[]
---@field interval number
---@field path cpos[]
---@field owner? player

DebugMsgEnabled = true

SetDifficulty = function()
    if Difficulty == "easy" then
        StartingCash = 7000

        USSRStartingCash = 75000
        BadGuyStartingCash = 30000

		OnlyOneMCV = false

		TimerTicks = DateTime.Minutes(90)

		TimeBeforeSams = DateTime.Minutes(10)


		AtkProductionInterval = DateTime.Seconds(60)

		Blk1Units1 = { "3tnk" }
		Blk1Units2 = { "4tnk", "v2rl" }
		Blk1Units3 = { "4tnk", "v2rl" }
		Blk1Units4 = { "4tnk", "v2rl" }
		Blk1Units5 = { "e4", "e4", "e4", "e4" }


    elseif Difficulty == "normal" then
        StartingCash = 6000

        USSRStartingCash = 100000
        BadGuyStartingCash = 40000

		OnlyOneMCV = false

		TimerTicks = DateTime.Minutes(72)

		TimeBeforeSams = DateTime.Minutes(7)

		AtkProductionInterval = DateTime.Seconds(40)

		Blk1Units1 = { "3tnk", "3tnk" }
		Blk1Units2 = { "4tnk", "v2rl", "v2rl" }
		Blk1Units3 = { "4tnk", "v2rl", "v2rl" }
		Blk1Units4 = { "4tnk", "v2rl", "v2rl" }
		Blk1Units5 = { "e4", "e4", "e4", "e4", "e4" }

    elseif Difficulty == "hard" then
		StartingCash = 5000

        USSRStartingCash = 100000
        BadGuyStartingCash = 40000

		OnlyOneMCV = true

		TimerTicks = DateTime.Minutes(60)

		TimeBeforeSams = DateTime.Minutes(5)

		AtkProductionInterval = DateTime.Seconds(20)

		Blk1Units1 = { "3tnk", "3tnk", "3tnk" }
		Blk1Units2 = { "4tnk", "4tnk", "v2rl", "v2rl" }
		Blk1Units3 = { "4tnk", "4tnk", "v2rl", "v2rl" }
		Blk1Units4 = { "4tnk", "4tnk", "v2rl", "v2rl" }
		Blk1Units5 = { "e4", "e4", "e4", "e4", "e4", "e4" }

		Periodic1Units = { "4tnk", "4tnk" }
		Periodic2Units = { "e4", "e4", "e4", "e4", "e1", "e1", "e1", "e2", "e2"  }
		Periodic3Units = { "4tnk", "4tnk", "v2rl", "v2rl" }
		Periodic4Units = { "v2rl", "v2rl", "v2rl" }
	end
end

--------------------------------------------------------------------
-----------------	    DATA BLOCK - START	------------------------
--------------------------------------------------------------------
local function ______DATA______() end

Periodic1Units = 
{
	hard = { "4tnk", "4tnk" },
	normal = { "4tnk" },
	easy = { "3tnk" }
}

Periodic2Units = 
{
	hard = { "e4", "e4", "e4", "e4", "e1", "e1", "e1", "e2", "e2"  },
	normal = { "e4", "e4", "e4", "e1", "e1", "e2", "e2" },
	easy = { "e4", "e4", "e1", "e1", "e2" }
}

Periodic3Units = 
{
	hard = { "4tnk", "4tnk", "v2rl", "v2rl" },
	normal = { "4tnk", "v2rl", "v2rl" },
	easy = { "4tnk", "v2rl" }
}

Periodic4Units = 
{
	hard = { "v2rl", "v2rl", "v2rl" },
	normal = { "v2rl", "v2rl" },
	easy = { "v2rl" }
}

BadguyPeriodic1Units = 
{
	hard = { "e2", "e2", "e2", "e4", "e4", "e4" },
	normal = { "e2", "e2", "e2", "e4", "e4" },
	easy = { "e2", "e2", "e2", "e4" }
}

BadguyPeriodic2Units = 
{
	hard = { "e1", "e1", "e2", "e2", "e2", "e2" },
	normal = { "e1", "e1", "e2", "e2", "e2" },
	easy = { "e1", "e1", "e2", "e2" }
}

BadguyPeriodic3Units = 
{
	hard = { "3tnk","3tnk", "v2rl", "v2rl" },
	normal = { "3tnk", "v2rl", "v2rl" },
	easy = { "3tnk", "v2rl" }
}

BadguyPeriodic4Units = 
{ hard =
{ "3tnk", "3tnk", "3tnk", "3tnk" }, 
normal =
{ "3tnk", "3tnk", "3tnk" }, 
easy =
{ "3tnk", "3tnk" } }

Blk1UnitsGroup = { }
Blk2UnitsGroup = { }
Blk3UnitsGroup = { }
Blk4UnitsGroup = { }
Blk5UnitsGroup = { }
Periodic1UnitsGroup = { }
Periodic2UnitsGroup = { }
Periodic3UnitsGroup = { }
Periodic4UnitsGroup = { }
BadguyPeriodic1UnitsGroup = { }
BadguyPeriodic2UnitsGroup = { }
BadguyPeriodic3UnitsGroup = { }
BadguyPeriodic4UnitsGroup = { }

AirGroup1 = { "yak" }
AirGroup2 = { "yak", "yak" }
AirGroup3 = { "mig", "mig" }
AirGroup4 = { "mig", "mig", "yak" }
AirGroup5 = { "mig", "mig", "mig", "yak", "yak", "yak", "yak" }

--AirGroup1Route = { WP96.Location }
--AirGroup2Route = { WP96.Location }
--AirGroup3Route = { WP83.Location }
--AirGroup4Route = { WP83.Location }
--AirGroup5Route = { WP84.Location }

---@type actor
USSRSam1, USSRSam2, USSRSam3, USSRSam4 = nil, nil, nil, nil
---@type blueprint[]
USSRBaseBlueprints =
{
	{ type = "powr", actor = USSRPower1, cost = 300, shape = { 2, 3 }, location = CPos.New(56, 42) },
	{ type = "apwr", actor = USSRPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(37, 42) },
	{ type = "apwr", actor = USSRPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(39, 39) },
	{ type = "powr", actor = USSRPower4, cost = 300, shape = { 2, 3 }, location = CPos.New(44, 39) },
	{ type = "apwr", actor = USSRPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(52, 39) },
	{ type = "apwr", actor = USSRPower6, cost = 500, shape = { 3, 3 }, location = CPos.New(55, 39) },
	{ type = "apwr", actor = USSRPower7, cost = 500, shape = { 3, 3 }, location = CPos.New(58, 41) },

	{ type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(41, 42) },

	{ type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(46, 45), owner = USSR, produce = "a" },
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

USSRBaseSamsBlueprints =
{
		-- I think these should be added to counter allies aircraft on normal/hard
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(38, 52) },
	{ type = "sam", actor = USSRSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(42, 39) },
	{ type = "sam", actor = USSRSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(55, 52) },
	{ type = "sam", actor = USSRSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(56, 38) }
}

BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGPower1, cost = 300, shape = { 3, 3 }, location = CPos.New(98, 47) },
	{ type = "apwr", actor = BGPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(90, 51) },
}

---@type actor
BGPower3, BGPower4, BGPower5, BGProc, BGBarr, BGWeap, BGDome, BGAfld1, BGAfld2, BGFtur1, BGFtur2, BGTesla1, BGTesla2, BGSam1, BGSam2, BGSam3, BGSam4 =
nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
BadGuyBaseExtraBlueprints = 
{
	{ type = "apwr", actor = BGPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) },
	{ type = "apwr", actor = BGPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 52) },
	{ type = "apwr", actor = BGPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 55) },

	{ type = "proc", actor = BGProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(100, 55) },

	{ type = "barr", actor = BGBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(95, 50) },
	{ type = "weap", actor = BGWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(92, 55) },

	{ type = "dome", actor = BGDome, cost = 1400, shape = { 2, 3 }, location = CPos.New(93, 51) }, --Added dome for BadGuy's "v2rl" prerequisite

	{ type = "afld", actor = BGAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(88, 54) },
	{ type = "afld", actor = BGAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(88, 56) },

	{ type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(96, 60) },
	{ type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(100, 60) },
    { type = "tsla", actor = BGTesla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(98, 58) },
    { type = "tsla", actor = BGTesla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(97, 50) },

	{ type = "sam", actor = BGSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 51) },
	{ type = "sam", actor = BGSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 59) },
	{ type = "sam", actor = BGSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(104, 59) },
	{ type = "sam", actor = BGSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(104, 47) }
}

--@type { interval: number, types: string[], path: cpos[], owner: player, onWaveDefeated: fun() }[]
---@type airWave[]
SovietAirTeams =
{
	{ types = { "yak", "yak" }, interval = DateTime.Seconds(120), path = { SovietAircraftOrigin1.Location }, owner = USSR},
	{ types = { "yak", "yak" }, interval = DateTime.Seconds(110), path = { SovietAircraftOrigin1.Location }},
	{ types = { "yak", "mig" }, interval = DateTime.Seconds(110), path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1.Location + CVec.New(-1, 0) }	},
	{ types = { "yak", "yak", "yak" }, interval = DateTime.Seconds(219),  path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1.Location + CVec.New(-1, 0) } },
	{ types = { "yak", "yak", "mig" }, interval = DateTime.Seconds(210), path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1	.Location + CVec.New(-1, 0) } }
}

--------------------------------------------------------------------
-----------------	    DATA BLOCK - END	------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	UTILS BLOCK - START	----------------------------
--------------------------------------------------------------------
local function ________________UTILS________________() end

---@param owner player
IsHarvesterMissing = function(owner)
	return #owner.GetActorsByType("harv") == 0
end

---@param owner player
CheckPlayerMoney = function(owner)
	return owner.Cash + owner.Resources
end

---@param player player
GrantCash = function(player, amount)
    player.Cash = player.Cash + amount
end

--Insert blueprints[] to player base building blueprints[]
---@param blueprints blueprint[]
---@param insert blueprint[]
InsertBlueprints = function(blueprints, insert)
    Utils.Do(insert, function(b)
        local index = #blueprints
		table.insert(blueprints, index, b)
        PrepareBlueprintEdges(b)
    end)
end

---@param type string
--@param producer actor
---@param owner player
BuildingAvailabilityCheck = function(type, owner)
	--if producer == nil then
	--	if 
	--		return true
	--	else
	--		return false
	--end
	
	--[[
	if not producer.IsDead or producer.Owner == owner then
		return true
	else
		return false
	end
	]]

	if owner.GetActorsByType(type) > 0 --[[or producer.Owner == owner]] then
		return true
	else
		return false
	end
end



--Once a building is rebuilt, checks what type of producer building it is and starts unit production
---@param producer actor
---@param owner player
ProductionCheck = function(producer, owner)
		--Media.Debug("Entered")
		--ProduceInfantry(producer, owner)
	--end
--[[
	--end
	if actorType == "barr" then
		ProduceInfantry(producer, owner)
	elseif actorType == "weap"  then
		ProduceArmor()
	elseif actorType == "spen" then
		--ProduceShips()
	elseif actorType == "afld" then
		ProduceAircraft()
	end
]]
end

--For Debug
D = function(msg)
	if DebugMsgEnabled then
		Media.Debug(tostring(msg))
	end
end
--------------------------------------------------------------------
-----------------	UTILS BLOCK - END	----------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function ________________BASE_MANAGEMENT________________() end

---@param blueprints blueprint[]
---@param cyard any
---@param owner player
BuildBase = function(blueprints, cyard, owner)
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
BuildBlueprint = function(blueprints, blueprint, cyard, owner)
	Trigger.AfterDelay(Actor.BuildTime(blueprint.type), function()
		if cyard.IsDead or cyard.Owner ~= owner then
			return
		elseif CheckPlayerMoney(owner) <= 299 --[[and IsHarvesterMissing()]] then
			return
		end

		if IsBuildAreaBlocked(owner, blueprint) then
			Trigger.AfterDelay(DateTime.Seconds(2--[[5]]), function()
				BuildBlueprint(blueprints, blueprint, cyard, owner)
			end)
			return
		end

		local actor = Actor.Create(blueprint.type, true, { Owner = owner, Location = blueprint.location })
		OnBlueprintBuilt(actor, blueprint, owner)
		Trigger.AfterDelay(DateTime.Seconds(1--[[10]]), function()
			BuildBase(blueprints, cyard, owner)
		end)
	end)
end

---@param actor actor
---@param blueprint blueprint
---@param owner player
OnBlueprintBuilt = function(actor, blueprint, owner)
	owner.Cash = owner.Cash - blueprint.cost
	blueprint.actor = actor
	MaintainBuilding(actor, blueprint, 0.75)


	Trigger.AfterDelay(1, function()
		D(blueprint.type)
		if blueprint.type ~= "barr" and blueprint.type ~= "weap" and blueprint.type ~= "afld" and blueprint.type ~= "spen" then
			return
		end

--NW 61, 29
--SE 105, 103

		if blueprint.type == "barr" then
			ProduceInfantry(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceWeap(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceAircraft(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceSubs(actor, owner)
		end
		--[[
		Media.Debug(tostring(actor))
		Media.Debug(tostring(blueprint.actor))
		Media.Debug(tostring(blueprint.type))
		Media.Debug(tostring(blueprint.produce))
		if blueprint.produce then
			Media.Debug("Here?")
			ProductionCheck(actor, owner)
			]]
			--[[
			Trigger.AfterDelay(DateTime.Seconds(1), function()
				actor.Kill()
			end)
			-- Build() will not work properly on producers if immediately called.
			Trigger.AfterDelay(1, function()
				Trigger.OnBuildingPlaced(owner, function(p, a)
					if a.Type == "barr" then
						Media.Debug("ProduceInfantry")
					elseif a.Type == "weap" then
						Media.Debug("ProduceArmor")
					elseif a.Type == "afld" then
						Media.Debug("ProduceAircraft")
					elseif a.Type == "afld" then
						Media.Debug("ProduceSubs")
					elseif a.Type ~= "barr" or a.Type ~= "weap" or a.Type ~= "afld" or a.Type ~= "spen" then
						Media.Debug("No production")
					end
				end)
				blueprint.onBuilt(actor)
			end)]]
	end)
end

---@param blueprint blueprint
---@param owner player
IsBuildAreaBlocked = function(owner, blueprint)
	local nw, se = blueprint.northwestEdge, blueprint.southeastEdge
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
ScatterBlockers = function(actors, owner)
	Utils.Do(actors, function(a)
		if a.IsIdle and a.Owner == owner and a.HasProperty("Scatter") then
			a.Scatter()
		end
	end)
end

---@param blueprints blueprint[]
---@param owner player
BeginBaseMaintenance = function(blueprints, owner)
	Utils.Do(blueprints, function(blueprint)
		MaintainBuilding(blueprint.actor, blueprint)
	end)
	Utils.Do(owner.GetActors(), function(actor)
		if actor.HasProperty("StartBuildingRepairs") then
			MaintainBuilding(actor, nil, 0.75)
		end
	end)
end

---@param actor actor
---@param blueprint blueprint
---@param repairThreshold number
MaintainBuilding = function(actor, blueprint, repairThreshold)
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

---@param blueprint blueprint
PrepareBlueprintEdges = function(blueprint)
	local shapeX, shapeY = blueprint.shape[1], blueprint.shape[2]
	local northwestEdge = Map.CenterOfCell(blueprint.location) + WVec.New(-512, -512, 0)
	local southeastEdge = northwestEdge + WVec.New(shapeX * 1024, shapeY * 1024, 0)
	blueprint.northwestEdge = northwestEdge
	blueprint.southeastEdge = southeastEdge
end

---Issues an order to player to produce an harvester if there is enough cash
---@param producer actor
---@param owner player
---@param delay number
ProduceHarvester = function(producer, owner, delay)
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


---@param producer actor
---@param owner player
ProducerAvailableCheck = function(producer, owner)
	local type = producer.Type
	if #owner.GetActorsByType(type) > 0 then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - END	--------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------		ATTACKING BLOCK - START	--------------------
--------------------------------------------------------------------
local function ________________AI_ATTACKS________________() end

---@param units actor[]
---@param path cpos[]
SendUnits = function(units, path)
	Utils.Do(units, function(unit)
		if unit.IsDead then
			return
		end

		unit.Patrol(path, false)
		IdleHunt(unit)
	end)
end

-----------------------
--- Inf Attacks     ---
-----------------------
local function __INF_ATTACKS__() end

LandAtkPaths = { MammothPatrolWP10.Location }

InfantryUnits = { "e1", "e2", "e4"}

InfantryAttackGroup = { }

InfantryAttackGroupSize = 12

---@param producer actor
---@param owner player
ProduceInfantry = function(producer, owner)
	if not ProducerAvailableCheck(producer, owner) then
		return
	elseif CheckPlayerMoney(owner) <= 299 --[[and IsHarvesterMissing()]] then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(InfantryUnits) }

	owner.Build(toBuild, function(units)
		table.insert(InfantryAttackGroup, units[1])

		if #InfantryAttackGroup >= InfantryAttackGroupSize then
			SendUnits(InfantryAttackGroup, LandAtkPaths)
			InfantryAttackGroup = { }
			Trigger.AfterDelay(AtkProductionInterval, function()
				ProduceInfantry(producer, owner)
			end)
		else
			Trigger.AfterDelay(delay, function()
				ProduceInfantry(producer, owner)
			end)
		end
	end)
end

-----------------------
--- Armor Attacks   ---
-----------------------
local function __ARMOR_ATTACKS__() end

VehicleTypes = { "3tnk", "4tnk", "v2rl"}

VehicleAttackGroup = {}

VehicleAttackGroupSize = 5

---@param producer actor
---@param owner player
ProduceArmor = function(producer, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if not ProducerAvailableCheck(producer, owner) then
		return
	--elseif IsHarvesterMissing() then
		--ProduceHarvester(factory, owner, delay)
		--return
	end

	local toBuild = { Utils.Random(VehicleTypes) }
	local target = {}

	owner.Build(toBuild, function(units)
		table.insert(VehicleAttackGroup, units[1])

		if #VehicleAttackGroup >= VehicleAttackGroupSize then
			SendUnits(VehicleAttackGroup, LandAtkPaths)
			VehicleAttackGroup = { }
			Trigger.AfterDelay(DateTime.Minutes(3), function()
				ProduceArmor(producer, owner)
			end)
		else
			Trigger.AfterDelay(delay, function()
				ProduceArmor(producer, owner)
			end)
		end
	end)
end

ProduceSovietPeriodic1Units = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		ProduceSovietPeriodic2Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic1Units[#Periodic1UnitsGroup+1] }, function(units)
		table.insert(Periodic1UnitsGroup, units[1])
		if #Periodic1UnitsGroup < #Periodic1Units then
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic1Units)
		else
			SendPeriodic1UnitsAttackGroup()
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic2Units)
		end
	end)
end

--[[
ProduceSovietPeriodic2Units = function()
	if USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		ProduceSovietPeriodic3Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic2Units[#Periodic2UnitsGroup+1] }, function(units)
		table.insert(Periodic2UnitsGroup, units[1])
		if #Periodic2UnitsGroup < #Periodic2Units then
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic2Units)
		else
			SendPeriodic2UnitsAttackGroup()
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic3Units)
		end
	end)
end

ProduceSovietPeriodic3Units = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		ProduceSovietPeriodic2Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic3Units[#Periodic3UnitsGroup+1] }, function(units)
		table.insert(Periodic3UnitsGroup, units[1])
		if #Periodic3UnitsGroup < #Periodic3Units then
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic3Units)
		else
			SendPeriodic3UnitsAttackGroup()
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic4Units)
		end
	end)
end

ProduceSovietPeriodic4Units = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		ProduceSovietPeriodic2Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic4Units[#Periodic4UnitsGroup+1] }, function(units)
		table.insert(Periodic4UnitsGroup, units[1])
		if #Periodic4UnitsGroup < #Periodic4Units then
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic4Units)
		else
			SendPeriodic4UnitsAttackGroup()
			Trigger.AfterDelay(AtkProductionInterval, ProduceSovietPeriodic1Units)
		end
	end)
end
]]

-----------------------
--- Air Attacks     ---
-----------------------
local function __AIR_ATTACKS__() end

GetAirstrikeTarget = function()
	local list = Greece.GetGroundAttackers()

	if #list == 0 then
		return
	end
	
	local target = list[DateTime.GameTime % #list + 1].CenterPosition
	return target
end

SendAirstrike = function()
	if USSRAfld1.IsDead or USSRAfld1.Owner ~= USSR then
		return
	end
	local target = GetAirstrikeTarget()

	if target then
		USSRAfld1.TargetAirstrike(target, Angle.SouthWest + Angle.New(16))
		Trigger.AfterDelay(DateTime.Seconds(4), SendAirstrike)
	else
		Trigger.AfterDelay(DateTime.Seconds(4)/4, SendAirstrike)
	end
end

---@param unit actor
---@param route cpos[]
SendRenAirstrike = function(unit, route)
	if (USSRAfld1.IsDead or USSRAfld1.Owner ~= USSR) and (USSRAfld2.IsDead or USSRAfld2.Owner ~= USSR) and (USSRAfld3.IsDead or USSRAfld3.Owner ~= USSR) and (USSRAfld4.IsDead or USSRAfld4.Owner ~= USSR) then
		return
	end
	local attackers = Reinforcements.Reinforce(USSR, unit, route)
	for i = 1, #attackers do
		InitializeAttackAircraft(attackers[i], Greece)
	end
end

BasePlanes = {}
TotalAflds = 1

---@param owner player
AfldAvailableCheck = function(producer, owner)
	if not producer.IsDead or producer.Owner == owner then
		return true
	else
		return false
	end
	TotalAflds = USSR.GetActorsByType("afld")
end

---@param producer actor
---@param owner player
ProduceAircraft = function(producer, owner)
    if not ProducerAvailableCheck(producer, owner) then
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

--Out of map attacks
SendParabombs = function()
	if BaseAfld.IsDead or BaseAfld.Owner ~= USSR then
		return
	end

	local airfield = BaseAfld
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

	Trigger.AfterDelay(ParabombDelay, SendParabombs)
end

SendParadrop = function()
	if BaseAfld.IsDead or BaseAfld.Owner ~= USSR then
		return
	end

	local aircraft = ParadropProxy.TargetParatroopers(KosyginExtractPoint.CenterPosition)

	Utils.Do(aircraft, function(a)
		Trigger.OnPassengerExited(a, function(t, p)
			IdleHunt(p)
		end)
	end)
	Trigger.AfterDelay(ParadropDelay, SendParadrop)
end

CurrentAirWave = 1

PrepareAircraftReinforcements = function()
	local delay = DateTime.Seconds(10)--FirstAirDelays[Difficulty] or FirstAirDelays["normal"]

	Trigger.AfterDelay(delay, function()
		ScheduleAirWave(1)
	end)
end

---@param player player
HasAirfield = function(player)
	return player.HasPrerequisites({ "afld" })
end

---@param wave integer
ScheduleAirWave = function(wave)
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
				if unit.AmmoCount() > 0 --[[or HasAirfield(unit.Owner)]] then -- #BasePlanes < TotalAflds
					table.insert(BasePlanes, unit)
					return
				elseif HasAirfield(unit.Owner) and #BasePlanes < TotalAflds then
					return
				end
				OnAircraftStranded(unit, team.path[1])

			end)
		end)

		Trigger.OnAllRemovedFromWorld(units, function()
			if AreSovietPlanesActive() then
				return
			end

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

---@param aircraft Actor
---@param exit CPos
OnAircraftStranded = function(aircraft, exit)
	--Media.Debug("Stranded check")
	local oldOwner = aircraft.Owner
	--[[
	if oldOwner == USSR and HasAirfield(BadGuy) then
		aircraft.Owner = BadGuy
	elseif oldOwner == BadGuy and HasAirfield(USSR) then
		aircraft.Owner = USSR
	end
	]]
	if oldOwner == aircraft.Owner then
		--Media.Debug("Send aircraft to elimination")
		aircraft.Stop()
		aircraft.Move(exit)
		aircraft.Destroy()
	end
end

AreSovietPlanesActive = function()
	local planes = { "mig", "yak" }
	return #USSR.GetActorsByTypes(planes) > 0
end

-----------------------
--- Naval Attacks   ---
-----------------------
local function __NAVAL_ATTACKS__() end

SubTypes = { "ss"}

SubAttackGroup = { }

SubAttackGroupSize = 5

NavalAtkPath = { }

---@param producer actor
---@param owner player
ProduceSubs = function(producer, owner)
	if not SpenAvailableCheck(producer, owner) then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	owner.Build(SubTypes, function(units)
		table.insert(SubAttackGroup, units[1])

		if #SubAttackGroup >= SubAttackGroupSize then
			SendUnits(SubAttackGroup, NavalAtkPath)
			SubAttackGroup = { }
			Trigger.AfterDelay(AtkProductionInterval, function()
				ProduceSubs(producer, owner)
			end)
		else
			Trigger.AfterDelay(delay, function()
				ProduceSubs(producer, owner)
			end)
		end
	end)
end

--------------------------------------------------------------------
----------------		ATTACKING BLOCK - END	--------------------
--------------------------------------------------------------------

SetupAIActivities = function()

	BeginBaseMaintenance(USSRBaseBlueprints, USSR)
	BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

	Trigger.AfterDelay(DateTime.Seconds(1), function()
		InsertBlueprints(USSRBaseBlueprints, USSRBaseSamsBlueprints)
		BuildBase(USSRBaseBlueprints, USSRFact, USSR)
	end)

	Trigger.AfterDelay(DateTime.Seconds(10), function()
		ProduceInfantry(USSRBarr, USSR)
	end)

	Trigger.AfterDelay(DateTime.Seconds(10), function()
		ProduceArmor(USSRWeap, USSR)
	end)

	PrepareAircraftReinforcements()

--[[
	Trigger.AfterDelay(DateTime.Minutes(5), ProduceSovietBlk1Vehicle)
	Trigger.AfterDelay(DateTime.Seconds(126), function()
		SendRenAirstrike(AirGroup1, AirGroup1Route)
	end)

	Trigger.AfterDelay(DateTime.Seconds(432), SendAirstrike)
]]

end

-- Activated once BadGuy if alerted
RunBadGuyActivities = function ()
	InsertBlueprints(BadGuyBaseBlueprints, BadGuyBaseExtraBlueprints)
	BuildBase(BadGuyBaseBlueprints, BadGuyFact, BadGuy)

end
