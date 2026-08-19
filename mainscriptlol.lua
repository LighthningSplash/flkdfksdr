local function missing(t, f, fallback)
	if type(f) == t then
		return f
	end
	return fallback
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

print("Script started")

while not player do
	task.wait()
	player = Players.LocalPlayer
end

print("Player found:", player.Name)

local queueteleport = missing(
	"function",
	queue_on_teleport
		or (syn and syn.queue_on_teleport)
		or (fluxus and fluxus.queue_on_teleport)
)

_G.hasFiredPlayAgain = nil

task.spawn(function()
	while not player do
		task.wait()
		player = Players.LocalPlayer
	end
	player.OnTeleport:Connect(function()
		if queueteleport then
			queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/LighthningSplash/flkdfksdr/refs/heads/main/mainscriptlol.lua'))()")
		end
	end)
end)

while not player do
	task.wait()
	player = Players.LocalPlayer
end

print("Waiting for StarterElevator...")
repeat task.wait() until workspace:FindFirstChild("StarterElevator", true)
print("StarterElevator found")

print("Waiting for Character...")
repeat task.wait() until player.Character
print("Character found")

print("Waiting for HumanoidRootPart...")
repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")
print("HumanoidRootPart found")

task.wait(2)

print("Getting PlayerGui...")
local playerGui = player:WaitForChild("PlayerGui", 10)
local mainUI = playerGui and playerGui:WaitForChild("MainUI", 10)
local itemShop = mainUI and mainUI:WaitForChild("ItemShop", 10)
local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder", 10)

if not remotesFolder then
	warn("RemotesFolder not found.")
	return
end

print("RemotesFolder found")

local crouchRemote = remotesFolder:FindFirstChild("Crouch")
if crouchRemote then
	crouchRemote:FireServer(false, true)
	print("Crouch fired")
end

local cewcew = true

task.spawn(function()
	while cewcew do
		local remotes = ReplicatedStorage:FindFirstChild("RemotesFolder")
		if remotes then
			local crouch = remotes:FindFirstChild("Crouch")
			if crouch then
				pcall(function()
					crouch:FireServer(true, true)
				end)
			end
		end
		task.wait()
	end
end)

local function getCharacter()
	local character = player.Character
	if not character or not character.Parent then
		character = player.CharacterAdded:Wait()
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		hrp = character:WaitForChild("HumanoidRootPart", 10)
	end
	return character, hrp
end

local function getCurrentHRP()
	local character = player.Character
	if not character or not character.Parent then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function checkAlive()
	local character = player.Character
	if not character or not character.Parent then
		return false
	end
	
	local alive = character:FindFirstChild("Alive")
	if not alive then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			return true
		end
		return false
	end
	
	return alive.Value == true
end

print("Waiting for CurrentRooms...")
local currentRooms = workspace:WaitForChild("CurrentRooms", 10)
local currentRoom0 = currentRooms and currentRooms:WaitForChild("0", 10)

if currentRoom0 then
	print("Room 0 found")
	local assets = currentRoom0:WaitForChild("Assets", 10)
	local keyObtain = assets and assets:WaitForChild("KeyObtain", 10)
	local keyHitbox = keyObtain and keyObtain:WaitForChild("Hitbox", 10)
	local keyTimeout = tick()
	print("Looking for key...")
	repeat
		local character, hrp = getCharacter()
		local keyObject = currentRoom0:FindFirstChild("KeyObtain", true)
		local keyPrompt = keyObject and keyObject:FindFirstChild("ModulePrompt")
		if keyHitbox and keyHitbox.Parent and hrp then
			hrp.CFrame = CFrame.new(keyHitbox.Position + Vector3.new(0, 0, 5))
		end
		if keyPrompt and keyPrompt:IsDescendantOf(workspace) then
			pcall(function()
				fireproximityprompt(keyPrompt)
			end)
		end
		task.wait(0.05)
	until (player.Character and player.Character:FindFirstChild("Key")) or (tick() - keyTimeout > 15)

	if player.Character and player.Character:FindFirstChild("Key") then
		print("Key obtained!")
	else
		print("Key timeout")
	end

	print("Finding RoomExit...")
	local roomExit = currentRoom0:WaitForChild("RoomExit", 10)
	local doorLooping = true
	print("RoomExit found, starting door loop...")
	task.spawn(function()
		while doorLooping do
			local character, hrp = getCharacter()
			local doorPrompt = currentRoom0:FindFirstChild("UnlockPrompt", true)
			if roomExit and roomExit.Parent and hrp then
				hrp.CFrame = CFrame.new(roomExit.Position + Vector3.new(0, 0, 5))
			end
			if doorPrompt and doorPrompt:IsDescendantOf(workspace) then
				pcall(function()
					fireproximityprompt(doorPrompt)
				end)
			end
			task.wait(0.05)
		end
	end)

	cewcew = false
	print("Waiting 8 seconds...")
	task.wait(8)
	doorLooping = false
	print("Room 0 complete")
