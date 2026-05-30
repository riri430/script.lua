__DIZZY_UPLOAD_VERSION = "ENVY_AR_ANTIKB_NOFREEZE_V2"
__DIZZY_JUMP_CACHE = __DIZZY_JUMP_CACHE or {UntilTime = 0, Result = false, LastStatusTime = 0, LastDeepScanTime = 0}
__DIZZY_DROP_SUPPRESS_TOOL_UNTIL = __DIZZY_DROP_SUPPRESS_TOOL_UNTIL or 0
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character
local humanoid
local humanoidRootPart
local screenGui
local mainFrame
local statusLabel
local BUTTON_BLACK = Color3.fromRGB(0, 0, 0)
local PANEL_COLOR = Color3.fromRGB(25, 25, 30)
local LEFT_COLOR = Color3.fromRGB(32, 32, 40)
local RIGHT_COLOR = Color3.fromRGB(36, 36, 44)
local SELECTED_COLOR = Color3.fromRGB(18, 54, 125)
local BOX_COLOR = Color3.fromRGB(45, 45, 55)
local SECTION_COLOR = Color3.fromRGB(50, 50, 62)

local buttonsLocked = false
local minimized = false

local DEFAULT_WALK_SPEED = 16
local MIN_SPEED = 2
local MAX_SPEED = 60

local speedMode = "Safe"
local safeSpeedValue = 40
local carrySpeedValue = 30
local laggerSpeedValue = 25
local laggerCarrySpeedValue = 20

local autoMoving = false
local currentAutoSide = nil
local currentAutoRun = 0

local AUTO_SCAN_RADIUS = 450
local AUTO_LEFT_STAND_OFFSET = 8.5
local AUTO_RIGHT_STAND_OFFSET = 7
local FLIP_AUTO_SIDES = false

local fixedAutoParts = {}

local batAimbotEnabled = false
local batTargetPlayer = nil

local BAT_FLY_SPEED = 58
local BAT_START_BOOST_SPEED = 50
local BAT_FOLLOW_DISTANCE = 1.4
local BAT_TOO_CLOSE_DISTANCE = 0.9
local BAT_STOP_DISTANCE = 0.6
local BAT_FOLLOW_HEIGHT = 0.15
local BAT_PREDICTION = 0.12
local BAT_RESPONSE = 22
local BAT_TARGET_VELOCITY_MULTIPLIER = 0.9

local jumpEnabled = false
local antiRagdollEnabled = false

local antiRagdollConnections = {}
local antiRagdollHeartbeatConnection = nil
local antiRagdollJumpGraceUntil = 0
local jumpDownSequenceGraceUntil = 0
local ANTI_RAGDOLL_JUMP_GRACE_TIME = 1.15
local CHILLI_STYLE_ANTI_RAGDOLL = true
local CHILLI_STATE_FIX_COOLDOWN = 0.045
local CHILLI_VELOCITY_CLAMP = 38
local CHILLI_UP_CLAMP = 55
local CHILLI_DOWN_CLAMP = -95
local CHILLI_MOVE_ASSIST_AFTER_HIT_TIME = 1.35
local CHILLI_MOVE_ASSIST_MIN_SPEED = 5

local antiKnockbackUntil = 0
local ANTI_KNOCKBACK_RECOVERY_TIME = 0.16
local ANTI_KNOCKBACK_EXTRA_SPEED = 24
local ANTI_KNOCKBACK_MAX_FALL_SPEED = -95
local ANTI_KNOCKBACK_MAX_UP_SPEED = 36

local lastMoveDirection = Vector3.zero
local keepMovingUntil = 0
local KEEP_MOVING_AFTER_HIT_TIME = 0

local lastKnockbackDetectTime = 0
local KNOCKBACK_DETECT_COOLDOWN = 0.12

local manualMoveUntil = 0
local MANUAL_MOVE_AFTER_HIT_TIME = 0
local MANUAL_MOVE_MIN_FLAT_SPEED = 2
local MANUAL_MOVE_STATE_COOLDOWN = 0.12
local lastManualMoveStateFix = 0

local activeMoveTouch = nil
local touchStartPosition = nil
local touchCurrentPosition = nil
local mobileMoveDirection = Vector3.zero

local MOBILE_TOUCH_DEADZONE = 14
local MOBILE_TOUCH_MAX_DISTANCE = 105

local selectedDownJump = 5
local MIN_DOWN_JUMP = 2
local MAX_DOWN_JUMP = 6

local totalJumpsInSequence = 0
local airborneSince = nil
local lastAirJumpTime = 0
local jumpDownPressCountV50 = 0
local lastJumpDownPressTimeV50 = 0
local JUMP_DOWN_PRESS_DEBOUNCE_V50 = 0.07
local lastDownTime = 0
local jumpDownHardGraceUntil = 0
local jumpDownForceUntil = 0
local JUMP_DOWN_FORCE_HOLD_TIME = 0.28
local cameraStabilizeUntil = 0
local CAMERA_STABILIZE_AFTER_HIT_TIME = 1.4
local lastRealJumpPressTime = 0
local tpDownLockUntil = 0
local autoTpDownEnabled = false
local autoTpDownHeight = 10
local MIN_AUTO_TP_DOWN_HEIGHT = 2
local MAX_AUTO_TP_DOWN_HEIGHT = 20
local lastAutoTpDownTime = 0
local AUTO_TP_DOWN_COOLDOWN = 0.22
local lastAutoTpDownHeight = 0

local AIR_JUMP_POWER = 72
local DOWNWARD_FORCE = -85
local SOFT_DOWNWARD_FORCE_WHILE_HOLDING = -62
local CARRY_JUMP_DOWN_FORCE_V49 = -55
local DROP_POP_UP_FORCE_V67 = 200
local DROP_POP_DOWN_FORCE_V67 = -255
local DROP_POP_UP_TIME_V67 = 0.045
local DROP_POP_RECOVER_TIME_V67 = 0.07
local DROP_POP_SNAP_UP_STUDS_V67 = 18
local CARRY_SAFE_DOWNWARD_FORCE = -30
local CARRY_SAFE_DOWNWARD_TIME = 0.34
local MIN_AIR_JUMP_INTERVAL = 0.2
local AIRBORNE_GRACE_TIME = 0.14
local DOWN_COOLDOWN = 0.45

local lastHeldTool = nil
local toolGuardUntil = 0
local TOOL_GUARD_TIME = 1.25

local PROTECTED_TOOL_NAMES = {
	["bat"] = true,
	["medusa"] = true
}

local RECOVER_TOOL_RADIUS = 120

local LOCAL_DROP_REMOTE_NAMES = {
	"DropBrainrot",
	"DropHeldBrainrot",
	"DropHeldItem",
	"DropItem",
	"DropCarry",
	"ReleaseCarry",
	"ReleaseHeld",
	"CancelCarry",
	"StopCarry",
	"StopHolding",
	"Drop"
}

local DROP_ITEM_KEYWORDS = {
	"brainrot",
	"brain",
	"carry",
	"carried",
	"held",
	"holding",
	"grab",
	"grabbed",
	"steal",
	"item"
}

local DROP_PROMPT_KEYWORDS = {
	"drop",
	"release",
	"cancel",
	"carry",
	"throw",
	"put down",
	"place"
}

local DROP_PROMPT_RADIUS = 18

local FLING_DROP_UP_POWER = 725
local FLING_DROP_FORWARD_POWER = 130
local FLING_DROP_AVATAR_UP_POWER = 170
local FLING_DROP_OBJECT_HEIGHT = 118

local FLING_DROP_DOWN_DELAY = 0.055
local FLING_DROP_DOWN_DELAY_2 = 0.14
local FLING_DROP_DOWN_DELAY_3 = 0.24
local FLING_DROP_DOWN_DISTANCE = 6
local FLING_DROP_GROUND_RAY_HEIGHT = 90
local FLING_DROP_GROUND_EXTRA_Y = 0.35

local DROP_V13_RECOVERY_DELAY = 1.05
local DROP_V13_SECOND_RECOVERY_DELAY = 1.35

local DROP_V19_MODE_INDEX = 2
local DROP_V19_MODES = {
	{Name = "LOW", AvatarUp = 145, RecoverDelay = 0.98},
	{Name = "MID", AvatarUp = 170, RecoverDelay = 0.88},
	{Name = "HIGH", AvatarUp = 190, RecoverDelay = 0.78},
	{Name = "V13", AvatarUp = 210, RecoverDelay = 1.05}
}

local movementJumpAmountLabel = nil
local autoTpDownHeightLabel = nil

local sectionButtons = {}
local OVERHEAD_TEXT_VALUE = "gg/mj4pUNcPd"
local overheadBillboard = nil
local floatingButtons = {}
local floatingButtonGroup = nil
local updateFloatingButtons = function() end

local function addCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object
end

local function setStatus(text)
	warn("[Dizzy Hub] " .. text)
end

local function clampSpeed(value)
	value = tonumber(value)

	if not value then
		return DEFAULT_WALK_SPEED
	end

	return math.clamp(value, MIN_SPEED, MAX_SPEED)
end

local function formatSpeed(value)
	if value % 1 == 0 then
		return tostring(math.floor(value))
	end

	return tostring(math.floor(value * 100 + 0.5) / 100)
end

local function getTargetSpeed()
	if speedMode == "Carry" then
		return carrySpeedValue
	elseif speedMode == "Lagger" then
		return laggerSpeedValue
	elseif speedMode == "Lagger Carry" then
		return laggerCarrySpeedValue
	else
		return safeSpeedValue
	end
end

local function getAutoSpeed()
	return math.clamp(safeSpeedValue, MIN_SPEED, MAX_SPEED)
end

local function applySpeed()
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	if batAimbotEnabled then
		humanoid.WalkSpeed = DEFAULT_WALK_SPEED
		return
	end

	if autoMoving then
		humanoid.WalkSpeed = getAutoSpeed()
		return
	end

	humanoid.WalkSpeed = clampSpeed(getTargetSpeed())
end

local function forceLocalSpeed()
	if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return
	end

	if autoMoving then
		humanoid.WalkSpeed = getAutoSpeed()
		return
	end

	if batAimbotEnabled then
		return
	end

	local targetSpeed = clampSpeed(getTargetSpeed())
	humanoid.WalkSpeed = targetSpeed

	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude <= 0.05 then
		return
	end

	local currentVelocity = humanoidRootPart.AssemblyLinearVelocity

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
		moveDirection.Unit.X * targetSpeed,
		currentVelocity.Y,
		moveDirection.Unit.Z * targetSpeed
	)
end

local function getGroundHitBelow()
	if not character or not humanoidRootPart then
		return nil
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = false

	local origin = humanoidRootPart.Position + Vector3.new(0, 60, 0)
	local direction = Vector3.new(0, -10000, 0)

	return workspace:Raycast(origin, direction, raycastParams)
end

local function zeroCharacterVelocity()
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.AssemblyLinearVelocity = Vector3.zero
			object.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

local function hardSnapToGroundOnce()
	if not character or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return false
	end

	local result = getGroundHitBelow()

	if not result then
		return false
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local rootHalfHeight = humanoidRootPart.Size.Y / 2

	local standingOffset = math.max((humanoid.HipHeight or 2) + rootHalfHeight - 0.35, 2.35)

	local targetPosition = Vector3.new(
		humanoidRootPart.Position.X,
		result.Position.Y + standingOffset,
		humanoidRootPart.Position.Z
	)

	local targetCFrame = CFrame.new(targetPosition, targetPosition + lookVector)

	pcall(function()
		humanoid.Sit = false
		humanoid.PlatformStand = false
		humanoid.Jump = false
	end)

	local wasAnchored = humanoidRootPart.Anchored
	humanoidRootPart.Anchored = true

	pcall(function()
		character:PivotTo(targetCFrame)
	end)

	humanoidRootPart.CFrame = targetCFrame
	zeroCharacterVelocity()

	pcall(function()
		humanoid:ChangeState(Enum.HumanoidStateType.Landed)
	end)

	RunService.Heartbeat:Wait()

	humanoidRootPart.Anchored = wasAnchored
	zeroCharacterVelocity()

	return true
end

local function tpDownToGround()
	if not character or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		setStatus("V31 TP DOWN: character not ready.")
		return
	end

	setStatus("V31 TP DOWN: hard snapping to ground now.")

	local restoreJumpEnabled = jumpEnabled
	jumpEnabled = false
	tpDownLockUntil = os.clock() + 0.28

	totalJumpsInSequence = 0
	airborneSince = nil
	lastAirJumpTime = os.clock()

	local snappedNow = hardSnapToGroundOnce()

	if not snappedNow then
		local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			currentVelocity.X * 0.05,
			-350,
			currentVelocity.Z * 0.05
		)

		setStatus("V31 TP DOWN: no ground hit, forcing straight down.")
	end

	task.spawn(function()
		local started = os.clock()

		while os.clock() - started < 0.28 do
			if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				break
			end

			hardSnapToGroundOnce()
			totalJumpsInSequence = 0
			airborneSince = nil

			if humanoid.FloorMaterial ~= Enum.Material.Air then
				break
			end

			task.wait(0.03)
		end

		zeroCharacterVelocity()

		tpDownLockUntil = 0

		if restoreJumpEnabled then
			jumpEnabled = true
		end

		totalJumpsInSequence = 0
		airborneSince = nil
		lastAirJumpTime = 0

		setStatus("V31 TP DOWN: grounded, jump restored.")
	end)
end

local function getHeightAboveGround()
	if not character or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return nil
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = false

	local origin = humanoidRootPart.Position
	local result = workspace:Raycast(origin, Vector3.new(0, -1500, 0), raycastParams)

	if not result then
		return nil
	end

	return math.max(0, origin.Y - result.Position.Y)
end

local function setAutoTpDownHeight(value)
	value = tonumber(value) or autoTpDownHeight
	autoTpDownHeight = math.clamp(math.floor(value + 0.5), MIN_AUTO_TP_DOWN_HEIGHT, MAX_AUTO_TP_DOWN_HEIGHT)
	lastAutoTpDownHeight = 0

	if autoTpDownHeightLabel and autoTpDownHeightLabel.Parent then
		autoTpDownHeightLabel.Text = tostring(autoTpDownHeight)
	end

	setStatus("Auto TP Down height set to " .. tostring(autoTpDownHeight) .. ".")
end

local function updateAutoTpDown()
	if not autoTpDownEnabled then
		lastAutoTpDownHeight = 0
		return
	end

	if os.clock() - lastAutoTpDownTime < AUTO_TP_DOWN_COOLDOWN then
		return
	end

	if os.clock() < tpDownLockUntil then
		return
	end

	local height = getHeightAboveGround()

	if not height then
		return
	end

	local selectedHeight = math.clamp(autoTpDownHeight, MIN_AUTO_TP_DOWN_HEIGHT, MAX_AUTO_TP_DOWN_HEIGHT)
	local crossedSelectedHeight = lastAutoTpDownHeight < selectedHeight and height >= selectedHeight

	lastAutoTpDownHeight = height

	if crossedSelectedHeight then
		lastAutoTpDownTime = os.clock()
		setStatus("Auto TP Down triggered at adjusted height " .. tostring(selectedHeight) .. ".")
		tpDownToGround()
	end
end

local function objectHasCashText(object)
	local textToCheck = string.lower(object.Name or "")

	local success, textValue = pcall(function()
		return object.Text
	end)

	if success and typeof(textValue) == "string" then
		textToCheck = textToCheck .. " " .. string.lower(textValue)
	end

	local hasCash = string.find(textToCheck, "cash") ~= nil
	local hasOffline = string.find(textToCheck, "offline") ~= nil

	return hasCash and hasOffline
