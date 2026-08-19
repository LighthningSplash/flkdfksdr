-- Dev test farm
-- Use in Roblox Studio Admin command bar
-- Press PlayTest to use Command Bar

local function missing(t, f, fallback)
	if type(f) == t then
		return f
	end
	return fallback
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

print("Script started")

while not player do
	task.wait(0.5)
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
		task.wait(0.5)
		player = Players.LocalPlayer
	end
	player.OnTeleport:Connect(function()
		if queueteleport then
			queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/LighthningSplash/flkdfksdr/refs/heads/main/mainscriptlol.lua'))()")
		end
	end)
end)

print("Waiting for StarterElevator...")
repeat task.wait(0.5) until workspace:FindFirstChild("StarterElevator", true)
print("StarterElevator found")

print("Waiting for Character...")
repeat task.wait(0.5) until player.Character
print("Character found")

print("Waiting for HumanoidRootPart...")
repeat task.wait(0.5) until player.Character:FindFirstChild("HumanoidRootPart")
print("HumanoidRootPart found")

local playerGui = player:WaitForChild("PlayerGui", 5)
local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder", 5)

if not remotesFolder then
	warn("RemotesFolder not found.")
	return
end

local crouchRemote = remotesFolder:FindFirstChild("Crouch")
if crouchRemote then
	crouchRemote:FireServer(false, true)
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
		task.wait(0.5)
	end
end)

local function getCharacter()
	local character = player.Character
	if not character or not character.Parent then
		character = player.CharacterAdded:Wait()
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		hrp = character:WaitForChild("HumanoidRootPart", 5)
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

-- Continuous background Eyes tracking loop
local function startEyesTrackingLoop()
	task.spawn(function()
		while true do
			local char = player.Character
			if char and checkAlive() then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")
				local eyes = workspace:FindFirstChild("Eyes", true)
				local motorRemote = remotesFolder:FindFirstChild("MotorReplication")
				
				if eyes and hrp and head and motorRemote then
					local eyesPos = eyes:GetPivot().Position
					
					-- Continuous character look at Eyes
					local lookAtCF = CFrame.lookAt(hrp.Position, Vector3.new(eyesPos.X, hrp.Position.Y, eyesPos.Z))
					hrp.CFrame = lookAtCF
					
					-- Camera look at Eyes
					local cam = workspace.CurrentCamera
					cam.CameraType = Enum.CameraType.Scriptable
					cam.CFrame = CFrame.lookAt(head.Position + Vector3.new(0, 0.5, 0), eyesPos)
					
					-- MotorReplication pitch angle encoding
					local rx, _, _ = CFrame.lookAt(head.Position, eyesPos):ToOrientation()
					local pitchInDegrees = math.deg(rx)
					local encodedMotorValue = math.round(pitchInDegrees * 10)
					
					pcall(function()
						motorRemote:FireServer(encodedMotorValue)
					end)
				end
			end
			task.wait(0.5)
		end
	end)
end

-- Fast teleport to Eyes
local function teleportToEyes()
	local eyes = workspace:FindFirstChild("Eyes", true)
	if eyes then
		local hrp = getCurrentHRP()
		if hrp then
			local eyesPos = eyes:GetPivot().Position
			hrp.CFrame = CFrame.new(eyesPos + Vector3.new(0, 2, 3))
			print("Teleported to Eyes")
			return true
		end
	end
	return false
end

-- Start background MotorReplication loop
startEyesTrackingLoop()

print("Waiting for CurrentRooms...")
local currentRooms = workspace:WaitForChild("CurrentRooms", 5)
local currentRoom0 = currentRooms and currentRooms:WaitForChild("0", 5)

if currentRoom0 then
	print("Room 0 found")
	local assets = currentRoom0:WaitForChild("Assets", 5)
	local keyObtain = assets and assets:WaitForChild("KeyObtain", 5)
	local keyHitbox = keyObtain and keyObtain:WaitForChild("Hitbox", 5)
	local keyTimeout = tick()
	
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
		task.wait(0.5)
	until (player.Character and player.Character:FindFirstChild("Key")) or (tick() - keyTimeout > 8)

	local roomExit = currentRoom0:WaitForChild("RoomExit", 5)
	local doorLooping = true
	
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
			task.wait(0.5)
		end
	end)

	cewcew = false
	task.wait(3)
	doorLooping = false
	
	teleportToEyes()
end

-- Instant death detection loop
repeat
	task.wait(0.5)
until not checkAlive()

print("Character dead. Handling rejoin sequence...")

-- Wait 3 seconds post-death before firing PlayAgain
task.wait(3)

local playAgainRemote = remotesFolder:WaitForChild("PlayAgain", 5)

local function firePlayAgain()
	if playAgainRemote then
		pcall(function()
			playAgainRemote:FireServer()
		end)
	end
end

-- Initial PlayAgain attempt
firePlayAgain()

-- Rejoin fallback loop: checking every 10 seconds if no progress occurs
task.spawn(function()
	while true do
		task.wait(10)
		-- Check if player is still dead/hasn't progressed to a new place or character
		if not checkAlive() then
			print("No progress detected after 10 seconds. Retrying PlayAgain...")
			firePlayAgain()
		else
			break
		end
	end
end)

print("Finished")
