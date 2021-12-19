-- Wait for game to load
repeat wait() until game:IsLoaded()

-- Synapse Compatibilities
if syn then
    queue_on_teleport = syn.queue_on_teleport
    request = syn.request
end

if not getgenv().DiscordJoined then
	request({
		Url = "http://127.0.0.1:6463/rpc?v=1",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["Origin"] = "https://discord.com"
		},
		Body = game:GetService("HttpService"):JSONEncode({
			cmd = "INVITE_BROWSER",
			args = {
				code = "MKVr5DunmQ"
			},
			nonce = game:GetService("HttpService"):GenerateGUID(false)
		}),
	})
end

-- Queue on Teleport
pcall(queue_on_teleport, [[loadstring(game:HttpGet("https://raw.githubusercontent.com/kubuntuclaps/Roblox-Scripts/main/Red%20Light%20Green%20Light.lua"))()]])

-- Variables
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CameraSubject = Workspace.Camera.CameraSubject

-- Global Variables
getgenv().DiscordJoined = true -- Avoiding Discord Join Multiple Times
getgenv().InfiniteJump = false
getgenv().CurrentCookie = nil
getgenv().RopeGame = false
getgenv().MarbleGame = false
getgenv().GlassESP = false
getgenv().GlassESPColor = Color3.fromRGB(0, 255, 0)
getgenv().AutoPunch = false

-- Metamethod Hook for WalkSpeed and JumpHeight
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and tostring(Self) == "Humanoid" and Key == "WalkSpeed" then
        return 16
    elseif not checkcaller() and tostring(Self) == "Humanoid" and Key == "JumpHeight" then
       return 7.2 
    end

    return OldIndex(Self, Key)
end)    

-- Infinite Jump
UIS.InputBegan:Connect(function(UserInput)
    if UserInput.UserInputType == Enum.UserInputType.Keyboard and UserInput.KeyCode == Enum.KeyCode.Space then
        if getgenv().InfiniteJump then
            LocalPlayer.Character.Humanoid:ChangeState(3)
        end
    end
end)

-- Hook OnClientEvent to get the current cookie
pcall(function()
    ReplicatedStorage.Remotes.StartHoneycomb.OnClientEvent:Connect(function(Cookie)
        getgenv().CurrentCookie = Cookie
    end)
end)

local function AutoPunch()
    local Distance = math.huge
    local Closest

    for next, Target in pairs(Players:GetPlayers()) do
        if Target ~= LocalPlayer and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character.Humanoid.Health > 0 and not Target:GetAttribute("Guard") then
            local Magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - Target.Character.HumanoidRootPart.Position).magnitude
            if Magnitude < Distance then
                Distance = Magnitude
                Closest = Target
            end
        end
    end

    if Closest ~= nil then ReplicatedStorage.Remotes.PunchEvent:FireServer(Workspace[Closest.Name]) end
end

-- ImGui Settings
local ImGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/kubuntuclaps/Roblox-Scripts/main/UI/ImGui.lua"))()
local Settings = {
    main_color = Color3.fromRGB(0, 0, 0),
    min_size = Vector2.new(600, 400),
    toggle_key = Enum.KeyCode.RightShift,
    can_resize = true,
}
local Window = ImGui:AddWindow("kubuntuhaxs™ - Red Light, Green Light", Settings)
local PlayerTab = Window:AddTab("LocalPlayer")
local AutoWinTab = Window:AddTab("Auto Win")
local GamepassTab = Window:AddTab("Gamepass")
local VisualsTab = Window:AddTab("Visuals")
local MiscTab = Window:AddTab("Misc")
local CreditsTab = Window:AddTab("Credits")

-- Player Tab
PlayerTab:AddLabel("Movility")

local WalkSpeedSlider = PlayerTab:AddSlider("WalkSpeed", function(walkspeed)
    LocalPlayer.Character.Humanoid.WalkSpeed = walkspeed
end, {
	["min"] = 16,
	["max"] = 100,
})
WalkSpeedSlider:Set(1)

local JumpSlider = PlayerTab:AddSlider("JumpHeight", function(jump)
    LocalPlayer.Character.Humanoid.JumpHeight = jump
end, {
    ["min"] = 7,
    ["max"] = 100,
})
JumpSlider:Set(1)

local InfiniteJump = PlayerTab:AddSwitch("Infinite Jump", function(toggle)
    getgenv().InfiniteJump = toggle
end)
InfiniteJump:Set(false)

-- Auto Win Tab
AutoWinTab:AddLabel("Auto Win")

local tweenInfo = TweenInfo.new(13, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(-341, 3, 435)})

local WinDoll = AutoWinTab:AddSwitch("Win Doll Game", function(toggle)
    ReplicatedStorage.Remotes.ReachedGoal:FireServer(Workspace.Mechanics.GoalPart1)
    if toggle and tween.PlaybackState ~= Enum.PlaybackState.Playing then
        tween:Play()
    elseif not toggle and tween.PlaybackState == Enum.PlaybackState.Playing then
        tween:Cancel()
    end
end)