end

local function getWorldPartFromObject(object)
	if object:IsA("BasePart") then
		return object
	end

	if object:IsA("Model") then
		return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
	end

	local current = object

	while current and current ~= workspace do
		if current:IsA("BasePart") then
			return current
		end

		if current:IsA("Model") then
			local part = current.PrimaryPart or current:FindFirstChildWhichIsA("BasePart", true)

			if part then
				return part
			end
		end

		if current:IsA("BillboardGui") or current:IsA("SurfaceGui") then
			local success, adornee = pcall(function()
				return current.Adornee
			end)

			if success and adornee and adornee:IsA("BasePart") then
				return adornee
			end
		end

		current = current.Parent
	end

	return nil
end

local function looksLikeCashSpot(object)
	if character and object:IsDescendantOf(character) then
		return false
	end

	if not objectHasCashText(object) then
		return false
	end

	local part = getWorldPartFromObject(object)

	if not part then
		return false
	end

	return true
end

local function findCashOnSide(side)
	if not humanoidRootPart then
		setStatus("Character not ready.")
		return nil
	end

	if fixedAutoParts[side] and fixedAutoParts[side].Parent then
		return fixedAutoParts[side]
	end

	local foundParts = {}
	local usedParts = {}

	for _, object in ipairs(workspace:GetDescendants()) do
		if looksLikeCashSpot(object) then
			local part = getWorldPartFromObject(object)

			if part and not usedParts[part] then
				usedParts[part] = true
				table.insert(foundParts, part)
			end
		end
	end

	if #foundParts == 0 then
		setStatus("No offline cash spots found.")
		return nil
	end

	if #foundParts == 1 then
		setStatus("Only one offline cash spot found.")
		fixedAutoParts.Left = foundParts[1]
		fixedAutoParts.Right = foundParts[1]
		return foundParts[1]
	end

	table.sort(foundParts, function(a, b)
		return a.Position.X < b.Position.X
	end)

	local leftPart = foundParts[1]
	local rightPart = foundParts[#foundParts]

	if FLIP_AUTO_SIDES then
		leftPart, rightPart = rightPart, leftPart
	end

	fixedAutoParts.Left = leftPart
	fixedAutoParts.Right = rightPart

	if side == "Left" then
		setStatus("Locked Left offline cash spot.")
		return fixedAutoParts.Left
	else
		setStatus("Locked Right offline cash spot.")
		return fixedAutoParts.Right
	end
end

local function isDirectPathClear(targetPosition)
	if not humanoidRootPart then
		return false
	end

	local origin = humanoidRootPart.Position + Vector3.new(0, 2, 0)
	local destination = targetPosition + Vector3.new(0, 2, 0)
	local direction = destination - origin

	if direction.Magnitude <= 2 then
		return true
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, raycastParams)

	if not result then
		return true
	end

	local hitDistance = (result.Position - origin).Magnitude
	local targetDistance = direction.Magnitude

	return hitDistance >= targetDistance - 4
end

local function stopMovement()
	if humanoid then
		humanoid:Move(Vector3.zero, false)
	end

	if humanoidRootPart then
		local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, currentVelocity.Y, 0)
	end
end

local function stopAutoMove()
	currentAutoRun += 1
	autoMoving = false
	currentAutoSide = nil

	stopMovement()
	applySpeed()

	setStatus("Auto stopped.")
	updateFloatingButtons()
end

local function isWaypointBackwards(waypointPosition, targetPosition)
	if not humanoidRootPart then
		return false
	end

	local currentPosition = humanoidRootPart.Position

	local toTarget = Vector3.new(targetPosition.X - currentPosition.X, 0, targetPosition.Z - currentPosition.Z)
	local toWaypoint = Vector3.new(waypointPosition.X - currentPosition.X, 0, waypointPosition.Z - currentPosition.Z)

	if toTarget.Magnitude < 1 or toWaypoint.Magnitude < 1 then
		return false
	end

	return toWaypoint.Unit:Dot(toTarget.Unit) < -0.2
end

local function smoothMoveAlongPoints(points, label, runId, timeout)
	if not humanoid or not humanoidRootPart then
		return false
	end

	timeout = timeout or 14

	local started = os.clock()
	local index = 1
	local finalStopDistance = 0.45
	local waypointPassDistance = 6

	while humanoid and humanoidRootPart and humanoid.Health > 0 do
		if runId ~= currentAutoRun then
			return false
		end

		local targetPosition = points[index]

		if not targetPosition then
			stopMovement()
			return true
		end

		targetPosition = Vector3.new(targetPosition.X, humanoidRootPart.Position.Y, targetPosition.Z)

		local currentPosition = humanoidRootPart.Position
		local difference = targetPosition - currentPosition
		local flatDifference = Vector3.new(difference.X, 0, difference.Z)
		local distance = flatDifference.Magnitude

		local isFinalPoint = index >= #points
		local passDistance = isFinalPoint and finalStopDistance or waypointPassDistance

		if distance <= passDistance then
			if isFinalPoint then
				stopMovement()
				return true
			else
				index += 1
				continue
			end
		end

		local direction = flatDifference.Unit
		local safeSpeed = getAutoSpeed()

		humanoid.WalkSpeed = safeSpeed
		humanoid:Move(direction, false)

		local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(direction.X * safeSpeed, currentVelocity.Y, direction.Z * safeSpeed)

		if os.clock() - started > timeout then
			stopMovement()
			return false
		end

		RunService.Heartbeat:Wait()
	end

	stopMovement()
	return false
end

local function pathfindToPosition(targetPosition, label, attempt)
	attempt = attempt or 1
	currentAutoRun += 1

	local thisRun = currentAutoRun
	autoMoving = true
	updateFloatingButtons()

	task.spawn(function()
		local function finish()
			if thisRun == currentAutoRun then
				autoMoving = false
				currentAutoSide = nil
				stopMovement()
				applySpeed()
				updateFloatingButtons()
			end
		end

		if not humanoid or not humanoidRootPart then
			setStatus("Character not ready.")
			finish()
			return
		end

		if humanoid.Health <= 0 then
			setStatus("Humanoid is dead.")
			finish()
			return
		end

		local speed = getAutoSpeed()
		humanoid.WalkSpeed = speed

		targetPosition = Vector3.new(targetPosition.X, humanoidRootPart.Position.Y, targetPosition.Z)

		local startPosition = humanoidRootPart.Position
		local totalDistance = (Vector3.new(targetPosition.X, 0, targetPosition.Z) - Vector3.new(startPosition.X, 0, startPosition.Z)).Magnitude

		local timeout = math.clamp((totalDistance / math.max(speed, 1)) + 6, 6, 24)

		setStatus("Finding path around walls/pillars to " .. label .. "...")

		local path = PathfindingService:CreatePath({
			AgentRadius = 3,
			AgentHeight = 5,
			AgentCanJump = true,
			AgentCanClimb = true,
			WaypointSpacing = 4
		})

		local success = pcall(function()
			path:ComputeAsync(humanoidRootPart.Position, targetPosition)
		end)

		if not success or path.Status ~= Enum.PathStatus.Success then
			if isDirectPathClear(targetPosition) then
				setStatus("Path failed, direct route is clear.")

				local reached = smoothMoveAlongPoints({ targetPosition }, label, thisRun, timeout)
				setStatus(reached and ("Reached " .. label .. ".") or ("Could not reach " .. label .. "."))

				finish()
				return
			end

			setStatus("No path around walls/pillars found.")
			finish()
			return
		end

		local points = {}
		local waypoints = path:GetWaypoints()

		for _, waypoint in ipairs(waypoints) do
			local point = Vector3.new(waypoint.Position.X, humanoidRootPart.Position.Y, waypoint.Position.Z)
			local distanceFromPlayer = (point - humanoidRootPart.Position).Magnitude

			if distanceFromPlayer > 4 then
				if not isWaypointBackwards(point, targetPosition) or not isDirectPathClear(targetPosition) then
					table.insert(points, point)
				end
			end
		end

		table.insert(points, targetPosition)

		local reached = smoothMoveAlongPoints(points, label, thisRun, timeout + 4)

		if thisRun ~= currentAutoRun then
			return
		end

		if reached then
			setStatus("Reached " .. label .. ".")
		else
			if attempt < 2 then
				setStatus("Smooth move blocked. Recalculating...")
				pathfindToPosition(targetPosition, label, attempt + 1)
				return
			else
				setStatus("Could not reach " .. label .. ".")
			end
		end

		finish()
	end)
end

local function getFixedStopPosition(side, cashPart)
	if not humanoidRootPart then
		return cashPart.Position
	end

	local otherCashPart = nil
	local standOffset = AUTO_RIGHT_STAND_OFFSET

	if side == "Left" then
		otherCashPart = fixedAutoParts.Right
		standOffset = AUTO_LEFT_STAND_OFFSET
	elseif side == "Right" then
		otherCashPart = fixedAutoParts.Left
		standOffset = AUTO_RIGHT_STAND_OFFSET
	end

	local stopPosition = cashPart.Position

	if otherCashPart and otherCashPart.Parent then
		local towardMiddle = otherCashPart.Position - cashPart.Position
		towardMiddle = Vector3.new(towardMiddle.X, 0, towardMiddle.Z)

		if towardMiddle.Magnitude > 0.1 then
			stopPosition = cashPart.Position + towardMiddle.Unit * standOffset
		end
	end

	return Vector3.new(stopPosition.X, humanoidRootPart.Position.Y, stopPosition.Z)
end

local function walkToCash(side)
	if not humanoid or not humanoidRootPart then
		setStatus("Character not ready.")
		return false
	end

	if humanoid.Health <= 0 then
		setStatus("Humanoid is dead.")
		return false
	end

	local cashPart = findCashOnSide(side)

	if not cashPart then
		return false
	end

	local targetPosition = getFixedStopPosition(side, cashPart)
	pathfindToPosition(targetPosition, side .. " offline cash stand point")
	return true
end

local function toggleAutoMove(side)
	if autoMoving and currentAutoSide == side then
		stopAutoMove()
		return
	end

	if autoMoving then
		stopAutoMove()
		task.wait(0.05)
	end

	currentAutoSide = side

	local started = walkToCash(side)

	if not started then
		currentAutoSide = nil
		autoMoving = false
		updateFloatingButtons()
	end
end

local function getClosestOtherPlayer()
	if not humanoidRootPart then
		return nil
	end

	local closestPlayer = nil
	local closestDistance = math.huge

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local otherCharacter = otherPlayer.Character
			local otherHumanoid = otherCharacter and otherCharacter:FindFirstChildOfClass("Humanoid")
			local otherRoot = otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart")

			if otherHumanoid and otherRoot and otherHumanoid.Health > 0 then
				local distance = (otherRoot.Position - humanoidRootPart.Position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestPlayer = otherPlayer
				end
			end
		end
	end

	return closestPlayer
end

local function stopBatAimbot()
	batAimbotEnabled = false
	batTargetPlayer = nil

	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = clampSpeed(getTargetSpeed())
	end

	if humanoidRootPart then
		local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, currentVelocity.Y, 0)
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	end

	setStatus("Bat Aimbot disabled.")
	updateFloatingButtons()
end

local function startBatAimbot()
	stopAutoMove()

	batTargetPlayer = getClosestOtherPlayer()

	if not batTargetPlayer or not batTargetPlayer.Character then
		batAimbotEnabled = false
		setStatus("No player found.")
		updateFloatingButtons()
		return
	end

	local targetRoot = batTargetPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not targetRoot or not humanoidRootPart then
		batAimbotEnabled = false
		setStatus("No target root found.")
		updateFloatingButtons()
		return
	end

	batAimbotEnabled = true

	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = DEFAULT_WALK_SPEED
	end

	local desiredPosition = targetRoot.Position - targetRoot.CFrame.LookVector * BAT_FOLLOW_DISTANCE + Vector3.new(0, BAT_FOLLOW_HEIGHT, 0)
	local difference = desiredPosition - humanoidRootPart.Position

	if difference.Magnitude > 0.1 then
		humanoidRootPart.AssemblyLinearVelocity = difference.Unit * BAT_START_BOOST_SPEED
	end

	setStatus("Bat Aimbot locked to " .. batTargetPlayer.Name .. ".")
	updateFloatingButtons()
end

local function toggleBatAimbot()
	if batAimbotEnabled then
		stopBatAimbot()
	else
		startBatAimbot()
	end
end

local function updateBatAimbot()
	if not batAimbotEnabled then
		return
	end

	if not character or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		stopBatAimbot()
		return
	end

	if not batTargetPlayer
		or not batTargetPlayer.Character
		or not batTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
		or not batTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
		or batTargetPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then

		batTargetPlayer = getClosestOtherPlayer()

		if not batTargetPlayer then
			stopBatAimbot()
			setStatus("No player found.")
			return
		end
	end

	local targetCharacter = batTargetPlayer.Character
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

	if not targetHumanoid or not targetRoot or targetHumanoid.Health <= 0 then
		batTargetPlayer = nil
		return
	end

	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = DEFAULT_WALK_SPEED

	local targetVelocity = targetRoot.AssemblyLinearVelocity
	local flatTargetVelocity = Vector3.new(targetVelocity.X, 0, targetVelocity.Z)

	local desiredPosition =
		targetRoot.Position
		- targetRoot.CFrame.LookVector * BAT_FOLLOW_DISTANCE
		+ Vector3.new(0, BAT_FOLLOW_HEIGHT, 0)
		+ flatTargetVelocity * BAT_PREDICTION

	local toDesired = desiredPosition - humanoidRootPart.Position
	local distanceToDesired = toDesired.Magnitude

	local toTarget = targetRoot.Position - humanoidRootPart.Position
	local distanceToTarget = toTarget.Magnitude

	if distanceToTarget < BAT_TOO_CLOSE_DISTANCE and distanceToTarget > 0.1 then
		local awayDirection = -toTarget.Unit
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(awayDirection.X * 8, math.clamp(targetVelocity.Y, -8, 8), awayDirection.Z * 8)
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		return
	end

	if distanceToDesired <= BAT_STOP_DISTANCE then
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			targetVelocity.X * BAT_TARGET_VELOCITY_MULTIPLIER,
			math.clamp(targetVelocity.Y * BAT_TARGET_VELOCITY_MULTIPLIER, -8, 8),
			targetVelocity.Z * BAT_TARGET_VELOCITY_MULTIPLIER
		)
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		return
	end

	local followVelocity = toDesired * BAT_RESPONSE

	if followVelocity.Magnitude > BAT_FLY_SPEED then
		followVelocity = followVelocity.Unit * BAT_FLY_SPEED
	end

	local targetMovementAssist = Vector3.new(
		targetVelocity.X * BAT_TARGET_VELOCITY_MULTIPLIER,
		math.clamp(targetVelocity.Y * BAT_TARGET_VELOCITY_MULTIPLIER, -8, 8),
		targetVelocity.Z * BAT_TARGET_VELOCITY_MULTIPLIER
	)

	local finalVelocity = followVelocity + targetMovementAssist

	if finalVelocity.Magnitude > BAT_FLY_SPEED then
		finalVelocity = finalVelocity.Unit * BAT_FLY_SPEED
	end

	humanoidRootPart.AssemblyLinearVelocity = finalVelocity
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
end

local function updateJumpAmountText()
	if movementJumpAmountLabel and movementJumpAmountLabel.Parent then
		movementJumpAmountLabel.Text = tostring(selectedDownJump)
	end
end

