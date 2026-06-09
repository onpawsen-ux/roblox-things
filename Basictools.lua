-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- File storage setup for client persistence (if supported by executor)
local hasFileSystem = (readfile ~= nil) and (writefile ~= nil)
local filename = "saved_waypoints.json"
local waypoints = {}

local function loadWaypoints()
    if hasFileSystem then
        pcall(function()
            if isfile(filename) then
                waypoints = HttpService:JSONDecode(readfile(filename))
            end
        end)
    end
end

local function saveWaypoints()
    if hasFileSystem then
        pcall(function()
            writefile(filename, HttpService:JSONEncode(waypoints))
        end)
    end
end

-- Initialize waypoints
loadWaypoints()

-- Clean up any existing instances of this GUI
local parent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
if parent:FindFirstChild("WaypointManagerGUI") then
    parent:FindFirstChild("WaypointManagerGUI"):Destroy()
end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WaypointManagerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 500)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Dragging implementation
local dragToggle = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.08), {Position = position}):Play()
end

-- Header / Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0.5, 0)
TitleCover.Position = UDim2.new(0, 0, 0.5, 0)
TitleCover.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Waypoint & Character Manager"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

TitleBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if (input.UserInputState == Enum.UserInputState.End) then
                dragToggle = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if dragToggle then
            updateInput(input)
        end
    end
end)

----------------------------------------------------
-- SECTION 1: Waypoint Saving Interface
----------------------------------------------------
local Controls = Instance.new("Frame")
Controls.Size = UDim2.new(1, -20, 0, 80)
Controls.Position = UDim2.new(0, 10, 0, 50)
Controls.BackgroundTransparency = 1
Controls.Parent = MainFrame

local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(1, 0, 0, 35)
NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NameInput.BorderSizePixel = 0
NameInput.Text = ""
NameInput.PlaceholderText = "Waypoint name..."
NameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 14
NameInput.Parent = Controls

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = NameInput

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(1, 0, 0, 35)
SaveButton.Position = UDim2.new(0, 0, 0, 45)
SaveButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
SaveButton.BorderSizePixel = 0
SaveButton.Text = "Save Current Location"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Font = Enum.Font.SourceSansBold
SaveButton.TextSize = 14
SaveButton.Parent = Controls

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 5)
SaveCorner.Parent = SaveButton

----------------------------------------------------
-- SECTION 2: Character Controls (Speed, Fly, Reset)
----------------------------------------------------
local CharControls = Instance.new("Frame")
CharControls.Size = UDim2.new(1, -20, 0, 125)
CharControls.Position = UDim2.new(0, 10, 0, 140)
CharControls.BackgroundTransparency = 1
CharControls.Parent = MainFrame

-- Walkspeed Row
local WSFrame = Instance.new("Frame")
WSFrame.Size = UDim2.new(1, 0, 0, 35)
WSFrame.BackgroundTransparency = 1
WSFrame.Parent = CharControls

local WSLabel = Instance.new("TextLabel")
WSLabel.Size = UDim2.new(0.3, 0, 1, 0)
WSLabel.BackgroundTransparency = 1
WSLabel.Text = "Walk Speed:"
WSLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
WSLabel.Font = Enum.Font.SourceSansBold
WSLabel.TextSize = 14
WSLabel.TextXAlignment = Enum.TextXAlignment.Left
WSLabel.Parent = WSFrame

local WSInput = Instance.new("TextBox")
WSInput.Size = UDim2.new(0.3, -5, 1, 0)
WSInput.Position = UDim2.new(0.3, 5, 0, 0)
WSInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
WSInput.BorderSizePixel = 0
WSInput.Text = "16"
WSInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WSInput.Font = Enum.Font.SourceSans
WSInput.TextSize = 14
WSInput.Parent = WSFrame

local WSInputCorner = Instance.new("UICorner")
WSInputCorner.CornerRadius = UDim.new(0, 5)
WSInputCorner.Parent = WSInput

local WSButton = Instance.new("TextButton")
WSButton.Size = UDim2.new(0.4, -5, 1, 0)
WSButton.Position = UDim2.new(0.6, 5, 0, 0)
WSButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WSButton.BorderSizePixel = 0
WSButton.Text = "Set Speed"
WSButton.TextColor3 = Color3.fromRGB(255, 255, 255)
WSButton.Font = Enum.Font.SourceSansBold
WSButton.TextSize = 14
WSButton.Parent = WSFrame

local WSBtnCorner = Instance.new("UICorner")
WSBtnCorner.CornerRadius = UDim.new(0, 5)
WSBtnCorner.Parent = WSButton

-- Flight Row
local FlyFrame = Instance.new("Frame")
FlyFrame.Size = UDim2.new(1, 0, 0, 35)
FlyFrame.Position = UDim2.new(0, 0, 0, 45)
FlyFrame.BackgroundTransparency = 1
FlyFrame.Parent = CharControls

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0.5, -5, 1, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.BorderSizePixel = 0
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 14
FlyButton.Parent = FlyFrame

local FlyBtnCorner = Instance.new("UICorner")
FlyBtnCorner.CornerRadius = UDim.new(0, 5)
FlyBtnCorner.Parent = FlyButton

