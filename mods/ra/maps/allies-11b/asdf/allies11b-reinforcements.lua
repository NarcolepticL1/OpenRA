--[[
local Greece = Player.GetPlayer("Greece")
local England = Player.GetPlayer("England")
local USSR = Player.GetPlayer("USSR")
local BadGuy = Player.GetPlayer("BadGuy")

--- Ticks between submarine reinforcements once Turkey's island is attacked.
local SubmarineIntervals =
{
	normal = DateTime.Seconds(120)
}

local BomberTargetTypes = { "barr", "kenn", "hpad", "spen", "syrd", "tent", "weap" }
local CurrentAirWave = 1
local FirstAirDelays =
{
	easy = DateTime.Seconds(180),
	normal = DateTime.Seconds(120)
}

---@return boolean
local function IsForwardCommandFallen()
	return ForwardCommand.IsDead or ForwardCommand.Owner ~= BadGuy
end

---@return boolean
local function AreSovietPlanesActive()
	local planes = { "mig", "yak" }
	return #USSR.GetActorsByTypes(planes) > 0 or #BadGuy.GetActorsByTypes(planes) > 0
end

---@param player player
---@return boolean
local function HasAirfield(player)
	return player.HasPrerequisites({ "afld" })
end

--- Try to reassign a stranded air unit to a base that can resupply it.
---@param aircraft actor
---@param exit cpos
local function OnAircraftStranded(aircraft, exit)
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

---@param enemyPlayer player
---@param targetTypes string[]
---@return actor|nil
local function SelectBomberTarget(enemyPlayer, targetTypes)
	local targetPool = enemyPlayer.GetActorsByTypes(targetTypes)

	if #targetPool > 0 then
		return Utils.Random(targetPool)
	end

	return nil
end

---@param entryCell cpos
---@param target? actor
local function SendBomber(entryCell, target)
	target = target or SelectBomberTarget(Greece, BomberTargetTypes)

	if not target then
		Trigger.AfterDelay(DateTime.Seconds(15), function()
			SendBomber(entryCell)
		end)

		return
	end

	local proxy = Actor.Create("powerproxy.parabombs", false, { Owner = USSR } )
	proxy.TargetAirstrike(target.CenterPosition, (Map.CenterOfCell(entryCell) - target.CenterPosition).Facing)
	proxy.Destroy()
end

---@type { interval: number, types: string[], path: cpos[], owner: player, onWaveDefeated: fun() }[]
local SovietAirTeams =
{
	{
		types = { "yak" },
		interval = DateTime.Seconds(105),
		path = { Waypoint57.Location }
	},
	{
		types = { "yak", "yak" },
		interval = DateTime.Seconds(114),
		path = { Waypoint65.Location }
	},
	{
		owner = BadGuy,
		types = { "mig", "mig" },
		interval = DateTime.Seconds(165),
		path = { Waypoint83.Location, Waypoint83.Location + CVec.New(-1, 0) },
		onWaveDefeated = function()
			if Difficulty ~= "hard" then
				return
			end

			SendBomber(Waypoint57.Location)
			SendBomber(Waypoint65.Location)
		end
	},
	{
		interval = DateTime.Seconds(219),
		types = { "mig", "mig", "yak" },
		path = { Waypoint83.Location, Waypoint83.Location + CVec.New(-1, 0) },
	},
	-- Original includes 2x Hind. Replaced with Yaks.
	{
		interval = DateTime.Seconds(210),
		types = { "mig", "mig", "mig", "yak", "yak", "yak", "yak" },
		path = { Waypoint84.Location, Waypoint84.Location + CVec.New(-1, 0) },
		onWaveDefeated = function()
			SendBomber(Waypoint28.Location)
			SendBomber(Waypoint28.Location)
		end
	}
}

-- TODO REMOVE
DebugAirTeams = function()
	FirstAirDelays[Difficulty] = 5
end
DebugAirTeams()

---@param wave integer
local function ScheduleAirWave(wave)
	local team = SovietAirTeams[wave]
	if not team then
		return
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
				if unit.AmmoCount() > 0 or HasAirfield(unit.Owner) then
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

local function PrepareAircraftReinforcements()
	local delay = FirstAirDelays[Difficulty] or FirstAirDelays["normal"]

	Trigger.AfterDelay(delay, function()
		if IsForwardCommandFallen() then
			return
		end

		ScheduleAirWave(1)
	end)
end

--- Begin Submarine reinforcements once Turkey's island is attacked.
--- Original chain is trigger end1 -> trigger sub2 -> team sub1.
---@param interval number
---@param entryCell cpos
local function ScheduleCommandSubs(interval, entryCell)
	Trigger.AfterDelay(interval, function()
		if IsForwardCommandFallen() then
			return
		end

		local sub = Actor.Create("ss", true, { Owner = USSR, Location = entryCell, Facing = Angle.South })
		sub.Scatter()
		IdleHunt(sub)
		ScheduleCommandSubs(interval, entryCell)
	end)
end

local function PrepareTurkey()
	local alerted = false
	local defenses = { IslandCoil1, IslandCoil2, IslandCoil3, IslandCoil4, IslandCoil5, IslandSam1, IslandSam2, IslandSam3 }
	local interval = SubmarineIntervals[Difficulty] or SubmarineIntervals["normal"]

	OnAnyDamaged(defenses, function(victim, attacker)
		if alerted or victim.Owner.Faction == attacker.Owner.Faction then
			return
		end

		alerted = true
		ScheduleCommandSubs(interval, Waypoint96.Location)
	end)
end

local TimeUntilEngland =
{
	easy = DateTime.Minutes(80),
	normal = DateTime.Minutes(60),
	hard = DateTime.Minutes(30)
}
--TODO remove
local DebugTimer = false
if DebugTimer then
	TimeUntilEngland[Difficulty] = DateTime.Seconds(7)
end

local EnglandReinforced = false
local CruisersReinforced = false

local function FlashNavyText()
	local basic = HSLColor.White
	local message = UserInterface.GetFluentMessage("the-navy-has-arrived")

	for i = 0, 9 do
		local color = basic

		if i % 2 == 0 then
			color = England.Color
		end

		Trigger.AfterDelay(DateTime.Seconds(i), function()
			UserInterface.SetMissionText(message, color)
		end)
	end

	Trigger.AfterDelay(DateTime.Seconds(10), function()
		UserInterface.SetMissionText("")
	end)
end

---@param delay integer
local function StartEnglandTimer(delay)
	Trigger.AfterDelay(delay, function()
		Media.PlaySpeechNotification(Greece, "TimerStarted")
		DateTime.TimeLimit = TimeUntilEngland[Difficulty] - delay
	end)
end

--- Cruisers attempt to reach the north end. Original teams: sea3, sea4.
---@param paths cpos[][]
local function ReinforceCruisers(paths)
	if CruisersReinforced then
		return
	end

	CruisersReinforced = true
	local cruisers = { Cruiser1, Cruiser2 }
	local i = 1

	Utils.Do(paths, function(path)
		local exit = path[#path]
		local cruiser = cruisers[i]
		-- These start neutral to avoid sharing vision.
		cruiser.Owner = England
		cruiser.IsInWorld = true
		i = i + 1

		Utils.Do(path, function(cell)
			if cell == path[1] then
				cruiser.MoveIntoWorld(cell)
				return
			end

			cruiser.Move(cell)
		end)

		Trigger.OnIdle(cruiser, function()
			if cruiser.Location == exit then
				return
			end

			cruiser.Move(exit)
		end)
	end)
end

--- Some ships precede the Cruisers. Original teams: sea1, sea2.
---@param paths cpos[][]
local function ReinforceCruiserEscorts(paths)
	local signalCells = { }

	local types = { "pt", "pt", "dd", "dd" }
	if Difficulty == "easy" then
		types = { "pt", "pt", "pt", "dd", "dd", "dd" }
	end

	Utils.Do(paths, function(path)
		local exit = path[#path]
		-- Near the river's midpoint, we will call in both Cruisers.
		signalCells[#signalCells + 1] = path[3]

		Reinforcements.Reinforce(England, types, { path[1] }, 25, function(ship)
			Utils.Do(Utils.Skip(path, 1), function(cell)
				ship.AttackMove(cell, 2)
			end)

			Trigger.OnIdle(ship, function()
				if ship.Location ~= exit then
					ship.AttackMove(exit)
					return
				end

				ship.Destroy()
			end)
		end)
	end)

	Trigger.OnEnteredFootprint(signalCells, function(a, id)
		if a.Owner ~= England then
			return
		end

		Trigger.RemoveFootprintTrigger(id)
		ReinforceCruisers(paths)
	end)

	-- In case the escorts never reach a third waypoint. Original behavior was
	-- to fail the mission if England was wiped out before Cruisers reinforced.
	Trigger.AfterDelay(DateTime.Seconds(40), function()
		ReinforceCruisers(paths)
	end)
end

local function ReinforceEngland()
	if EnglandReinforced then
		return
	end

	local paths =
	{
		west =
		{
			Waypoint28.Location,
			Waypoint27.Location,
			Waypoint52.Location,
			Waypoint53.Location,
			Waypoint54.Location,
			Waypoint55.Location,
			Waypoint56.Location,
			-- Takes the place of Waypoint57.
			EnglandExit1.Location
		},
		east =
		{
			Waypoint58.Location,
			Waypoint59.Location,
			Waypoint60.Location,
			Waypoint61.Location,
			Waypoint62.Location,
			Waypoint63.Location,
			Waypoint64.Location,
			-- Takes the place of Waypoint65.
			EnglandExit2.Location
		}
	}

	ReinforceCruiserEscorts(paths)
	Media.PlaySpeechNotification(Greece, "AlliedForcesApproaching")
end

local function PrepareEngland()
	StartEnglandTimer(DateTime.Seconds(3))

	Utils.Do({ Cruiser1, Cruiser2 }, function(c)
		c.IsInWorld = false
	end)

	Trigger.OnTimerExpired(function()
		FlashNavyText()
		ReinforceEngland()
	end)
end

PrepareEngland()
PrepareTurkey()
PrepareAircraftReinforcements()
]]