local function setDownJumpAmount(value)
	selectedDownJump = math.clamp(tonumber(value) or 5, MIN_DOWN_JUMP, MAX_DOWN_JUMP)
	updateJumpAmountText()
	setStatus("Downward jump set to jump " .. tostring(selectedDownJump) .. ".")
end

local function isAirborneState(state)
	return state == Enum.HumanoidStateType.Freefall
		or state == Enum.HumanoidStateType.Jumping
		or state == Enum.HumanoidStateType.FallingDown
end

local function isGroundedState(state)
	return state == Enum.HumanoidStateType.Running
		or state == Enum.HumanoidStateType.RunningNoPhysics
		or state == Enum.HumanoidStateType.Landed
		or state == Enum.HumanoidStateType.Climbing
		or state == Enum.HumanoidStateType.Seated
end

local function isAirborne()
	if not humanoid then
		return false
	end

	return isAirborneState(humanoid:GetState())
		or humanoid.FloorMaterial == Enum.Material.Air
end

local function resetJumpSequence()
	totalJumpsInSequence = 0
	jumpDownPressCountV50 = 0
	airborneSince = nil
end

local function getHeldTool()
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Tool")
end

local function rememberHeldTool()
	local tool = getHeldTool()

	if tool then
		lastHeldTool = tool

		pcall(function()
			tool.CanBeDropped = false
		end)

		return tool
	end

	lastHeldTool = nil
	return nil
end

local function reEquipLastHeldTool()
	if __DIZZY_DROP_SUPPRESS_TOOL_UNTIL and os.clock() < __DIZZY_DROP_SUPPRESS_TOOL_UNTIL then
		return
	end

	if not lastHeldTool then
		return
	end

	if os.clock() > toolGuardUntil then

		return
	end

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	if lastHeldTool.Parent == character then
		pcall(function()
			lastHeldTool.CanBeDropped = false
		end)
		return
	end

	local backpack = player:FindFirstChild("Backpack")

	if backpack and lastHeldTool.Parent == backpack then
		pcall(function()
			lastHeldTool.CanBeDropped = false
			humanoid:EquipTool(lastHeldTool)
		end)
	end
end

local function isProtectedToolName(name)
	name = string.lower(name or "")

	for protectedName in pairs(PROTECTED_TOOL_NAMES) do
		if string.find(name, protectedName) then
			return true
		end
	end

	return false
end

local function protectTool(tool)
	if tool and tool:IsA("Tool") then
		pcall(function()
			tool.CanBeDropped = false
		end)
	end
end

local function recoverProtectedTools()
	local dropped = 0
	local backpack = player:FindFirstChild("Backpack")

	if not backpack then
		setStatus("Backpack not found.")
		return
	end

	local function tryDropTool(tool)
		if not tool or not tool:IsA("Tool") then
			return
		end

		if not isProtectedToolName(tool.Name) then
			return
		end

		protectTool(tool)

		if tool.Parent == character then
			lastHeldTool = tool
			dropped += 1
			return
		end

		if tool.Parent == backpack then
			lastHeldTool = tool
			dropped += 1

			if humanoid then
				pcall(function()
					humanoid:EquipTool(tool)
				end)
			end

			return
		end

		if humanoidRootPart and tool:IsDescendantOf(workspace) then
			local handle = tool:FindFirstChild("Handle")

			if handle and handle:IsA("BasePart") then
				local distance = (handle.Position - humanoidRootPart.Position).Magnitude

				if distance <= RECOVER_TOOL_RADIUS then
					tool.Parent = backpack
					lastHeldTool = tool
					dropped += 1

					pcall(function()
						humanoid:EquipTool(tool)
					end)
				end
			end
		end
	end

	if character then
		for _, object in ipairs(character:GetDescendants()) do
			tryDropTool(object)
		end
	end

	for _, object in ipairs(backpack:GetDescendants()) do
		tryDropTool(object)
	end

	for _, object in ipairs(workspace:GetDescendants()) do
		tryDropTool(object)
	end

	if dropped > 0 then
		startToolGuard()
		setStatus("Droped/protected Bat or Medusa.")
	else
		setStatus("Could not find Bat or Medusa locally. Reset/rejoin or restore from server inventory.")
	end
end

local function autoProtectImportantTools()
	local backpack = player:FindFirstChild("Backpack")

	if character then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("Tool") and isProtectedToolName(object.Name) then
				protectTool(object)
			end
		end
	end

	if backpack then
		for _, object in ipairs(backpack:GetDescendants()) do
			if object:IsA("Tool") and isProtectedToolName(object.Name) then
				protectTool(object)
			end
		end
	end
end

local function isProtectedHeldName(name)
	name = string.lower(name or "")

	if string.find(name, "bat") or string.find(name, "medusa") then
		return true
	end

	return false
end

local function looksLikeDroppableHeldObject(object)
	if not object then
		return false
	end

	local name = string.lower(object.Name or "")

	if isProtectedHeldName(name) then
		return false
	end

	for _, keyword in ipairs(DROP_ITEM_KEYWORDS) do
		if string.find(name, keyword) then
			return true
		end
	end

	if object:GetAttribute("IsBrainrot") == true
		or object:GetAttribute("IsCarried") == true
		or object:GetAttribute("IsCarriedItem") == true
		or object:GetAttribute("Held") == true
		or object:GetAttribute("Holding") == true then
		return true
	end

	return false
end

local function findLocalDropRemotes()
	local remotes = {}
	local used = {}

	local locations = {
		game:GetService("ReplicatedStorage"),
		player,
		player:FindFirstChild("PlayerGui"),
		character,
		workspace
	}

	for _, location in ipairs(locations) do
		if location then
			for _, object in ipairs(location:GetDescendants()) do
				if object:IsA("RemoteEvent") then
					local lowerName = string.lower(object.Name)

					for _, remoteName in ipairs(LOCAL_DROP_REMOTE_NAMES) do
						local wanted = string.lower(remoteName)

						if lowerName == wanted
							or string.find(lowerName, "drop")
							or string.find(lowerName, "release")
							or string.find(lowerName, "carry") then

							if not used[object] then
								used[object] = true
								table.insert(remotes, object)
							end
						end
					end
				end
			end
		end
	end

	__DIZZY_DROP_REMOTE_CACHE = remotes
	return remotes
end

task.delay(0.8, function()
	pcall(function()
		__DIZZY_DROP_REMOTE_CACHE = findLocalDropRemotes()
	end)
end)

local function getRootOutsideCharacter(part)
	if not part or not character then
		return nil
	end

	if part:IsDescendantOf(character) then
		return nil
	end

	local model = part:FindFirstAncestorOfClass("Model")

	if model and model ~= character and not model:IsDescendantOf(character) then
		return model
	end

	return part
end

local HAND_PART_NAMES = {
	["lefthand"] = true,
	["righthand"] = true,
	["left hand"] = true,
	["right hand"] = true,
	["leftarm"] = true,
	["rightarm"] = true,
	["left arm"] = true,
	["right arm"] = true,
	["leftlowerarm"] = true,
	["rightlowerarm"] = true,
	["leftupperarm"] = true,
	["rightupperarm"] = true,
	["humanoidrootpart"] = true,
	["uppertorso"] = true,
	["torso"] = true
}

local function isHandOrCarryPart(part)
	if not part or not part:IsA("BasePart") then
		return false
	end

	return HAND_PART_NAMES[string.lower(part.Name or "")] == true
end

local function isSafeCharacterInternalObject(object)
	if not character or not object then
		return false
	end

	if object:IsDescendantOf(character) then
		if object:IsA("Accessory") then
			return true
		end

		if object:IsA("Tool") then
			return isProtectedHeldName(object.Name)
		end

		local lower = string.lower(object.Name or "")

		if string.find(lower, "humanoid")
			or string.find(lower, "animate")
			or string.find(lower, "health")
			or string.find(lower, "head")
			or string.find(lower, "torso")
			or string.find(lower, "arm")
			or string.find(lower, "leg")
			or string.find(lower, "hand")
			or string.find(lower, "foot") then
			return true
		end
	end

	return false
end

local function getDropCandidateFromConnectedPart(part)
	if not part or not character then
		return nil
	end

	if part:IsDescendantOf(character) then
		return nil
	end

	local model = part:FindFirstAncestorOfClass("Model")

	if model and model ~= character and not model:IsDescendantOf(character) then
		if not isProtectedHeldName(model.Name) then
			return model
		end
	end

	if not isProtectedHeldName(part.Name) then
		return part
	end

	return nil
end

local function jointConnectsCandidateToCharacter(joint, candidate)
	if not character or not joint or not candidate then
		return false
	end

	if joint:IsA("Weld") or joint:IsA("WeldConstraint") or joint:IsA("Motor6D") then
		local part0 = joint.Part0
		local part1 = joint.Part1

		if not part0 or not part1 then
			return false
		end

		return (part0:IsDescendantOf(candidate) and part1:IsDescendantOf(character))
			or (part1:IsDescendantOf(candidate) and part0:IsDescendantOf(character))
	elseif joint:IsA("Constraint") or joint:IsA("AlignPosition") or joint:IsA("AlignOrientation") then
		local a0 = joint.Attachment0
		local a1 = joint.Attachment1

		if not a0 or not a1 or not a0.Parent or not a1.Parent then
			return false
		end

		return (a0.Parent:IsDescendantOf(candidate) and a1.Parent:IsDescendantOf(character))
			or (a1.Parent:IsDescendantOf(candidate) and a0.Parent:IsDescendantOf(character))
	end

	return false
end

local function destroyAllJointsBetweenCandidateAndCharacter(candidate)
	local destroyed = 0

	if not candidate or not character then
		return destroyed
	end

	local scanRoots = {
		candidate,
		character,
		workspace
	}

	local seen = {}

	for _, rootObject in ipairs(scanRoots) do
		if rootObject then
			for _, object in ipairs(rootObject:GetDescendants()) do
				if not seen[object] then
					seen[object] = true

					if object:IsA("Weld")
						or object:IsA("WeldConstraint")
						or object:IsA("Motor6D")
						or object:IsA("Constraint")
						or object:IsA("AlignPosition")
						or object:IsA("AlignOrientation") then

						if jointConnectsCandidateToCharacter(object, candidate) then
							destroyed += 1

							pcall(function()
								object:Destroy()
							end)
						end
					end
				end
			end
		end
	end

	return destroyed
end

local function findLocalHeldObjectsForDrop()
	local found = {}
	local used = {}

	local function add(object)
		if not object or used[object] then
			return
		end

		if object == character then
			return
		end

		if isProtectedHeldName(object.Name) then
			return
		end

		if isSafeCharacterInternalObject(object) then
			return
		end

		used[object] = true
		table.insert(found, object)
	end

	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") then
				if not isProtectedHeldName(child.Name) then
					add(child)
				end
			elseif (child:IsA("Model") or child:IsA("BasePart")) and looksLikeDroppableHeldObject(child) then
				add(child)
			end
		end
	end

	if character then
		for _, object in ipairs(workspace:GetDescendants()) do
			if object:IsA("Weld") or object:IsA("WeldConstraint") or object:IsA("Motor6D") then
				local part0 = object.Part0
				local part1 = object.Part1

				if part0 and part1 then
					local candidate = nil

					if part0:IsDescendantOf(character) and isHandOrCarryPart(part0) then
						candidate = getDropCandidateFromConnectedPart(part1)
					elseif part1:IsDescendantOf(character) and isHandOrCarryPart(part1) then
						candidate = getDropCandidateFromConnectedPart(part0)
					elseif part0:IsDescendantOf(character) and not part1:IsDescendantOf(character) and looksLikeDroppableHeldObject(part1) then
						candidate = getDropCandidateFromConnectedPart(part1)
					elseif part1:IsDescendantOf(character) and not part0:IsDescendantOf(character) and looksLikeDroppableHeldObject(part0) then
						candidate = getDropCandidateFromConnectedPart(part0)
					end

					if candidate then
						add(candidate)
					end
				end
			elseif object:IsA("AlignPosition") or object:IsA("AlignOrientation") or object:IsA("Constraint") then
				local a0 = object.Attachment0
				local a1 = object.Attachment1

				if a0 and a1 and a0.Parent and a1.Parent then
					local candidate = nil

					if a0.Parent:IsDescendantOf(character) and isHandOrCarryPart(a0.Parent) then
						candidate = getDropCandidateFromConnectedPart(a1.Parent)
					elseif a1.Parent:IsDescendantOf(character) and isHandOrCarryPart(a1.Parent) then
						candidate = getDropCandidateFromConnectedPart(a0.Parent)
					elseif a0.Parent:IsDescendantOf(character) and looksLikeDroppableHeldObject(a1.Parent) then
						candidate = getDropCandidateFromConnectedPart(a1.Parent)
					elseif a1.Parent:IsDescendantOf(character) and looksLikeDroppableHeldObject(a0.Parent) then
						candidate = getDropCandidateFromConnectedPart(a0.Parent)
					end

					if candidate then
						add(candidate)
					end
				end
			end
		end
	end

	if humanoidRootPart then
		for _, object in ipairs(workspace:GetDescendants()) do
			if object:IsA("Model") then
				local part = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)

				if part
					and not object:IsDescendantOf(character)
					and looksLikeDroppableHeldObject(object)
					and (part.Position - humanoidRootPart.Position).Magnitude <= 12 then

					add(object)
				end
			elseif object:IsA("BasePart") then
				if not object:IsDescendantOf(character)
					and looksLikeDroppableHeldObject(object)
					and (object.Position - humanoidRootPart.Position).Magnitude <= 12 then

					add(object)
				end
			end
		end
	end

	return found
end

local function detachOneLocalDropObject(object)
	if not object or not object.Parent then
		return false
	end

	if isProtectedHeldName(object.Name) then
		return false
	end

	local destroyedJoints = destroyAllJointsBetweenCandidateAndCharacter(object)

	if object:IsA("Tool") then
		pcall(function()
			object.CanBeDropped = true
		end)

		local handle = object:FindFirstChild("Handle")

		if handle and handle:IsA("BasePart") and humanoidRootPart then
			object.Parent = workspace
			handle.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -4)
			handle.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * 14 + Vector3.new(0, 5, 0)
			return true
		end

		object.Parent = workspace
		return true
	end

	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("Weld")
			or descendant:IsA("WeldConstraint")
			or descendant:IsA("Motor6D")
			or descendant:IsA("AlignPosition")
			or descendant:IsA("AlignOrientation")
			or descendant:IsA("BallSocketConstraint")
			or descendant:IsA("HingeConstraint")
			or descendant:IsA("RodConstraint")
			or descendant:IsA("SpringConstraint") then

			pcall(function()
				descendant:Destroy()
			end)

			destroyedJoints += 1
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = true
			descendant.Massless = false

			if humanoidRootPart then
				descendant.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * 18 + Vector3.new(0, 6, 0)
			end
		end
	end

	if object:IsA("Model") then
		object.Parent = workspace

		if humanoidRootPart then
			pcall(function()
				object:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -5))
			end)
		end

		return true
	elseif object:IsA("BasePart") then
		object.Parent = workspace
		object.Anchored = false
		object.CanCollide = true
		object.Massless = false

		if humanoidRootPart then
			object.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			object.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * 18 + Vector3.new(0, 6, 0)
		end

		return true
	end

	return destroyedJoints > 0
end