local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0.5, -5, 1, 0)
FlySpeedInput.Position = UDim2.new(0.5, 5, 0, 0)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlySpeedInput.BorderSizePixel = 0
FlySpeedInput.Text = "50"
FlySpeedInput.PlaceholderText = "Fly Speed"
FlySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedInput.Font = Enum.Font.SourceSans
FlySpeedInput.TextSize = 14
FlySpeedInput.Parent = FlyFrame

local FlySpeedCorner = Instance.new("UICorner")
FlySpeedCorner.CornerRadius = UDim.new(0, 5)
FlySpeedCorner.Parent = FlySpeedInput

-- Self Reset Row
local ResetButton = Instance.new("TextButton")
ResetButton.Size = UDim2.new(1, 0, 0, 35)
ResetButton.Position = UDim2.new(0, 0, 0, 90)
ResetButton.BackgroundColor3 = Color3.fromRGB(198, 40, 40)
ResetButton.BorderSizePixel = 0
ResetButton.Text = "Self Reset"
ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetButton.Font = Enum.Font.SourceSansBold
ResetButton.TextSize = 14
ResetButton.Parent = CharControls

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 5)
ResetCorner.Parent = ResetButton

----------------------------------------------------
-- SECTION 3: Waypoints Scroll List
----------------------------------------------------
local ListContainer = Instance.new("Frame")
ListContainer.Size = UDim2.new(1, -20, 1, -285)
ListContainer.Position = UDim2.new(0, 10, 0, 275)
ListContainer.BackgroundTransparency = 1
ListContainer.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = ListContainer

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = ScrollFrame

-- Populate waypoints dynamically
local function populateList()
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for name, data in pairs(waypoints) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Name = name
        ItemFrame.Size = UDim2.new(1, -6, 0, 38)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
        ItemFrame.BorderSizePixel = 0
        ItemFrame.Parent = ScrollFrame

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 4)
        ItemCorner.Parent = ItemFrame

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0.55, -5, 1, 0)
        NameLabel.Position = UDim2.new(0, 10, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        NameLabel.Font = Enum.Font.SourceSansBold
        NameLabel.TextSize = 14
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = ItemFrame

        local TPButton = Instance.new("TextButton")
        TPButton.Size = UDim2.new(0.2, -5, 0.7, 0)
        TPButton.Position = UDim2.new(0.55, 5, 0.15, 0)
        TPButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
        TPButton.BorderSizePixel = 0
        TPButton.Text = "Teleport"
        TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TPButton.Font = Enum.Font.SourceSansBold
        TPButton.TextSize = 11
        TPButton.Parent = ItemFrame

        local TPCorner = Instance.new("UICorner")
        TPCorner.CornerRadius = UDim.new(0, 3)
        TPCorner.Parent = TPButton

        local DelButton = Instance.new("TextButton")
        DelButton.Size = UDim2.new(0.2, -5, 0.7, 0)
        DelButton.Position = UDim2.new(0.75, 10, 0.15, 0)
        DelButton.BackgroundColor3 = Color3.fromRGB(198, 40, 40)
        DelButton.BorderSizePixel = 0
        DelButton.Text = "Delete"
        DelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DelButton.Font = Enum.Font.SourceSansBold
        DelButton.TextSize = 11
        DelButton.Parent = ItemFrame

        local DelCorner = Instance.new("UICorner")
        DelCorner.CornerRadius = UDim.new(0, 3)
        DelCorner.Parent = DelButton

        -- Teleport Action
        TPButton.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(data.x, data.y, data.z)
            end
        end)

        -- Delete Action
        DelButton.MouseButton1Click:Connect(function()
            waypoints[name] = nil
            saveWaypoints()
            populateList()
        end)
    end
end

-- Save Waypoint Input logic
SaveButton.MouseButton1Click:Connect(function()
    local text = NameInput.Text:match("^%s*(.-)%s*$")
    if text == "" then return end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        waypoints[text] = {x = pos.X, y = pos.Y, z = pos.Z}
        saveWaypoints()
        populateList()
        NameInput.Text = ""
    end
end)

populateList()

----------------------------------------------------
-- SECTION 4: Local Utilities Logic
----------------------------------------------------

-- Walk Speed Implementation
local currentWalkSpeed = 16

WSButton.MouseButton1Click:Connect(function()
    local inputVal = tonumber(WSInput.Text)
    if inputVal then
        currentWalkSpeed = inputVal
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = currentWalkSpeed
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = currentWalkSpeed
end)

-- Flight Implementation
local flying = false
local bv, bg

local function stopFlying()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

local function startFlying()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    flying = true
    hum.PlatformStand = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.CFrame = root.CFrame
    bg.Parent = root

    task.spawn(function()
        local camera = workspace.CurrentCamera
        while flying and char.Parent and root.Parent do
            task.wait()
            local flySpeed = tonumber(FlySpeedInput.Text) or 50
            local direction = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                bv.Velocity = direction.Unit * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = camera.CFrame
        end
        stopFlying()
    end)
end

local function toggleFly()
    if flying then
        stopFlying()
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        startFlying()
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    end
end

FlyButton.MouseButton1Click:Connect(toggleFly)

-- Self Reset Implementation
ResetButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        else
            char:BreakJoints()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    stopFlying()
    FlyButton.Text = "Fly: OFF"
    FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- Keyboard Toggle Visibility (Right Shift Key)
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
    end
end)