end

-- Check for death within 4 seconds of finishing RoomExit teleport
print("Checking for death post RoomExit...")
local roomExitDeathTimer = tick()
local deathDetected = false

while tick() - roomExitDeathTimer < 4 do
	if not checkAlive() then
		deathDetected = true
		print("Death detected after RoomExit!")
		break
	end
	task.wait(0.1)
end

-- If no death detected, try teleporting to all "Eyes" parts for 4 seconds
if not deathDetected then
	print("No death detected within 4s. Starting teleport to 'Eyes' parts...")
	local eyesDeathTimer = tick()
	
	while tick() - eyesDeathTimer < 4 do
		if not checkAlive() then
			deathDetected = true
			print("Death detected while teleporting to Eyes!")
			break
		end
		
		-- Find all "Eyes" models/parts in workspace
		local eyesInstances = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.Name == "Eyes" then
				table.insert(eyesInstances, v)
			end
		end

		local hrp = getCurrentHRP()
		if hrp and #eyesInstances > 0 then
			for _, eyeObj in ipairs(eyesInstances) do
				if not checkAlive() then
					deathDetected = true
					break
				end
				local eyePos = eyeObj:IsA("Model") and eyeObj:GetPivot().Position or (eyeObj:IsA("BasePart") and eyeObj.Position)
				if eyePos then
					hrp.CFrame = CFrame.new(eyePos)
				end
				task.wait(0.1)
			end
		else
			task.wait(0.1)
		end
	end
end

--------------------------------------------------------------------------------
-- PLAY AGAIN / VIRTUAL MOUSE CLICK LOGIC
--------------------------------------------------------------------------------
local progressDetected = false

-- Track progression (Teleport or respawn)
local teleportConn
teleportConn = player.OnTeleport:Connect(function()
	progressDetected = true
	if teleportConn then teleportConn:Disconnect() end
end)

local charConn
charConn = player.CharacterAdded:Connect(function()
	progressDetected = true
	if charConn then charConn:Disconnect() end
end)

-- Function to click UI Button via VirtualInputManager mouse event
local function clickPlayAgainButton(button)
	if not button or not button:IsA("GuiObject") then return end

	print("Clicking button using Virtual Mouse...")

	pcall(function()
		local pos = button.AbsolutePosition
		local size = button.AbsoluteSize
		local clickPos = pos + (size / 2)
		
		VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 1)
		task.wait(0.05)
		VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 1)
	end)
end

-- Helper to wait until the PlayAgain TextButton is visible on screen
local function waitForButtonVisible()
	print("Waiting for PlayAgain button to become visible...")
	while not progressDetected do
		local deathPanel = mainUI and mainUI:FindFirstChild("DeathPanel")
		local playAgainBtn = deathPanel and deathPanel:FindFirstChild("PlayAgain")

		if playAgainBtn and playAgainBtn:IsA("GuiObject") then
			if playAgainBtn.Visible and playAgainBtn.AbsoluteSize.X > 0 then
				return playAgainBtn
			end
		end
		task.wait(0.2)
	end
	return nil
end

-- Main Flow Execution
local playAgainBtn = waitForButtonVisible()

if playAgainBtn and not progressDetected then
	print("PlayAgain button is now visible! Waiting 1 second...")
	task.wait(1)

	while not progressDetected do
		clickPlayAgainButton(playAgainBtn)
		
		-- Check every 0.2s for 5s if click triggered progression
		local clickStart = tick()
		while tick() - clickStart < 5 do
			if progressDetected then break end
			task.wait(0.2)
		end

		if not progressDetected then
			print("No progress detected after click, retrying Virtual Mouse click...")
		end
	end
end

print("Progress detected! PlayAgain execution completed.")
print("Script finished execution")