local function fireSafeDropRemotes(heldObjects)
	local fired = false

	for _, remote in ipairs(findLocalDropRemotes()) do
		fired = true

		pcall(function()
			remote:FireServer()
		end)

		pcall(function()
			remote:FireServer("Drop")
		end)

		pcall(function()
			remote:FireServer("Release")
		end)

		pcall(function()
			remote:FireServer("CancelCarry")
		end)

		for _, heldObject in ipairs(heldObjects) do
			if heldObject and not isProtectedHeldName(heldObject.Name) then
				pcall(function()
					remote:FireServer(heldObject)
				end)

				pcall(function()
					remote:FireServer("Drop", heldObject)
				end)
			end
		end
	end

	return fired
end

local function textMatchesDropKeyword(text)
	text = string.lower(tostring(text or ""))

	for _, keyword in ipairs(DROP_PROMPT_KEYWORDS) do
		if string.find(text, keyword) then
			return true
		end
	end

	return false
end

local function activateNearbyDropPrompts()
	if not humanoidRootPart then
		return false
	end

	local activated = false

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("ProximityPrompt") then
			local promptPart = object.Parent
			local partPosition = nil

			if promptPart and promptPart:IsA("BasePart") then
				partPosition = promptPart.Position
			elseif promptPart and promptPart:IsA("Attachment") and promptPart.Parent and promptPart.Parent:IsA("BasePart") then
				partPosition = promptPart.Parent.Position
			end

			local closeEnough = true

			if partPosition then
				closeEnough = (partPosition - humanoidRootPart.Position).Magnitude <= DROP_PROMPT_RADIUS
			end

			local matches =
				textMatchesDropKeyword(object.Name)
				or textMatchesDropKeyword(object.ActionText)
				or textMatchesDropKeyword(object.ObjectText)

			if closeEnough and matches and object.Enabled then
				activated = true

				pcall(function()
					object.RequiresLineOfSight = false
				end)

				pcall(function()
					object.MaxActivationDistance = math.max(object.MaxActivationDistance, DROP_PROMPT_RADIUS)
				end)

				task.spawn(function()
					pcall(function()
						object:InputHoldBegin()
					end)

					task.wait(math.clamp((object.HoldDuration or 0) + 0.08, 0.08, 1.3))

					pcall(function()
						object:InputHoldEnd()
					end)
				end)
			end
		end
	end

	return activated
end

local function fireLocalDropBindables(heldObjects)
	local fired = false
	local locations = {
		player,
		player:FindFirstChild("PlayerGui"),
		character,
		game:GetService("ReplicatedStorage")
	}

	for _, location in ipairs(locations) do
		if location then
			for _, object in ipairs(location:GetDescendants()) do
				if object:IsA("BindableEvent") or object:IsA("BindableFunction") then
					if textMatchesDropKeyword(object.Name) then
						fired = true

						if object:IsA("BindableEvent") then
							pcall(function()
								object:Fire()
							end)

							pcall(function()
								object:Fire("Drop")
							end)

							for _, heldObject in ipairs(heldObjects) do
								pcall(function()
									object:Fire(heldObject)
								end)
							end
						else
							pcall(function()
								object:Invoke()
							end)

							pcall(function()
								object:Invoke("Drop")
							end)

							for _, heldObject in ipairs(heldObjects) do
								pcall(function()
									object:Invoke(heldObject)
								end)
							end
						end
					end
				end
			end
		end
	end

	return fired
end

local function callDropRemoteFunctions(heldObjects)
	local called = false
	local locations = {
		game:GetService("ReplicatedStorage"),
		player,
		player:FindFirstChild("PlayerGui"),
		character,
		workspace
	}

	for _, location in ipairs(locations) do
		if location then
			for _, object in ipairs(location:GetDescendants()) do
				if object:IsA("RemoteFunction") and textMatchesDropKeyword(object.Name) then
					called = true

					pcall(function()
						object:InvokeServer()
					end)

					pcall(function()
						object:InvokeServer("Drop")
					end)

					pcall(function()
						object:InvokeServer("Release")
					end)

					for _, heldObject in ipairs(heldObjects) do
						if heldObject and not isProtectedHeldName(heldObject.Name) then
							pcall(function()
								object:InvokeServer(heldObject)
							end)

							pcall(function()
								object:InvokeServer("Drop", heldObject)
							end)
						end
					end
				end
			end
		end
	end

	return called
end

local function tryBackpackDropToolOnly()

	if not character then
		return false
	end

	local didDrop = false

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") and not isProtectedHeldName(child.Name) then
			local lowerName = string.lower(child.Name)

			if textMatchesDropKeyword(lowerName) or looksLikeDroppableHeldObject(child) then
				pcall(function()
					child.CanBeDropped = true
				end)

				local handle = child:FindFirstChild("Handle")

				if handle and handle:IsA("BasePart") and humanoidRootPart then
					child.Parent = workspace
					handle.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
					handle.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * 16 + Vector3.new(0, 5, 0)
					didDrop = true
				end
			end
		end
	end

	return didDrop
end

local function getSnapDownCFrameForObject(object)
	if not humanoidRootPart then
		return nil
	end

	local rootCFrame = humanoidRootPart.CFrame
	local frontPosition = (rootCFrame * CFrame.new(0, 0, -FLING_DROP_DOWN_DISTANCE)).Position
	local rayOrigin = frontPosition + Vector3.new(0, FLING_DROP_GROUND_RAY_HEIGHT, 0)
	local rayDirection = Vector3.new(0, -FLING_DROP_GROUND_RAY_HEIGHT * 2, 0)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local excludeList = {}

	if character then
		table.insert(excludeList, character)
	end

	if object then
		table.insert(excludeList, object)
	end

	rayParams.FilterDescendantsInstances = excludeList
	rayParams.IgnoreWater = false

	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)

	local sizeY = 3

	if object then
		if object:IsA("Model") then
			local ok, size = pcall(function()
				return object:GetExtentsSize()
			end)

			if ok and size then
				sizeY = math.max(size.Y, 2)
			end
		elseif object:IsA("BasePart") then
			sizeY = math.max(object.Size.Y, 1)
		elseif object:IsA("Tool") then
			local handle = object:FindFirstChild("Handle")

			if handle and handle:IsA("BasePart") then
				sizeY = math.max(handle.Size.Y, 1)
			end
		end
	end

	local y = frontPosition.Y

	if result then
		y = result.Position.Y + (sizeY / 2) + FLING_DROP_GROUND_EXTRA_Y
	else
		y = humanoidRootPart.Position.Y - 2
	end

	local finalPosition = Vector3.new(frontPosition.X, y, frontPosition.Z)
	local _, yaw, _ = rootCFrame:ToOrientation()

	return CFrame.new(finalPosition) * CFrame.Angles(0, yaw, 0)
end

local function zeroDropObjectVelocity(object)
	if not object then
		return
	end

	local function zeroPart(part)
		if part and part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = true
			part.AssemblyLinearVelocity = Vector3.new(0, -4, 0)
			part.AssemblyAngularVelocity = Vector3.zero
		end
	end

	if object:IsA("Model") then
		for _, descendant in ipairs(object:GetDescendants()) do
			if descendant:IsA("BasePart") then
				zeroPart(descendant)
			end
		end
	elseif object:IsA("Tool") then
		local handle = object:FindFirstChild("Handle")

		if handle then
			zeroPart(handle)
		end
	elseif object:IsA("BasePart") then
		zeroPart(object)
	end
end

local function snapDropObjectDown(object)
	if not object or not object.Parent then
		return false
	end

	if isProtectedHeldName(object.Name) then
		return false
	end

	local targetCFrame = getSnapDownCFrameForObject(object)

	if not targetCFrame then
		return false
	end

	object.Parent = workspace

	if object:IsA("Model") then
		pcall(function()
			object:PivotTo(targetCFrame)
		end)

		zeroDropObjectVelocity(object)
		return true
	elseif object:IsA("Tool") then
		local handle = object:FindFirstChild("Handle")

		if handle and handle:IsA("BasePart") then
			pcall(function()
				handle.CFrame = targetCFrame
			end)

			zeroDropObjectVelocity(object)
			return true
		end
	elseif object:IsA("BasePart") then
		pcall(function()
			object.CFrame = targetCFrame
		end)

		zeroDropObjectVelocity(object)
		return true
	end

	return false
end

local function scheduleFastSnapDown(object)
	task.delay(FLING_DROP_DOWN_DELAY, function()
		snapDropObjectDown(object)
	end)

	task.delay(FLING_DROP_DOWN_DELAY_2, function()
		snapDropObjectDown(object)
	end)

	task.delay(FLING_DROP_DOWN_DELAY_3, function()
		snapDropObjectDown(object)
	end)
end

local function flingOneHeldObjectUp(object)
	if not object or not object.Parent then
		return false
	end

	if isProtectedHeldName(object.Name) then
		return false
	end

	local didFling = false

	local function flingPart(part)
		if not part or not part:IsA("BasePart") then
			return
		end

		part.Anchored = false
		part.CanCollide = true
		part.Massless = false

		if humanoidRootPart then
			part.CFrame = humanoidRootPart.CFrame * CFrame.new(0, FLING_DROP_OBJECT_HEIGHT, -6)
			part.AssemblyLinearVelocity =
				Vector3.new(0, FLING_DROP_UP_POWER, 0)
				+ humanoidRootPart.CFrame.LookVector * FLING_DROP_FORWARD_POWER
			part.AssemblyAngularVelocity = Vector3.new(35, 35, 35)
		else
			part.AssemblyLinearVelocity = Vector3.new(0, FLING_DROP_UP_POWER, 0)
			part.AssemblyAngularVelocity = Vector3.new(35, 35, 35)
		end

		didFling = true
	end

	if object:IsA("Model") then
		object.Parent = workspace

		if humanoidRootPart then
			pcall(function()
				object:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, FLING_DROP_OBJECT_HEIGHT, -6))
			end)
		end

		for _, part in ipairs(object:GetDescendants()) do
			if part:IsA("BasePart") then
				flingPart(part)
			end
		end
	elseif object:IsA("BasePart") then
		object.Parent = workspace
		flingPart(object)
	elseif object:IsA("Tool") then
		pcall(function()
			object.CanBeDropped = true
		end)

		local handle = object:FindFirstChild("Handle")
		object.Parent = workspace

		if handle and handle:IsA("BasePart") then
			flingPart(handle)
		end
	end

	return didFling
end

local lastDropSafeCFrame = nil

local function enableLocalRespawnSoftener()
	if not humanoid then
		return
	end

	pcall(function()
		humanoid.BreakJointsOnDeath = false
		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid.AutoRotate = true
	end)
end

local function lateDropRecovery()
	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	if not lastDropSafeCFrame then
		return
	end

	pcall(function()
		humanoidRootPart.CFrame = lastDropSafeCFrame
	end)

	pcall(function()
		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)

	humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
end

local function getDropV19Mode()
	return DROP_V19_MODES[DROP_V19_MODE_INDEX] or DROP_V19_MODES[2]
end

local function cycleDropV19Mode()
	DROP_V19_MODE_INDEX += 1

	if DROP_V19_MODE_INDEX > #DROP_V19_MODES then
		DROP_V19_MODE_INDEX = 1
	end

	local mode = getDropV19Mode()
	setStatus("DROP mode: " .. mode.Name .. " / " .. tostring(mode.AvatarUp))
end

local function getDropV19AvatarPower()
	local mode = getDropV19Mode()
	return mode.AvatarUp or FLING_DROP_AVATAR_UP_POWER
end

local function getDropV19RecoveryDelay()
	local mode = getDropV19Mode()
	return mode.RecoverDelay or DROP_V13_RECOVERY_DELAY
end

local function flingAvatarUpBriefly()
	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	lastDropSafeCFrame = humanoidRootPart.CFrame
	enableLocalRespawnSoftener()

	autoProtectImportantTools()

	pcall(function()
		humanoid.Jump = true
	end)

	local mode = getDropV19Mode()
	local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
		math.clamp(currentVelocity.X, -18, 18),
		getDropV19AvatarPower(),
		math.clamp(currentVelocity.Z, -18, 18)
	)

	task.delay(getDropV19RecoveryDelay(), function()
		lateDropRecovery()
	end)

	task.delay(getDropV19RecoveryDelay() + 0.24, function()
		lateDropRecovery()
	end)

	setStatus("DROP V19 " .. mode.Name .. " tried.")
end

local function safeAvatarPopForDropV67()
	if not character or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return false
	end

	local startCFrame = humanoidRootPart.CFrame
	local startHealth = humanoid.Health
	local oldBreakJointsOnDeath = humanoid.BreakJointsOnDeath
	local oldPlatformStand = humanoid.PlatformStand
	local oldSit = humanoid.Sit

	pcall(function()
		humanoid.BreakJointsOnDeath = false
		humanoid.Sit = false
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
	end)

	pcall(function()
		enableLocalRespawnSoftener()
	end)

	local function recoverDropPosition()
		if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
			return
		end

		local safePosition = startCFrame.Position + Vector3.new(0, 2, 0)
		humanoidRootPart.CFrame = CFrame.new(safePosition, safePosition + startCFrame.LookVector)
		humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

		pcall(function()
			humanoid.PlatformStand = false
			humanoid.Sit = false
			humanoid.AutoRotate = true
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end)
	end

	local upPosition = startCFrame.Position + Vector3.new(0, DROP_POP_SNAP_UP_STUDS_V67, 0)
	humanoidRootPart.CFrame = CFrame.new(upPosition, upPosition + startCFrame.LookVector)
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, DROP_POP_UP_FORCE_V67, 0)
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

	task.wait(DROP_POP_UP_TIME_V67)

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return false
	end

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, DROP_POP_DOWN_FORCE_V67, 0)
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

	task.wait(DROP_POP_RECOVER_TIME_V67)

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return false
	end

	recoverDropPosition()

	pcall(function()
		humanoid.Health = math.max(humanoid.Health, math.min(startHealth, humanoid.MaxHealth))
		humanoid.BreakJointsOnDeath = oldBreakJointsOnDeath
		humanoid.PlatformStand = oldPlatformStand
		humanoid.Sit = oldSit
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)

	task.delay(0.05, recoverDropPosition)
	task.delay(0.15, recoverDropPosition)
	task.delay(0.35, recoverDropPosition)

	return true
end

local function safeLocalDropHeld()
	local now = os.clock()

	__DIZZY_DROP_SUPPRESS_TOOL_UNTIL = now + 1.0
	toolGuardUntil = 0
	lastHeldTool = nil

	pcall(function()
		if humanoid then
			humanoid:UnequipTools()
		end
	end)

	task.spawn(function()
		local suppressUntil = os.clock() + 1.0

		while os.clock() < suppressUntil do
			toolGuardUntil = 0
			lastHeldTool = nil

			local currentTool = getHeldTool()

			if currentTool and isProtectedHeldName(currentTool.Name) and humanoid then
				pcall(function()
					humanoid:UnequipTools()
				end)
			end

			RunService.Heartbeat:Wait()
		end
	end)

	if not __DIZZY_DROP_STATUS_TIME or now - __DIZZY_DROP_STATUS_TIME > 1.25 then
		__DIZZY_DROP_STATUS_TIME = now
		setStatus("DROP FAST: triggered.")
	end

	task.spawn(function()
		pcall(function()
			local dropHeight = nil

			pcall(function()
				if getHeightAboveGround then
					dropHeight = getHeightAboveGround()
				end
			end)

			if not dropHeight or dropHeight <= 24 then
				safeAvatarPopForDropV67()
			end
		end)
	end)

	local cachedDropRemotes = __DIZZY_DROP_REMOTE_CACHE

	if cachedDropRemotes then
		task.defer(function()
			local fired = 0

			for _, remote in ipairs(cachedDropRemotes) do
				if fired >= 4 then
					break
				end

				if remote and remote.Parent then
					fired += 1

					pcall(function()
						remote:FireServer()
					end)

					pcall(function()
						remote:FireServer("Drop")
					end)

					if fired % 2 == 0 then
						RunService.Heartbeat:Wait()
					end
				end
			end
		end)
	end

	if __DIZZY_DROP_LIGHT_HELPER_LOCK_UNTIL and now < __DIZZY_DROP_LIGHT_HELPER_LOCK_UNTIL then
		return
	end

	__DIZZY_DROP_LIGHT_HELPER_LOCK_UNTIL = now + 1.4

	task.delay(0.025, function()
		local heldObjects = {}

		pcall(function()
			heldObjects = findLocalHeldObjectsForDrop() or {}
		end)

		for _, object in ipairs(heldObjects) do
			if object and object.Parent and not isProtectedHeldName(object.Name) then
				pcall(function()
					detachOneLocalDropObject(object)
				end)

				pcall(function()
					flingOneHeldObjectUp(object)
				end)

				pcall(function()
					scheduleFastSnapDown(object)
				end)
			end
		end

		RunService.Heartbeat:Wait()

		pcall(function()
			tryBackpackDropToolOnly()
		end)

		if character then
			for _, child in ipairs(character:GetChildren()) do
				if child and child.Parent and not isProtectedHeldName(child.Name) and looksLikeDroppableHeldObject(child) then
					pcall(function()
						detachOneLocalDropObject(child)
					end)

					pcall(function()
						flingOneHeldObjectUp(child)
					end)

					pcall(function()
						scheduleFastSnapDown(child)
					end)
				end
			end
		end
	end)