local WinCookie = AutoWinTab:AddButton("Win Honey Comb Game", function()
    if getgenv().CurrentCookie ~= nil then
        getgenv().CurrentCookie:SetAttribute("Percent", 100)
        getgenv().CurrentCookie[getgenv().CurrentCookie.Name .. "Hitboxes"]:ClearAllChildren()
        wait(5)
        ReplicatedStorage.Remotes.HoneyCombResult:FireServer(true)
    end
end)

local WinRope = AutoWinTab:AddSwitch("Win Rope Game", function(toggle)
    getgenv().RopeGame = toggle
end)
WinRope:Set(false)

local MarbleGame = AutoWinTab:AddSwitch("Win Marble Game", function(toggle)
    getgenv().MarbleGame = toggle
end)

local WinGlass = AutoWinTab:AddButton("Win Glass Game", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-501, 78, -480)
end)

local WinSquid = AutoWinTab:AddSwitch("Win Squid Game", function(toggle)
    if toggle then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-314, 3, 326)
    end
    getgenv().AutoPunch = toggle
end)
WinSquid:Set(false)

-- Gamepass Tab
GamepassTab:AddLabel("Guard Options")

local BecomeGuard = GamepassTab:AddButton("Become Guard", function()
    ReplicatedStorage.GuardRemotes.BecomeGuard:InvokeServer(true)
end)

local CollectAllBodies = GamepassTab:AddButton("Collect All Bodies", function()
    for next, Body in pairs(Workspace.Bodies:GetChildren()) do
        ReplicatedStorage.GuardRemotes.CollectBody:FireServer(LocalPlayer, Body.Torso.CFrame, Body.Name)
    end
end)

GamepassTab:AddLabel("Frontman Options")

local BecomeFrontman = GamepassTab:AddButton("Become Frontman", function()
    ReplicatedStorage.FrontmanRemotes.BecomeFrontman:InvokeServer(true)
end)

-- Visuals Tab
VisualsTab:AddLabel("Visuals")

local GlassESP = VisualsTab:AddSwitch("Glass ESP", function(toggle)
    getgenv().GlassESP = toggle

    if not toggle then
        for next, Glass in pairs(Workspace.Glass:GetChildren()) do
            if Glass:FindFirstChild("SelectionBox") then
                Glass.SelectionBox.Transparency = 1
            end
        end
    end
end)

local GlassESPColor = VisualsTab:AddColorPicker("Glass ESP Color", function(color)
    getgenv().GlassESPColor = color
end)

-- Misc Tab
MiscTab:AddLabel("Global Exploits")

local TeleportUp = MiscTab:AddButton("Teleport To Game", function()
    ReplicatedStorage.Remotes.ReachedGoal:FireServer(Workspace.Mechanics.GoalPart1)
end)

local RemoveKillparts = MiscTab:AddButton("Remove Killparts", function()
    Workspace.Mechanics:WaitForChild("Kill"):Destroy()
    Workspace.Mechanics:WaitForChild("Kill2"):Destroy()
end)

local RemoveBlockparts = MiscTab:AddButton("Remove Blockparts", function()
    Workspace.Mechanics:WaitForChild("Block"):Destroy()
    Workspace.Mechanics:WaitForChild("Block2"):Destroy()
end)

MiscTab:AddLabel("Game Exploits")

local BreakGlasses = MiscTab:AddButton("Break Glasses", function()
    for next, Glass in pairs(Workspace.Glass:GetChildren()) do
        ReplicatedStorage.Remotes.BreakGlass:FireServer(Glass)
    end
end)

local AutoPunchToggle = MiscTab:AddSwitch("Auto Punch", function(toggle)
    getgenv().AutoPunch = toggle
end)

local ChangeTeam = MiscTab:AddDropdown("Change Rope Team", function(team)
    ReplicatedStorage.Remotes.TeamUi:FireServer(tonumber(team))
end)
local Team1 = ChangeTeam:Add("1")
local Team2 = ChangeTeam:Add("2")

MiscTab:AddLabel("Teleport Options")

local ReturnLobby = MiscTab:AddButton("Return to Lobby", function()
    TeleportService:Teleport(7540891731, LocalPlayer)
end)

-- Credits Tab
CreditsTab:AddLabel("Made by kubuntuclaps")
CreditsTab:AddLabel("UI Made by Singularity#5490")
CreditsTab:AddLabel("Thanks to cursedv2 for showcasing me <3")
CreditsTab:AddLabel("Thanks to tenaki#6824 for emotional support :)")
CreditsTab:AddButton("Copy Discord Link", function()
    setclipboard("https://discord.gg/MKVr5DunmQ")
end)

ImGui:FormatWindows()
CreditsTab:Show()

-- RenderStepped Loop
RunService.RenderStepped:Connect(function()
    if getgenv().AutoPunch then
        AutoPunch()
    elseif getgenv().RopeGame then
        ReplicatedStorage.Pull:FireServer(1)
    elseif getgenv().GlassESP then
        for next, Glass in pairs(Workspace.Glass:GetChildren()) do
            if Glass:FindFirstChild("SelectionBox") then
                Glass.SelectionBox.Transparency = 0
                Glass.SelectionBox.SurfaceColor3 = getgenv().GlassESPColor
            end
        end
    end
end)