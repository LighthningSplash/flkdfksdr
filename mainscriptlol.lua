-- AutoFarm Death (Standalone)
local stoped = false
if _G.DEATH_FARM then
    return
end
_G.DEATH_FARM = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local RemotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder", 999)
local PlayAgain = RemotesFolder:WaitForChild("PlayAgain", 999)
local Crouch = RemotesFolder:WaitForChild("Crouch")
local MotorRemote = RemotesFolder:FindFirstChild("MotorReplication")

player.OnTeleport:Connect(function()
    queue_on_teleport([[loadstring(game:HttpGet('https://raw.githubusercontent.com/LighthningSplash/flkdfksdr/refs/heads/main/mainscriptlol.lua'))()]])
end)

local character = player.Character or player.CharacterAdded:Wait()

-- Fast crouch spam (anti-cheat bypass)
task.spawn(function()
    while task.wait() do
        Crouch:FireServer(true, true)
    end
end)

local room = workspace:WaitForChild("CurrentRooms", 999):WaitForChild("0", 999)
local elevator = room:WaitForChild("StarterElevator", 999)

local CFrame1 = CFrame.new(249.999954, -0.373500377, -9.99999714, 0.99999994, 0, 0.00037855946, 0, 1, 0, -0.00037855946, 0, 0.99999994)
local CFrame2 = CFrame.new(243.364471, -0.373500377, -50.2721786, 0.066934742, 0, 0.997757375, 0, 1, 0, -0.997757375, 0, 0.066934742)
local CFrame3 = CFrame.new(265.486267, -0.400000364, -48.4754181, 0.999383152, 3.15590509e-9, 0.0351186804, -2.2460569e-9, 1, -2.59472621e-8, -0.0351186804, 2.5852378e-8, 0.999383152)

local ended = false
local st = 0
local killCooldown = false
local progressTimeout = false
local doorOpened = false

local function hasKey()
    local backpack = player:FindFirstChild("Backpack")
    local key = character:FindFirstChild("Key") or (backpack and backpack:FindFirstChild("Key"))
    return key
end

local function teleportToEyes()
    local eyes = workspace:FindFirstChild("Eyes", true)
    if eyes and character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local eyesPos = eyes:GetPivot().Position
        local targetCF = CFrame.new(eyesPos + (eyes:GetPivot().LookVector * 6), eyesPos)
        hrp.CFrame = targetCF

        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Scriptable
        local targetCamPos = targetCF.Position + Vector3.new(0, 2, 0)
        local targetCamCF = CFrame.new(targetCamPos, eyesPos)
        local tween = TweenService:Create(cam, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = targetCamCF})
        tween:Play()

        if MotorRemote then
            local rx, ry, rz = targetCamCF:ToOrientation()
            local pitchDeg = math.deg(rx)
            local encoded = math.round(pitchDeg * 10)
            MotorRemote:FireServer(encoded)
        end
    end
end

-- Pre-run shop and skip
RemotesFolder.PreRunShop:FireServer({})
fireproximityprompt(elevator.Model.Model.SkipButton.SkipPrompt)

workspace.CurrentRooms.ChildAdded:Once(function()
    ended = true
    task.wait(0.1)
    if not killCooldown then
        killCooldown = true
        task.wait(10)
        replicatesignal(player.Kill)
    end
    task.wait(0.1)
    PlayAgain:FireServer()
end)

RemotesFolder.Statistics.OnClientEvent:Connect(function()
    if stoped then return end
    PlayAgain:FireServer()
end)

character:PivotTo(CFrame1)

-- Get key
while not hasKey() do
    character.PrimaryPart.CFrame = room.Assets.KeyObtain.Hitbox.CFrame
    fireproximityprompt(room.Assets.KeyObtain.ModulePrompt)
    task.wait()
end

character:PivotTo(CFrame2)

local function GetProxiOpen()
    for _, i in room.Door:GetDescendants() do
        if i:IsA("ProximityPrompt") then
            return i
        end
    end
    return
end

local promptUnlock = GetProxiOpen()

-- Door unlock + progress monitoring
task.spawn(function()
    while not ended do
        character.PrimaryPart.CFrame = CFrame3
        fireproximityprompt(promptUnlock)
        doorOpened = true
        task.wait()
    end
end)

task.spawn(function()
    task.wait(5) -- wait 5 seconds after door is first unlocked
    if not ended and doorOpened then
        while not ended do
            teleportToEyes()
            task.wait(0.1)
        end
    end
end)