end

local function startToolGuard()
	if __DIZZY_DROP_SUPPRESS_TOOL_UNTIL and os.clock() < __DIZZY_DROP_SUPPRESS_TOOL_UNTIL then
		toolGuardUntil = 0
		return
	end

	local tool = rememberHeldTool()

	if not tool then
		toolGuardUntil = 0
		return
	end

	toolGuardUntil = os.clock() + TOOL_GUARD_TIME

	task.defer(reEquipLastHeldTool)

	task.delay(0.08, reEquipLastHeldTool)
	task.delay(0.22, reEquipLastHeldTool)
	task.delay(0.45, reEquipLastHeldTool)
end

local function updateToolGuard()
	if os.clock() > toolGuardUntil then
		return
	end

	reEquipLastHeldTool()
end

local function getJumpPreserveFlatVelocity(currentVelocity, multiplier)
	multiplier = multiplier or 1

	local speed = getAntiKnockbackSpeed()
	local inputDirection = getKeyboardMoveDirection()
	local moveDirection = humanoid and humanoid.MoveDirection or Vector3.zero

	if inputDirection.Magnitude > 0.05 then
		lastMoveDirection = inputDirection.Unit
		return Vector3.new(
			inputDirection.Unit.X * speed * multiplier,
			0,
			inputDirection.Unit.Z * speed * multiplier
		)
	end

	if moveDirection.Magnitude > 0.05 then
		local flatDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)

		if flatDirection.Magnitude > 0.05 then
			flatDirection = flatDirection.Unit
			lastMoveDirection = flatDirection

			return Vector3.new(
				flatDirection.X * speed * multiplier,
				0,
				flatDirection.Z * speed * multiplier
			)
		end
	end

	return Vector3.new(currentVelocity.X * multiplier, 0, currentVelocity.Z * multiplier)
end

local function stabilizeCameraAndRoot()
	if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return
	end

	local camera = workspace.CurrentCamera

	if camera then
		pcall(function()
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
		end)
	end

	pcall(function()
		humanoid.CameraOffset = Vector3.zero
		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid.AutoRotate = true
	end)

	local position = humanoidRootPart.Position
	local _, yaw, _ = humanoidRootPart.CFrame:ToOrientation()

	pcall(function()
		humanoidRootPart.CFrame = CFrame.new(position) * CFrame.Angles(0, yaw, 0)
	end)

	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
end

local function holdJumpDownForce()
	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	local untilTime = jumpDownForceUntil

	task.spawn(function()
		while os.clock() < untilTime do
			if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
				break
			end

			local velocity = humanoidRootPart.AssemblyLinearVelocity
			local flatVelocity = getJumpPreserveFlatVelocity(velocity, 0.95)

			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
				flatVelocity.X,
				math.min(velocity.Y, DOWNWARD_FORCE),
				flatVelocity.Z
			)

			humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			task.wait(0.025)
		end
	end)
end

local function performAirJump()
	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	local now = os.clock()
	antiRagdollJumpGraceUntil = math.max(antiRagdollJumpGraceUntil, now + 0.8)
	local jumpCache = __DIZZY_JUMP_CACHE
	local holdingCarryObject = false

	if jumpCache and now < (jumpCache.UntilTime or 0) then
		holdingCarryObject = jumpCache.Result == true
	else
		if character then
			for _, child in ipairs(character:GetChildren()) do
				if child and child.Parent and not isProtectedHeldName(child.Name) then
					if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Tool")) and looksLikeDroppableHeldObject(child) then
						holdingCarryObject = true
						break
					end
				end
			end
		end

		if not holdingCarryObject and jumpCache and findLocalHeldObjectsForDrop and now - (jumpCache.LastDeepScanTime or 0) > 4.5 then
			jumpCache.LastDeepScanTime = now

			local heldObjects = nil
			pcall(function()
				heldObjects = findLocalHeldObjectsForDrop()
			end)

			if heldObjects then
				for _, object in ipairs(heldObjects) do
					if object and object.Parent and not isProtectedHeldName(object.Name) then
						if object:IsA("Model") or object:IsA("BasePart") or object:IsA("Tool") then
							holdingCarryObject = true
							break
						end
					end
				end
			end
		end

		if jumpCache then
			jumpCache.Result = holdingCarryObject
			jumpCache.UntilTime = now + (holdingCarryObject and 3.5 or 0.45)
		end
	end

	if not holdingCarryObject then
		startToolGuard()
	else
		if humanoid.Sit then
			humanoid.Sit = false
		end

		if humanoid.PlatformStand then
			humanoid.PlatformStand = false
		end

		if humanoid.AutoRotate == false then
			humanoid.AutoRotate = true
		end
	end

	local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
	local jumpPower = AIR_JUMP_POWER
	local horizontalMultiplier = 1

	if holdingCarryObject then
		jumpPower = 62
		horizontalMultiplier = 0.96
	end

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
		currentVelocity.X * horizontalMultiplier,
		math.max(currentVelocity.Y, jumpPower),
		currentVelocity.Z * horizontalMultiplier
	)

	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	lastAirJumpTime = now

	if not holdingCarryObject then
		task.defer(reEquipLastHeldTool)
	end
end
local function isHoldingCarryObjectForJumpDown()
	if not character then
		return false
	end

	for _, child in ipairs(character:GetChildren()) do
		if (child:IsA("Model") or child:IsA("BasePart")) and looksLikeDroppableHeldObject(child) then
			return true
		end
	end

	local heldObjects = {}

	pcall(function()
		heldObjects = findLocalHeldObjectsForDrop()
	end)

	for _, object in ipairs(heldObjects) do
		if object and object.Parent and not isProtectedHeldName(object.Name) then
			if object:IsA("Model") or object:IsA("BasePart") then
				return true
			end
		end
	end

	return false
end

local function startCarrySafeDownProtection()

	local untilTime = os.clock() + CARRY_SAFE_DOWNWARD_TIME

	task.spawn(function()
		while os.clock() < untilTime do
			if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				break
			end

			pcall(function()
				humanoid.Sit = false
				humanoid.PlatformStand = false
				humanoid.AutoRotate = true
			end)

			local velocity = humanoidRootPart.AssemblyLinearVelocity

			if velocity.Y < CARRY_SAFE_DOWNWARD_FORCE then
				humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
					velocity.X,
					CARRY_SAFE_DOWNWARD_FORCE,
					velocity.Z
				)
			end

			task.wait(0.03)
		end
	end)
end

local function sendPlayerDown()
	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	local holdingCarryObject = isHoldingCarryObjectForJumpDown and isHoldingCarryObjectForJumpDown() or false
	local heldTool = nil

	if not holdingCarryObject then
		heldTool = rememberHeldTool()
		startToolGuard()
	else
		pcall(function()
			humanoid.Sit = false
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end)
	end

	local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
	local downwardForce = DOWNWARD_FORCE
	local horizontalMultiplier = 0.6

	if heldTool then
		downwardForce = SOFT_DOWNWARD_FORCE_WHILE_HOLDING
	end

	if holdingCarryObject then

		downwardForce = CARRY_JUMP_DOWN_FORCE_V49 or -55
		horizontalMultiplier = 0.75
	end

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
		currentVelocity.X * horizontalMultiplier,
		downwardForce,
		currentVelocity.Z * horizontalMultiplier
	)

	totalJumpsInSequence = 0
	jumpDownPressCountV50 = 0
	airborneSince = nil
	lastDownTime = os.clock()
	lastAirJumpTime = os.clock()

	if holdingCarryObject then
		setStatus("V50 carry Jump Down sent down.")
	else
		setStatus("V50 Jump Down sent down.")
	end

	if not holdingCarryObject then
		task.defer(reEquipLastHeldTool)
	end
end

local function handleJumpAbility()

	if not getHeldTool() then
		lastHeldTool = nil
	end

	if not jumpEnabled then
		return
	end

	if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return
	end

	local now = os.clock()

	if os.clock() < tpDownLockUntil then
		return
	end

	if now - lastJumpDownPressTimeV50 < JUMP_DOWN_PRESS_DEBOUNCE_V50 then
		return
	end

	lastJumpDownPressTimeV50 = now

	local targetJump = math.clamp(selectedDownJump or 5, MIN_DOWN_JUMP or 2, MAX_DOWN_JUMP or 6)

	jumpDownPressCountV50 += 1
	totalJumpsInSequence = jumpDownPressCountV50

	if jumpDownPressCountV50 >= targetJump then
		if now - lastDownTime >= DOWN_COOLDOWN then
			sendPlayerDown()
		else
			jumpDownPressCountV50 = math.max(targetJump - 1, 0)
			totalJumpsInSequence = jumpDownPressCountV50
		end

		return
	end

	performAirJump()

	local jumpCache = __DIZZY_JUMP_CACHE
	if not jumpCache or now - (jumpCache.LastStatusTime or 0) > 2.5 then
		if jumpCache then
			jumpCache.LastStatusTime = now
		end

		setStatus("V50 Jump " .. tostring(jumpDownPressCountV50) .. "/" .. tostring(targetJump) .. ".")
	end
end

local function getCameraFlatDirections()
	local camera = workspace.CurrentCamera

	if not camera then
		return Vector3.zero, Vector3.zero
	end

	local forward = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	forward = Vector3.new(forward.X, 0, forward.Z)
	right = Vector3.new(right.X, 0, right.Z)

	if forward.Magnitude > 0 then
		forward = forward.Unit
	end

	if right.Magnitude > 0 then
		right = right.Unit
	end

	return forward, right
end

local function updateMobileMoveDirection()
	if not touchStartPosition or not touchCurrentPosition then
		mobileMoveDirection = Vector3.zero
		return
	end

	local delta = touchCurrentPosition - touchStartPosition

	if delta.Magnitude < MOBILE_TOUCH_DEADZONE then
		mobileMoveDirection = Vector3.zero
		return
	end

	local clampedDelta = delta

	if clampedDelta.Magnitude > MOBILE_TOUCH_MAX_DISTANCE then
		clampedDelta = clampedDelta.Unit * MOBILE_TOUCH_MAX_DISTANCE
	end

	local forward, right = getCameraFlatDirections()

	local x = clampedDelta.X / MOBILE_TOUCH_MAX_DISTANCE
	local y = clampedDelta.Y / MOBILE_TOUCH_MAX_DISTANCE

	local worldDirection = (right * x) + (forward * -y)

	if worldDirection.Magnitude > 0.05 then
		mobileMoveDirection = worldDirection.Unit
	else
		mobileMoveDirection = Vector3.zero
	end
end

local function getKeyboardMoveDirection()
	local mobileDirection = mobileMoveDirection

	if mobileDirection.Magnitude > 0.05 then
		return mobileDirection.Unit
	end

	local move = Vector3.zero
	local forward, right = getCameraFlatDirections()

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		move += forward
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		move -= forward
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		move += right
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		move -= right
	end

	if move.Magnitude > 0.05 then
		return move.Unit
	end

	return Vector3.zero
end

local function setupMobileTouchMovement()
	UserInputService.TouchStarted:Connect(function(input)
		if activeMoveTouch then
			return
		end

		local camera = workspace.CurrentCamera
		local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local position = Vector2.new(input.Position.X, input.Position.Y)

		if position.X > viewportSize.X * 0.58 then
			return
		end

		activeMoveTouch = input
		touchStartPosition = position
		touchCurrentPosition = position
		updateMobileMoveDirection()
	end)

	UserInputService.TouchMoved:Connect(function(input)
		if input ~= activeMoveTouch then
			return
		end

		touchCurrentPosition = Vector2.new(input.Position.X, input.Position.Y)
		updateMobileMoveDirection()
	end)

	UserInputService.TouchEnded:Connect(function(input)
		if input ~= activeMoveTouch then
			return
		end

		activeMoveTouch = nil
		touchStartPosition = nil
		touchCurrentPosition = nil
		mobileMoveDirection = Vector3.zero
	end)
end

local function rememberMoveDirection()
	if not humanoid then
		return
	end

	local inputDirection = getKeyboardMoveDirection()
	local humanoidDirection = humanoid.MoveDirection
	local direction = Vector3.zero

	if inputDirection.Magnitude > 0.05 then
		direction = inputDirection
	elseif humanoidDirection.Magnitude > 0.05 then
		direction = Vector3.new(humanoidDirection.X, 0, humanoidDirection.Z)
	end

	if direction.Magnitude > 0.05 then
		lastMoveDirection = direction.Unit
	end
end

local function keepGuiButtonsAlive()
	pcall(function()
		if screenGui then
			screenGui.Enabled = true
		end
if mainFrame then
			mainFrame.Visible = true
		end

		if floatingButtonGroup then
			floatingButtonGroup.Visible = true
			floatingButtonGroup.ZIndex = 50
		end

		for _, button in pairs(floatingButtons) do
			if button and button.Parent then
				button.Visible = true
				button.Active = true
				button.Selectable = true
				button.AutoButtonColor = true
				button.ZIndex = 50
			end
		end
	end)
end

local function disconnectAntiRagdollConnections()
	for _, connection in ipairs(antiRagdollConnections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(antiRagdollConnections)

	if antiRagdollHeartbeatConnection then
		antiRagdollHeartbeatConnection:Disconnect()
		antiRagdollHeartbeatConnection = nil
	end
end

local function setHumanoidStateEnabledSafe(state, enabled)
	if not humanoid then
		return
	end

	pcall(function()
		humanoid:SetStateEnabled(state, enabled)
	end)
end

local function isRagdollObject(object)
	local name = string.lower(object.Name)

	if string.find(name, "ragdoll")
		or string.find(name, "ballsocket")
		or string.find(name, "stun")
		or string.find(name, "knock") then
		return true
	end

	return object:IsA("BallSocketConstraint")
		or object:IsA("HingeConstraint")
		or object:IsA("RodConstraint")
		or object:IsA("SpringConstraint")
end

local function startAntiKnockbackWindow()
	local now = os.clock()

	antiKnockbackUntil = math.max(antiKnockbackUntil, now + 0.42)
	keepMovingUntil = math.max(keepMovingUntil, now + 0.28)
	manualMoveUntil = math.max(manualMoveUntil, now + 0.28)
end

local function getAntiKnockbackSpeed()
	if autoMoving then
		return getAutoSpeed()
	end

	if batAimbotEnabled then
		return DEFAULT_WALK_SPEED
	end

	return clampSpeed(getTargetSpeed())
end

local function getWantedFlatVelocity()
	if not humanoid then
		return Vector3.zero
	end

	local speed = getAntiKnockbackSpeed()
	local inputDirection = getKeyboardMoveDirection()
	local moveDirection = humanoid.MoveDirection

	if inputDirection.Magnitude > 0.05 then
		lastMoveDirection = inputDirection.Unit
		return Vector3.new(inputDirection.Unit.X * speed, 0, inputDirection.Unit.Z * speed)
	end

	if moveDirection.Magnitude > 0.05 then
		local flatDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
		lastMoveDirection = flatDirection
		return Vector3.new(flatDirection.X * speed, 0, flatDirection.Z * speed)
	end

	return Vector3.zero
end

local function cancelKnockback()
	if not humanoidRootPart or not humanoid then
		return
	end

	keepGuiButtonsAlive()

	local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
	local inputDirection = getKeyboardMoveDirection()
	local moveDirection = humanoid.MoveDirection
	local direction = Vector3.zero

	if inputDirection.Magnitude > 0.05 then
		direction = inputDirection.Unit
	elseif moveDirection.Magnitude > 0.05 then
		local flatMove = Vector3.new(moveDirection.X, 0, moveDirection.Z)

		if flatMove.Magnitude > 0.05 then
			direction = flatMove.Unit
		end
	end

	local speed = getAntiKnockbackSpeed()
	local finalFlat = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)

	if direction.Magnitude > 0.05 then
		lastMoveDirection = direction
		finalFlat = Vector3.new(direction.X * speed, 0, direction.Z * speed)
	else
		local maxFlat = 6

		if finalFlat.Magnitude > maxFlat then
			finalFlat = finalFlat.Unit * maxFlat
		end
	end

	local yVelocity = currentVelocity.Y

	if os.clock() <= antiKnockbackUntil or isRealRagdollState() or humanoid.PlatformStand then
		yVelocity = math.clamp(yVelocity, -90, 12)
	end

	if humanoid.FloorMaterial ~= Enum.Material.Air and yVelocity < 0 then
		yVelocity = 0
	end

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(finalFlat.X, yVelocity, finalFlat.Z)
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

	humanoid.PlatformStand = false
	humanoid.Sit = false
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = speed

	if direction.Magnitude > 0.05 then
		pcall(function()
			humanoid:Move(direction, false)
		end)
	end
end

local function markJumpDownSequenceGrace()
	jumpDownSequenceGraceUntil = os.clock() + 1.35
	antiRagdollJumpGraceUntil = math.max(antiRagdollJumpGraceUntil, jumpDownSequenceGraceUntil)
end

local function isJumpDownSequenceGraceActive()
	return os.clock() < jumpDownSequenceGraceUntil
end

local function markAntiRagdollJumpGrace()
	antiRagdollJumpGraceUntil = math.max(antiRagdollJumpGraceUntil, os.clock() + ANTI_RAGDOLL_JUMP_GRACE_TIME)
end

local function isAntiRagdollJumpGraceActive()
	return os.clock() < antiRagdollJumpGraceUntil
end

local function isRealRagdollState()
	if not humanoid then
		return false
	end

	local state = humanoid:GetState()

	return state == Enum.HumanoidStateType.Ragdoll
		or state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.PlatformStanding
		or state == Enum.HumanoidStateType.Physics
end

local function forceManualMovementDropy()

	return
end

local function shouldCancelKnockback()
	if not humanoidRootPart or not humanoid then
		return false
	end

	if os.clock() - lastDownTime < 0.35 then
		return false
	end

	if isAntiRagdollJumpGraceActive() or isJumpDownSequenceGraceActive() or batAimbotEnabled then
		return false
	end

	local now = os.clock()
	local velocity = humanoidRootPart.AssemblyLinearVelocity
	local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
	local speed = getAntiKnockbackSpeed()

	if now <= antiKnockbackUntil then
		return true
	end

	if now - lastKnockbackDetectTime < KNOCKBACK_DETECT_COOLDOWN then
		return false
	end

	if isRealRagdollState() or humanoid.PlatformStand or humanoid.Sit then
		lastKnockbackDetectTime = now
		startAntiKnockbackWindow()
		return true
	end

	local wantedFlat = getWantedFlatVelocity()
	local excessVelocity = (flatVelocity - wantedFlat).Magnitude
	local highFlatLimit = math.max(speed + 9, 28)
	local excessLimit = math.max(16, speed * 0.38)

	if flatVelocity.Magnitude > highFlatLimit and excessVelocity > excessLimit then
		lastKnockbackDetectTime = now
		startAntiKnockbackWindow()
		return true
	end

	if velocity.Y > 42 and flatVelocity.Magnitude > speed + 6 then
		lastKnockbackDetectTime = now
		startAntiKnockbackWindow()
		return true
	end

	if velocity.Y < -115 and isRealRagdollState() then
		lastKnockbackDetectTime = now
		startAntiKnockbackWindow()
		return true
	end

	return false
end

local function repairCharacterJointsLight()
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("Motor6D") then
			object.Enabled = true
		elseif isRagdollObject(object) then
			
		elseif object:IsA("BasePart") then
			object.Anchored = false
		end
	end
end

local function forceFastGetUp()
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	humanoid.PlatformStand = false
	humanoid.Sit = false
	humanoid.AutoRotate = true

	local currentState = humanoid:GetState()

	if (isAntiRagdollJumpGraceActive() or isJumpDownSequenceGraceActive())
		and (currentState == Enum.HumanoidStateType.Jumping
			or currentState == Enum.HumanoidStateType.Freefall
			or humanoid.FloorMaterial == Enum.Material.Air
			or jumpEnabled)
		and not isRealRagdollState() then
		return
	end

	if currentState == Enum.HumanoidStateType.Ragdoll
		or currentState == Enum.HumanoidStateType.FallingDown
		or currentState == Enum.HumanoidStateType.PlatformStanding
		or currentState == Enum.HumanoidStateType.Physics then

		startAntiKnockbackWindow()

		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)

		task.defer(function()
			if humanoid and humanoid.Health > 0 then
				pcall(function()
					if humanoid.FloorMaterial == Enum.Material.Air then
						humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
					else
						humanoid:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)
			end
		end)
	end

	if autoMoving then
		humanoid.WalkSpeed = getAutoSpeed()
	else
		humanoid.WalkSpeed = clampSpeed(getTargetSpeed())
	end

	if humanoidRootPart then
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	end
end

local function forceAntiRagdollMovementAssist()
	if not antiRagdollEnabled then
		return
	end

	if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return
	end

	if autoMoving or batAimbotEnabled then
		return
	end

	if os.clock() > antiKnockbackUntil and not isRealRagdollState() and not humanoid.PlatformStand then
		return
	end

	local inputDirection = getKeyboardMoveDirection()
	local humanoidDirection = humanoid.MoveDirection
	local direction = Vector3.zero

	if inputDirection.Magnitude > 0.05 then
		direction = inputDirection.Unit
	elseif humanoidDirection.Magnitude > 0.05 then
		local flat = Vector3.new(humanoidDirection.X, 0, humanoidDirection.Z)

		if flat.Magnitude > 0.05 then
			direction = flat.Unit
		end
	end

	pcall(function()
		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid.AutoRotate = true
	end)

	if direction.Magnitude <= 0.05 then
		local velocity = humanoidRootPart.AssemblyLinearVelocity
		local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)

		if os.clock() <= antiKnockbackUntil and flatVelocity.Magnitude > 6 then
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
				flatVelocity.Unit.X * 6,
				math.clamp(velocity.Y, -90, 12),
				flatVelocity.Unit.Z * 6
			)
			humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		end

		return
	end

	lastMoveDirection = direction

	local speed = getAntiKnockbackSpeed()
	humanoid.WalkSpeed = speed

	pcall(function()
		humanoid:Move(direction, false)
	end)

	local velocity = humanoidRootPart.AssemblyLinearVelocity
	local yVelocity = velocity.Y

	if os.clock() <= antiKnockbackUntil or isRealRagdollState() or humanoid.PlatformStand then
		yVelocity = math.clamp(yVelocity, -90, 12)
	end

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
		direction.X * speed,
		yVelocity,
		direction.Z * speed
	)

	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

	if os.clock() < cameraStabilizeUntil then
		stabilizeCameraAndRoot()
	end
end

local function applyAntiRagdollState()
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	if antiRagdollEnabled then
		if os.clock() - (antiRagdollLastLightRepair or 0) > 0.75 then
			antiRagdollLastLightRepair = os.clock()
			repairCharacterJointsLight()
		end

		if (isAntiRagdollJumpGraceActive() or isJumpDownSequenceGraceActive())
			and (humanoid.FloorMaterial == Enum.Material.Air or isAirborneState(humanoid:GetState()) or jumpEnabled)
			and not isRealRagdollState()
			and not humanoid.PlatformStand then

			humanoid.PlatformStand = false
			humanoid.Sit = false
			humanoid.AutoRotate = true
			return
		end

		if shouldCancelKnockback() then
			cancelKnockback()
		end

		forceFastGetUp()
		forceAntiRagdollMovementAssist()
	else
		setHumanoidStateEnabledSafe(Enum.HumanoidStateType.Ragdoll, true)
		setHumanoidStateEnabledSafe(Enum.HumanoidStateType.FallingDown, true)
		setHumanoidStateEnabledSafe(Enum.HumanoidStateType.PlatformStanding, true)

		humanoid.PlatformStand = false
		humanoid.Sit = false
	end
end

local function startAntiRagdollWatcher()
	disconnectAntiRagdollConnections()

	if not character or not humanoid then
		return
	end

	setHumanoidStateEnabledSafe(Enum.HumanoidStateType.Ragdoll, true)
	setHumanoidStateEnabledSafe(Enum.HumanoidStateType.FallingDown, true)
	setHumanoidStateEnabledSafe(Enum.HumanoidStateType.PlatformStanding, true)

	table.insert(antiRagdollConnections, humanoid.StateChanged:Connect(function(_, newState)
		if not antiRagdollEnabled then
			return
		end

		if newState == Enum.HumanoidStateType.Ragdoll
			or newState == Enum.HumanoidStateType.FallingDown
			or newState == Enum.HumanoidStateType.PlatformStanding
			or newState == Enum.HumanoidStateType.Physics then

			startAntiKnockbackWindow()
			task.defer(applyAntiRagdollState)
		end
	end))

	table.insert(antiRagdollConnections, character.DescendantAdded:Connect(function(object)
		if not antiRagdollEnabled then
			return
		end

		task.defer(function()
			if object:IsA("Motor6D") then
				object.Enabled = true
			elseif isRagdollObject(object) then
				startAntiKnockbackWindow()
			elseif object:IsA("BasePart") then
				object.Anchored = false
			end

			applyAntiRagdollState()
		end)
	end))

	antiRagdollHeartbeatConnection = RunService.Heartbeat:Connect(function()
		if antiRagdollEnabled then
			applyAntiRagdollState()
		end
	end)

	applyAntiRagdollState()
end

local function updateAntiRagdoll()
	if not antiRagdollEnabled then
		return
	end

	applyAntiRagdollState()
end

local function makePanelDraggable(handle, frame)
	local dragging = false
	local dragStart
	local startPos

	handle.Active = true

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			if buttonsLocked then
				return
			end

			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			if buttonsLocked then
				return
			end

			local delta = input.Position - dragStart

			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function makeButton(parent, text, height, callback)
	local button = Instance.new("TextButton")
	local buttonHeight = math.min(height or 32, 34)

	button.Size = UDim2.new(1, 0, 0, buttonHeight)
	button.BackgroundColor3 = BUTTON_BLACK
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.TextWrapped = true
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = parent

	addCorner(button, 7)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback(button)
		end
	end)

	return button
end

local function makeActionButton(parent, text, height, callback)
	local button = Instance.new("TextButton")
	local buttonHeight = math.min(height or 32, 34)

	button.Size = UDim2.new(1, 0, 0, buttonHeight)
	button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.TextWrapped = true
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = parent

	addCorner(button, 7)

	button.MouseButton1Click:Connect(function()
		button.Text = text .. "..."
		if callback then
			callback(button)
		end

		task.delay(0.25, function()
			if button and button.Parent then
				button.Text = text
			end
		end)
	end)

	return button
end

local function makeInfo(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 12
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makeToggle(parent, text, getState, callback)
	local button

	local function refresh()
		local enabled = getState()
		button.Text = text .. ": " .. (enabled and "ON" or "OFF")
		button.BackgroundColor3 = enabled and SELECTED_COLOR or BUTTON_BLACK
	end

	button = makeButton(parent, "", 32, function()
		if callback then
			callback()
		end

		refresh()
	end)

	refresh()
	return button
end

local function makeSpeedAdjuster(parent, labelText, startValue, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 38)
	holder.BackgroundTransparency = 1
	holder.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.48, -4, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(235, 235, 245)
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.52, 0, 1, 0)
	box.Position = UDim2.new(0.48, 0, 0, 0)
	box.BackgroundColor3 = BOX_COLOR
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.TextSize = 14
	box.Font = Enum.Font.GothamBold
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Text = formatSpeed(startValue)
	box.PlaceholderText = "type speed"
	box.Parent = holder
	addCorner(box, 7)

	local currentValue = clampSpeed(startValue)

	local function updateValue(newValue)
		currentValue = clampSpeed(newValue)
		box.Text = formatSpeed(currentValue)
		label.Text = labelText

		if callback then
			callback(currentValue)
		end
	end

	box.FocusLost:Connect(function()
		updateValue(box.Text)
	end)

	updateValue(currentValue)
end

local function clearContent(contentArea, listLayout)
	for _, child in ipairs(contentArea:GetChildren()) do
		if child ~= listLayout then
			child:Destroy()
		end
	end
end

local function updateSelected(sectionName)
	for name, button in pairs(sectionButtons) do
		if name == sectionName then
			button.BackgroundColor3 = SELECTED_COLOR
		else
			button.BackgroundColor3 = BUTTON_BLACK
		end
	end
end

local function createOrUpdateOverheadText()
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head then
		return
	end

	local old = head:FindFirstChild("DizzyOverheadText")

	if old then
		old:Destroy()
	end

	overheadBillboard = Instance.new("BillboardGui")
	overheadBillboard.Name = "DizzyOverheadText"
	overheadBillboard.Size = UDim2.new(0, 180, 0, 38)
	overheadBillboard.StudsOffset = Vector3.new(0, 2.7, 0)
	overheadBillboard.AlwaysOnTop = true
	overheadBillboard.MaxDistance = 250
	overheadBillboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = OVERHEAD_TEXT_VALUE
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.25
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = overheadBillboard
end

local function setupCharacter(char)
	character = char
	humanoid = character:WaitForChild("Humanoid", 10)
	humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

	resetJumpSequence()
	startAntiRagdollWatcher()

	if humanoid then
		humanoid.AutoRotate = true

		humanoid.StateChanged:Connect(function(_, newState)
			if isAirborneState(newState) then
				if not airborneSince then
					airborneSince = os.clock()
				end

				if totalJumpsInSequence <= 0 then
					totalJumpsInSequence = 1
				end
			elseif isGroundedState(newState) then
				resetJumpSequence()
			end
		end)
	end

	if character then
		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				if __DIZZY_DROP_SUPPRESS_TOOL_UNTIL and os.clock() < __DIZZY_DROP_SUPPRESS_TOOL_UNTIL and isProtectedHeldName(child.Name) then
					lastHeldTool = nil

					pcall(function()
						if humanoid then
							humanoid:UnequipTools()
						end
					end)

					return
				end

				lastHeldTool = child

				pcall(function()
					child.CanBeDropped = false
				end)

				if isProtectedToolName(child.Name) then
					protectTool(child)
				end
			end
		end)
	end

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		backpack.ChildAdded:Connect(function(child)
			if child:IsA("Tool") and isProtectedToolName(child.Name) then
				protectTool(child)
			end
		end)
	end

	task.wait(0.25)
	applySpeed()
	createOrUpdateOverheadText()
	setStatus("Character loaded.")
end

local function forceAddVisibleDropOnlyButton()

	if floatingButtons.DropTools then
		floatingButtons.DropTools.Text = "DROP"
		floatingButtons.DropTools.Visible = true
		floatingButtons.DropTools.Active = true
		floatingButtons.DropTools.Selectable = true
		floatingButtons.DropTools.AutoButtonColor = true
	end
end

local function createGui()
	for _, oldGui in ipairs(playerGui:GetChildren()) do
		if oldGui:IsA("ScreenGui") then
			local oldName = string.lower(oldGui.Name or "")

			if string.find(oldName, "dizzy", 1, true) then
				oldGui:Destroy()
			end
		end
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DizzyHubGUI_V89_MEDUSA_COUNTER_ONCE"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 9999
	screenGui.Parent = playerGui
	screenGui:SetAttribute("MedusaCounterEnabled", false)
	screenGui:SetAttribute("MedusaCounterLastTime", 0)
	screenGui:SetAttribute("BatCounterEnabled", false)
	screenGui:SetAttribute("BatCounterLastVelocity", 0)
	screenGui:SetAttribute("BatCounterLastJumpTime", 0)
	screenGui:SetAttribute("BatCounterBusyUntil", 0)

	screenGui:SetAttribute("BatCounterLastHealth", -1)
	screenGui:SetAttribute("BatCounterLastTime", 0)

	task.spawn(function()
		for _ = 1, 30 do
			for _, oldGui in ipairs(playerGui:GetChildren()) do
				if oldGui ~= screenGui and oldGui:IsA("ScreenGui") then
					local oldName = string.lower(oldGui.Name or "")

					if string.find(oldName, "dizzy", 1, true)
						or oldGui:FindFirstChild("DizzyHubPanel", true)
						or oldGui:FindFirstChild("DizzyHubStatus", true) then
						oldGui:Destroy()
					end
				end
			end

			task.wait(0.1)
		end
	end)
local fullSize = UDim2.new(0, 620, 0, 368)
	local minimizedSize = UDim2.new(0, 155, 0, 48)

	local shortTabSize = UDim2.new(0, 145, 0, 36)
	local shortTitleSize = UDim2.new(0, 98, 1, 0)
	local fullBodySize = UDim2.new(1, 0, 1, 0)

	mainFrame = Instance.new("Frame")
	mainFrame.Name = "DizzyHubPanel"
	mainFrame.Size = fullSize
	mainFrame.Position = UDim2.new(0.5, -310, 0, 142)
	mainFrame.BackgroundColor3 = PANEL_COLOR
	mainFrame.BackgroundTransparency = 1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 14)

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = shortTabSize
	titleBar.Position = UDim2.new(0.5, -300, 0, 90)
	titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	titleBar.BorderSizePixel = 0
	titleBar.Active = true
	titleBar.Selectable = true
	titleBar.Parent = screenGui
	titleBar.ZIndex = 60
	addCorner(titleBar, 8)

	local title = Instance.new("TextLabel")
	title.Size = shortTitleSize
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Dizzy Hub V89"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 17
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar
	title.ZIndex = 61

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Size = UDim2.new(0, 32, 0, 28)
	minimizeButton.Position = UDim2.new(1, -38, 0, 4)
	minimizeButton.BackgroundColor3 = BUTTON_BLACK
	minimizeButton.Text = "-"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 20
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Parent = titleBar
	minimizeButton.ZIndex = 61
	addCorner(minimizeButton, 8)

	makePanelDraggable(titleBar, titleBar)

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Size = fullBodySize
	body.Position = UDim2.new(0, 0, 0, 0)
	body.BackgroundTransparency = 1
	body.Parent = mainFrame

	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftSections"
	leftPanel.Size = UDim2.new(0, 145, 1, 0)
	leftPanel.BackgroundColor3 = LEFT_COLOR
	leftPanel.BorderSizePixel = 0
	leftPanel.Parent = body
	addCorner(leftPanel, 10)
	makePanelDraggable(leftPanel, mainFrame)

	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightContent"
	rightPanel.Size = UDim2.new(1, -155, 1, 0)
	rightPanel.Position = UDim2.new(0, 155, 0, 0)
	rightPanel.BackgroundColor3 = RIGHT_COLOR
	rightPanel.BorderSizePixel = 0
	rightPanel.Parent = body
	addCorner(rightPanel, 10)

	local rightTitle = Instance.new("TextLabel")
	rightTitle.Size = UDim2.new(1, -20, 0, 38)
	rightTitle.Position = UDim2.new(0, 10, 0, 8)
	rightTitle.BackgroundTransparency = 1
	rightTitle.Text = "Speed"
	rightTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	rightTitle.TextSize = 20
	rightTitle.Font = Enum.Font.GothamBold
	rightTitle.TextXAlignment = Enum.TextXAlignment.Left
	rightTitle.Parent = rightPanel
	makePanelDraggable(rightTitle, mainFrame)

	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -20, 1, -58)
	contentArea.Position = UDim2.new(0, 10, 0, 50)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ScrollBarThickness = 4
	contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentArea.Parent = rightPanel

	local contentList = Instance.new("UIListLayout")
	contentList.Padding = UDim.new(0, 6)
	contentList.SortOrder = Enum.SortOrder.LayoutOrder
	contentList.Parent = contentArea

	floatingButtons = {}

	local function openSection(sectionName)
		clearContent(contentArea, contentList)
		updateSelected(sectionName)

		rightTitle.Text = sectionName
		if sectionName == "Speed" then
			makeInfo(contentArea, "Choose a speed mode and adjust values.")
makeSpeedAdjuster(contentArea, "Safe Speed", safeSpeedValue, function(value)
				safeSpeedValue = value
				applySpeed()
				setStatus("Safe Speed set to " .. formatSpeed(value))
			end)

			makeSpeedAdjuster(contentArea, "Carry Speed", carrySpeedValue, function(value)
				carrySpeedValue = value
				applySpeed()
				setStatus("Carry Speed set to " .. formatSpeed(value))
			end)

			makeSpeedAdjuster(contentArea, "Lagger Speed", laggerSpeedValue, function(value)
				laggerSpeedValue = value
				applySpeed()
				setStatus("Lagger Speed set to " .. formatSpeed(value))
			end)

			makeSpeedAdjuster(contentArea, "Lagger Carry Speed", laggerCarrySpeedValue, function(value)
				laggerCarrySpeedValue = value
				applySpeed()
				setStatus("Lagger Carry Speed set to " .. formatSpeed(value))
			end)
elseif sectionName == "Movement" then
			makeInfo(contentArea, "Movement settings.")

			makeToggle(contentArea, "Auto TP Down", function()
				return autoTpDownEnabled
			end, function()
				autoTpDownEnabled = not autoTpDownEnabled

				if autoTpDownEnabled then
					lastAutoTpDownTime = 0
					lastAutoTpDownHeight = 0
					setStatus("Auto TP Down enabled at adjusted height " .. tostring(autoTpDownHeight) .. ".")
				else
					setStatus("Auto TP Down disabled.")
				end

				updateFloatingButtons()
			end)
			local autoTpHeightFrame = Instance.new("Frame")
			autoTpHeightFrame.Size = UDim2.new(1, 0, 0, 38)
			autoTpHeightFrame.BackgroundTransparency = 1
			autoTpHeightFrame.Parent = contentArea

			local autoTpTextLabel = Instance.new("TextLabel")
			autoTpTextLabel.Size = UDim2.new(0.56, -4, 1, 0)
			autoTpTextLabel.Position = UDim2.new(0, 0, 0, 0)
			autoTpTextLabel.BackgroundTransparency = 1
			autoTpTextLabel.Text = "Auto TP Height"
			autoTpTextLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
			autoTpTextLabel.TextSize = 12
			autoTpTextLabel.Font = Enum.Font.GothamBold
			autoTpTextLabel.TextXAlignment = Enum.TextXAlignment.Left
			autoTpTextLabel.Parent = autoTpHeightFrame

			autoTpDownHeightLabel = Instance.new("TextBox")
			autoTpDownHeightLabel.Size = UDim2.new(0.44, 0, 1, 0)
			autoTpDownHeightLabel.Position = UDim2.new(0.56, 0, 0, 0)
			autoTpDownHeightLabel.BackgroundColor3 = BOX_COLOR
			autoTpDownHeightLabel.Text = tostring(autoTpDownHeight)
			autoTpDownHeightLabel.PlaceholderText = "2-20"
			autoTpDownHeightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			autoTpDownHeightLabel.TextSize = 14
			autoTpDownHeightLabel.Font = Enum.Font.GothamBold
			autoTpDownHeightLabel.BorderSizePixel = 0
			autoTpDownHeightLabel.ClearTextOnFocus = false
			autoTpDownHeightLabel.Parent = autoTpHeightFrame
			addCorner(autoTpDownHeightLabel, 7)

			autoTpDownHeightLabel.FocusLost:Connect(function()
				setAutoTpDownHeight(autoTpDownHeightLabel.Text)
			end)

			setAutoTpDownHeight(autoTpDownHeight)

			makeButton(contentArea, "DROP MODE", 42, function()
	cycleDropV19Mode()
end)

		elseif sectionName == "Mechanics" then
			makeInfo(contentArea, "Mechanics settings.")

			makeToggle(contentArea, "Infinite Jump", function()
				return jumpEnabled
			end, function()
				jumpEnabled = not jumpEnabled

				if jumpEnabled then
					setStatus("Infinite Jump enabled.")
				else
					resetJumpSequence()
					setStatus("Infinite Jump disabled.")
				end
			end)

			local jumpAmountFrame = Instance.new("Frame")
			jumpAmountFrame.Size = UDim2.new(1, 0, 0, 38)
			jumpAmountFrame.BackgroundTransparency = 1
			jumpAmountFrame.Parent = contentArea

			local jumpAmountTextLabel = Instance.new("TextLabel")
			jumpAmountTextLabel.Size = UDim2.new(0.56, -4, 1, 0)
			jumpAmountTextLabel.Position = UDim2.new(0, 0, 0, 0)
			jumpAmountTextLabel.BackgroundTransparency = 1
			jumpAmountTextLabel.Text = "Infinite Jump Count"
			jumpAmountTextLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
			jumpAmountTextLabel.TextSize = 12
			jumpAmountTextLabel.Font = Enum.Font.GothamBold
			jumpAmountTextLabel.TextXAlignment = Enum.TextXAlignment.Left
			jumpAmountTextLabel.Parent = jumpAmountFrame

			movementJumpAmountLabel = Instance.new("TextBox")
			movementJumpAmountLabel.Size = UDim2.new(0.44, 0, 1, 0)
			movementJumpAmountLabel.Position = UDim2.new(0.56, 0, 0, 0)
			movementJumpAmountLabel.BackgroundColor3 = BOX_COLOR
			movementJumpAmountLabel.Text = tostring(selectedDownJump)
			movementJumpAmountLabel.PlaceholderText = "2-6"
			movementJumpAmountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			movementJumpAmountLabel.TextSize = 14
			movementJumpAmountLabel.Font = Enum.Font.GothamBold
			movementJumpAmountLabel.BorderSizePixel = 0
			movementJumpAmountLabel.ClearTextOnFocus = false
			movementJumpAmountLabel.Parent = jumpAmountFrame
			addCorner(movementJumpAmountLabel, 7)

			movementJumpAmountLabel.FocusLost:Connect(function()
				setDownJumpAmount(movementJumpAmountLabel.Text)
			end)

			updateJumpAmountText()

			makeToggle(contentArea, "Anti Ragdoll", function()
				return antiRagdollEnabled
			end, function()
				antiRagdollEnabled = not antiRagdollEnabled

				if antiRagdollEnabled then
					setStatus("Anti Ragdoll + Anti Knockback enabled.")
					startAntiRagdollWatcher()
				else
					disconnectAntiRagdollConnections()
					applyAntiRagdollState()
					setStatus("Anti Ragdoll + Anti Knockback disabled.")
				end
			end)

			makeToggle(contentArea, "Bat Counter", function()
				return screenGui and screenGui:GetAttribute("BatCounterEnabled") == true
			end, function()
				if screenGui then
					screenGui:SetAttribute("BatCounterEnabled", not (screenGui:GetAttribute("BatCounterEnabled") == true))

					if screenGui:GetAttribute("BatCounterEnabled") == true then
						setStatus("Bat Counter enabled.")
					else
						setStatus("Bat Counter disabled.")
					end
				end
			end)

			makeToggle(contentArea, "Medusa Counter", function()
				return screenGui and screenGui:GetAttribute("MedusaCounterEnabled") == true
			end, function()
				if screenGui then
					screenGui:SetAttribute("MedusaCounterEnabled", not (screenGui:GetAttribute("MedusaCounterEnabled") == true))

					if screenGui:GetAttribute("MedusaCounterEnabled") == true then
						setStatus("Medusa Counter enabled.")
					else
						setStatus("Medusa Counter disabled.")
					end
				end
			end)

		elseif sectionName == "UI" then
			makeInfo(contentArea, "UI settings.")

			makeToggle(contentArea, "Lock Dragging", function()
				return buttonsLocked
			end, function()
				buttonsLocked = not buttonsLocked
				setStatus(buttonsLocked and "Dragging locked." or "Dragging unlocked.")
			end)

			makeButton(contentArea, "Reset Panel Position", 42, function()
				mainFrame.Position = UDim2.new(0.5, -310, 0, 142)
				titleBar.Position = UDim2.new(0.5, -300, 0, 90)
				setStatus("Panel/title positions reset.")
			end)

		elseif sectionName == "Auto" then
			makeInfo(contentArea, "Auto section.")

			makeButton(contentArea, "Auto Left", 42, function()
				toggleAutoMove("Left")
			end)

			makeButton(contentArea, "Auto Right", 42, function()
				toggleAutoMove("Right")
			end)

			makeButton(contentArea, "Stop Auto Movement", 42, function()
				stopAutoMove()
			end)

			makeToggle(contentArea, "Bat Aimbot", function()
				return batAimbotEnabled
			end, function()
				toggleBatAimbot()
			end)

		elseif sectionName == "Settings" then
			makeInfo(contentArea, "Settings.")

			makeButton(contentArea, "Reset Status Text", 42, function()
				setStatus("V91 loaded: sections connected, title detached.")
			end)

			makeButton(contentArea, "Destroy GUI", 42, function()
				stopAutoMove()
				stopBatAimbot()
				disconnectAntiRagdollConnections()

				if screenGui then
					screenGui:Destroy()
				end
			end)
		end

		updateFloatingButtons()
	end

	local function makeSectionButton(text, order)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -16, 0, 42)
		button.Position = UDim2.new(0, 8, 0, 8 + ((order - 1) * 50))
		button.BackgroundColor3 = BUTTON_BLACK
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 15
		button.Font = Enum.Font.GothamBold
		button.BorderSizePixel = 0
		button.Parent = leftPanel
		addCorner(button, 8)

		sectionButtons[text] = button

		button.MouseButton1Click:Connect(function()
			openSection(text)
		end)

		return button
	end
	makeSectionButton("Speed", 1)
	makeSectionButton("Movement", 2)
	makeSectionButton("Mechanics", 3)
	makeSectionButton("UI", 4)
	makeSectionButton("Auto", 5)
	makeSectionButton("Settings", 6)

	local function makeFloatingButtonDraggable(button)
		local dragging = false
		local dragStart
		local startPos

		button.Active = true

		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then

				if buttonsLocked then
					return
				end

				dragging = true
				dragStart = input.Position

				local dragTarget = floatingButtonGroup or button
				startPos = dragTarget.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			) then
				if buttonsLocked then
					return
				end

				local dragTarget = floatingButtonGroup or button
				local delta = input.Position - dragStart

				dragTarget.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	local function createSquareButton(name, position, callback)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(0, 74, 0, 74)
		button.Position = position
		button.BackgroundColor3 = BUTTON_BLACK
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 13
		button.Font = Enum.Font.GothamBold
		button.TextWrapped = true
		button.BorderSizePixel = 0
		button.AutoButtonColor = true
		button.Parent = floatingButtonGroup or screenGui
		button.ZIndex = 51

		addCorner(button, 10)
		makeFloatingButtonDraggable(button)

		button.MouseButton1Click:Connect(function()
			if callback then
				callback()
			end
		end)

		return button
	end

	updateFloatingButtons = function()
		if floatingButtons.AutoLeft then
			floatingButtons.AutoLeft.Text = autoMoving and currentAutoSide == "Left" and "STOP\nLEFT" or "AUTO\nLEFT"
		end

		if floatingButtons.AutoRight then
			floatingButtons.AutoRight.Text = autoMoving and currentAutoSide == "Right" and "STOP\nRIGHT" or "AUTO\nRIGHT"
		end

		if floatingButtons.Carry then
			floatingButtons.Carry.Text = speedMode == "Carry" and "CARRY\nSPEED\nON" or "CARRY\nSPEED\nOFF"
		end

		if floatingButtons.Bat then
			floatingButtons.Bat.Text = batAimbotEnabled and "BAT\nAIM\nON" or "BAT\nAIM\nOFF"
		end

		if floatingButtons.DropTools then
			floatingButtons.DropTools.Text = "DROP"
		end

		if floatingButtons.LaggerCarry then
			floatingButtons.LaggerCarry.Text = speedMode == "Lagger Carry" and "LAGGER\nCARRY\nON" or "LAGGER\nCARRY\nOFF"
		end

		if floatingButtons.TPDown then
			floatingButtons.TPDown.Text = "TP\nDOWN"
		end

		if floatingButtons.Lagger then
			floatingButtons.Lagger.Text = speedMode == "Lagger" and "LAGGER\nMODE\nON" or "LAGGER\nMODE\nOFF"
		end
	end

	floatingButtonGroup = Instance.new("Frame")
	floatingButtonGroup.Name = "DizzyFloatingButtonGroup"
	floatingButtonGroup.Size = UDim2.new(0, 158, 0, 326)
	floatingButtonGroup.Position = UDim2.new(0, 16, 0, 105)
	floatingButtonGroup.BackgroundTransparency = 1
	floatingButtonGroup.BorderSizePixel = 0
	floatingButtonGroup.Active = false
	floatingButtonGroup.Parent = screenGui
	floatingButtonGroup.ZIndex = 50

	local leftX = 0
	local rightX = 84
	local topY = 0
	local gapY = 84

	floatingButtons.Bat = createSquareButton("BatAimbotSquareButton", UDim2.new(0, leftX, 0, topY + gapY), function()
		toggleBatAimbot()
	end)

	floatingButtons.AutoRight = createSquareButton("AutoRightSquareButton", UDim2.new(0, rightX, 0, topY), function()
		toggleAutoMove("Right")
	end)

	floatingButtons.DropTools = createSquareButton("DropSquareButton", UDim2.new(0, leftX, 0, topY), function()
		safeLocalDropHeld()
		updateFloatingButtons()
	end)

	floatingButtons.AutoLeft = createSquareButton("AutoLeftSquareButton", UDim2.new(0, rightX, 0, topY + gapY), function()
		toggleAutoMove("Left")
	end)

	floatingButtons.TPDown = createSquareButton("TPDownSquareButton", UDim2.new(0, leftX, 0, topY + gapY * 2), function()
		tpDownToGround()
		updateFloatingButtons()
	end)

	floatingButtons.Lagger = createSquareButton("LaggerModeSquareButton", UDim2.new(0, leftX, 0, topY + gapY * 3), function()
		if speedMode == "Lagger" then
			speedMode = "Safe"
			setStatus("Speed mode: Safe")
		else
			speedMode = "Lagger"
			setStatus("Speed mode: Lagger")
		end

		applySpeed()
		updateFloatingButtons()
	end)

	floatingButtons.Carry = createSquareButton("CarrySpeedSquareButton", UDim2.new(0, rightX, 0, topY + gapY * 2), function()
		if speedMode == "Carry" then
			speedMode = "Safe"
			setStatus("Speed mode: Safe")
		else
			speedMode = "Carry"
			setStatus("Speed mode: Carry")
		end

		applySpeed()
		updateFloatingButtons()
	end)

	floatingButtons.LaggerCarry = createSquareButton("LaggerCarryModeSquareButton", UDim2.new(0, rightX, 0, topY + gapY * 3), function()
		if speedMode == "Lagger Carry" then
			speedMode = "Safe"
			setStatus("Speed mode: Safe")
		else
			speedMode = "Lagger Carry"
			setStatus("Speed mode: Lagger Carry")
		end

		applySpeed()
		updateFloatingButtons()
	end)

	local function applyMinimizedState()
		titleBar.Size = shortTabSize
		title.Size = shortTitleSize
		mainFrame.BackgroundTransparency = 1

		if minimized then

			body.Visible = false
			mainFrame.Visible = false

			minimizeButton.Visible = false
			minimizeButton.Active = false
			minimizeButton.Selectable = false
		else

			mainFrame.Visible = true
			mainFrame.Size = fullSize
			body.Visible = true
			body.Size = fullBodySize

			minimizeButton.Visible = true
			minimizeButton.Active = true
			minimizeButton.Selectable = true
			minimizeButton.Text = "-"
		end
	end

	minimizeButton.MouseButton1Click:Connect(function()
		minimized = true
		applyMinimizedState()
	end)

	local minimizedClickStart = nil

	titleBar.InputBegan:Connect(function(input)
		if minimized and (
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			minimizedClickStart = input.Position
		end
	end)

	titleBar.InputEnded:Connect(function(input)
		if not minimized or not minimizedClickStart then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local moved = (input.Position - minimizedClickStart).Magnitude
		minimizedClickStart = nil

		if moved <= 8 then
			minimized = false
			applyMinimizedState()
		end
	end)

	applyMinimizedState()

	openSection("Speed")
	updateFloatingButtons()
end

createGui()
task.delay(0.6, createOrUpdateOverheadText)
forceAddVisibleDropOnlyButton()
setupMobileTouchMovement()

if player.Character then
	task.spawn(function()
		setupCharacter(player.Character)
	end)
else
	setStatus("Waiting for character...")
end

player.CharacterAdded:Connect(function(char)
	task.spawn(function()
		setupCharacter(char)
	end)
end)

UserInputService.JumpRequest:Connect(handleJumpAbility)

RunService.RenderStepped:Connect(function()
	if humanoid and humanoid.Health > 0 then
		rememberMoveDirection()
		keepGuiButtonsAlive()

		if not isAirborne() then
			resetJumpSequence()
		end

		autoProtectImportantTools()
		updateToolGuard()
		updateAntiRagdoll()
		forceLocalSpeed()
		updateAutoTpDown()
		forceManualMovementDropy()
		updateBatAimbot()
		pcall(function()
			if not screenGui or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				return
			end

			local velocity = humanoidRootPart.AssemblyLinearVelocity
			local flatSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			local ySpeed = math.abs(velocity.Y)
			local currentState = humanoid:GetState()
			local now = os.clock()

			if __DIZZY_DROP_SUPPRESS_TOOL_UNTIL and now < __DIZZY_DROP_SUPPRESS_TOOL_UNTIL then
				screenGui:SetAttribute("BatCounterLastVelocity", velocity.Magnitude)
				return
			end

			if currentState == Enum.HumanoidStateType.Jumping or humanoid.Jump then
				screenGui:SetAttribute("BatCounterLastJumpTime", now)
			end

			if screenGui:GetAttribute("BatCounterEnabled") ~= true then
				screenGui:SetAttribute("BatCounterLastVelocity", velocity.Magnitude)
				return
			end

			local lastJumpTime = screenGui:GetAttribute("BatCounterLastJumpTime")
			local busyUntil = screenGui:GetAttribute("BatCounterBusyUntil")

			if typeof(lastJumpTime) ~= "number" then
				lastJumpTime = 0
			end

			if typeof(busyUntil) ~= "number" then
				busyUntil = 0
			end

			if now < busyUntil then
				return
			end

			local recentlyJumped = now - lastJumpTime < 0.45
			local strongRagdollState =
				humanoid.PlatformStand
				or humanoid.Sit
				or currentState == Enum.HumanoidStateType.Ragdoll
				or currentState == Enum.HumanoidStateType.FallingDown
				or currentState == Enum.HumanoidStateType.PlatformStanding
				or currentState == Enum.HumanoidStateType.Physics

			local previousVelocity = screenGui:GetAttribute("BatCounterLastVelocity")

			if typeof(previousVelocity) ~= "number" then
				previousVelocity = velocity.Magnitude
			end

			local velocitySpike = velocity.Magnitude - previousVelocity > 18

			local antiKbSpeedForCounter = getAntiKnockbackSpeed and getAntiKnockbackSpeed() or DEFAULT_WALK_SPEED

			local looksLikeBatHit =
				(strongRagdollState and not recentlyJumped)
				or (ySpeed > 75 and velocitySpike and not recentlyJumped and flatSpeed < antiKbSpeedForCounter + 35)

			if not looksLikeBatHit then
				screenGui:SetAttribute("BatCounterLastVelocity", velocity.Magnitude)
				return
			end

			local lastCounterTime = screenGui:GetAttribute("BatCounterLastTime")

			if typeof(lastCounterTime) ~= "number" then
				lastCounterTime = 0
			end

			if now - lastCounterTime < 0.9 then
				return
			end

			local backpack = player:FindFirstChild("Backpack")
			local batTool = nil

			if character then
				for _, object in ipairs(character:GetChildren()) do
					if object:IsA("Tool") and string.find(string.lower(object.Name or ""), "bat", 1, true) then
						batTool = object
						break
					end
				end
			end

			if not batTool and backpack then
				for _, object in ipairs(backpack:GetChildren()) do
					if object:IsA("Tool") and string.find(string.lower(object.Name or ""), "bat", 1, true) then
						batTool = object
						break
					end
				end
			end

			if not batTool then
				screenGui:SetAttribute("BatCounterLastTime", now)
				setStatus("Bat Counter: no bat found.")
				return
			end

			pcall(function()
				humanoid.PlatformStand = false
				humanoid.Sit = false
				humanoid.AutoRotate = true
			end)

			if batTool.Parent ~= character and humanoid then
				pcall(function()
					humanoid:EquipTool(batTool)
				end)
			end

			screenGui:SetAttribute("BatCounterBusyUntil", now + 1.05)
			screenGui:SetAttribute("MedusaCounterBlockUntil", now + 1.25)

			task.spawn(function()
				task.wait(0.01)

				if batTool and batTool.Parent then
					pcall(function()
						batTool:Activate()
					end)
				end
			end)

			screenGui:SetAttribute("BatCounterLastTime", now)
			screenGui:SetAttribute("BatCounterLastVelocity", velocity.Magnitude)
			setStatus("Bat Counter: knockback detected, single bat activation.")
		end)
		pcall(function()
			if not screenGui or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				return
			end

			if screenGui:GetAttribute("MedusaCounterEnabled") ~= true then
				return
			end

			local now = os.clock()

			if __DIZZY_DROP_SUPPRESS_TOOL_UNTIL and now < __DIZZY_DROP_SUPPRESS_TOOL_UNTIL then
				return
			end

			local medusaBlockedUntil = screenGui:GetAttribute("MedusaCounterBlockUntil")

			if typeof(medusaBlockedUntil) == "number" and now < medusaBlockedUntil then
				return
			end

			local lastCounterTime = screenGui:GetAttribute("MedusaCounterLastTime")

			if typeof(lastCounterTime) ~= "number" then
				lastCounterTime = 0
			end

			if now - lastCounterTime < 0.18 then
				return
			end

			local currentState = humanoid:GetState()
			local velocity = humanoidRootPart.AssemblyLinearVelocity
			local flatSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			local looksFrozen = false
			local hasFreezeMarker = false

			if character then
				for _, object in ipairs(character:GetDescendants()) do
					if not object:IsA("Tool") and not object:FindFirstAncestorOfClass("Tool") then
						local lowerName = string.lower(object.Name or "")

						if string.find(lowerName, "stone", 1, true)
							or string.find(lowerName, "petrify", 1, true)
							or string.find(lowerName, "petrified", 1, true)
							or string.find(lowerName, "freeze", 1, true)
							or string.find(lowerName, "frozen", 1, true) then
							hasFreezeMarker = true
							break
						end
					end
				end
			end

			if hasFreezeMarker then
				looksFrozen = true
			elseif screenGui:GetAttribute("BatCounterEnabled") == true then
				return
			elseif humanoid.PlatformStand
				or currentState == Enum.HumanoidStateType.PlatformStanding
				or currentState == Enum.HumanoidStateType.Physics then
				if flatSpeed < 18 and math.abs(velocity.Y) < 18 then
					looksFrozen = true
				end
			end

			if not looksFrozen then
				return
			end

			local backpack = player:FindFirstChild("Backpack")
			local medusaTool = nil

			if character then
				for _, object in ipairs(character:GetChildren()) do
					if object:IsA("Tool") then
						local lowerName = string.lower(object.Name or "")

						if string.find(lowerName, "medusa", 1, true) then
							medusaTool = object
							break
						end
					end
				end
			end

			if not medusaTool and backpack then
				for _, object in ipairs(backpack:GetChildren()) do
					if object:IsA("Tool") then
						local lowerName = string.lower(object.Name or "")

						if string.find(lowerName, "medusa", 1, true) then
							medusaTool = object
							break
						end
					end
				end
			end

			if not medusaTool then
				screenGui:SetAttribute("MedusaCounterLastTime", now)
				setStatus("Medusa Counter: no Medusa found.")
				return
			end

			pcall(function()
				humanoid.PlatformStand = false
				humanoid.Sit = false
				humanoid.AutoRotate = true
			end)

			if medusaTool.Parent ~= character and humanoid then
				pcall(function()
					humanoid:EquipTool(medusaTool)
				end)
			end

			task.spawn(function()
				for _ = 1, 2 do
					if medusaTool and medusaTool.Parent then
						pcall(function()
							medusaTool:Activate()
						end)
					end

					task.wait(0.012)
				end
			end)

			screenGui:SetAttribute("MedusaCounterLastTime", now)
			setStatus("Medusa Counter: Medusa activated fast.")
		end)
	end
end)

setStatus("V91 loaded: sections connected, title detached.")
