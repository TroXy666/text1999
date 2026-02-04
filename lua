local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Sirius",
   LoadingTitle = "Подождите...",
   LoadingSubtitle = "Загрузка меню",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Sirius",
      FileName = "DefaultConfig"
   },
   KeySystem = false
})

-- ESP Variables
local ESP = {}
local BoxEnabled = false
local NameEnabled = false
local TracerEnabled = false
local TeamCheckEnabled = false
local BoxColor = Color3.fromRGB(255, 0, 0)
local NameColor = Color3.fromRGB(255, 255, 255)
local TracerColor = Color3.fromRGB(255, 0, 0)
local Transparency = 1
local Thickness = 2

-- Player Mods Variables
local Speed = 16
local JumpPower = 50
local InfiniteJumpEnabled = false

-- Misc
local FPSBoostEnabled = false

-- ESP Functions
local function CreateESP(plr)
   local data = {}
   data.Box = Drawing.new("Square")
   data.Box.Filled = false
   data.Box.Thickness = Thickness
   data.Box.Transparency = Transparency
   data.Box.Color = BoxColor
   data.Box.Visible = false

   data.Name = Drawing.new("Text")
   data.Name.Size = 16
   data.Name.Center = true
   data.Name.Outline = true
   data.Name.Font = 2
   data.Name.Color = NameColor
   data.Name.Transparency = Transparency
   data.Name.Visible = false

   data.Tracer = Drawing.new("Line")
   data.Tracer.Thickness = Thickness
   data.Tracer.Transparency = Transparency
   data.Tracer.Color = TracerColor
   data.Tracer.Visible = false

   ESP[plr] = data
end

local function RemoveESP(plr)
   if ESP[plr] then
      ESP[plr].Box:Remove()
      ESP[plr].Name:Remove()
      ESP[plr].Tracer:Remove()
      ESP[plr] = nil
   end
end

local function UpdateESP()
   for Player, Drawings in pairs(ESP) do
      local Character = Player.Character
      if not Character then
         Drawings.Box.Visible = false
         Drawings.Name.Visible = false
         Drawings.Tracer.Visible = false
         continue
      end
      local RootPart = Character:FindFirstChild("HumanoidRootPart")
      local Humanoid = Character:FindFirstChild("Humanoid")
      if not RootPart or not Humanoid then
         Drawings.Box.Visible = false
         Drawings.Name.Visible = false
         Drawings.Tracer.Visible = false
         continue
      end
      if TeamCheckEnabled and Player.Team == LocalPlayer.Team and Player.Team then
         Drawings.Box.Visible = false
         Drawings.Name.Visible = false
         Drawings.Tracer.Visible = false
         continue
      end
      local RootPosition, OnScreen = camera:WorldToViewportPoint(RootPart.Position)
      if not OnScreen then
         Drawings.Box.Visible = false
         Drawings.Name.Visible = false
         Drawings.Tracer.Visible = false
         continue
      end
      -- Box calculation
      local TopOfHead = camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, (Humanoid.HipHeight or 0) + 1, 0))
      local BottomOfFeet = camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 4, 0))
      local Height = math.clamp(math.abs(TopOfHead.Y - BottomOfFeet.Y), 2, math.huge)
      local Width = Height / 2.2
      local BoxPosX = ((TopOfHead.X + BottomOfFeet.X) / 2) - (Width / 2)
      local BoxPosY = TopOfHead.Y
      Drawings.Box.Position = Vector2.new(BoxPosX, BoxPosY)
      Drawings.Box.Size = Vector2.new(Width, Height)
      -- Name
      local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      local dist = lRoot and math.floor((lRoot.Position - RootPart.Position).Magnitude) or 0
      Drawings.Name.Text = Player.DisplayName .. " [" .. dist .. "]"
      Drawings.Name.Position = Vector2.new(RootPosition.X, BoxPosY - 20)
      -- Tracer
      Drawings.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
      Drawings.Tracer.To = Vector2.new(RootPosition.X, RootPosition.Y)
      -- Visibility
      Drawings.Box.Visible = BoxEnabled
      Drawings.Name.Visible = NameEnabled
      Drawings.Tracer.Visible = TracerEnabled
   end
end

-- Player Mods Functions
local function ApplyWalkSpeed()
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Humanoid") then
      char.Humanoid.WalkSpeed = Speed
   end
end

local function ApplyJumpPower()
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Humanoid") then
      char.Humanoid.JumpPower = JumpPower
   end
end

-- UI Creation
local ESPTab = Window:CreateTab("ESP")
ESPTab:CreateSection("ESP для игроков")

local TeamCheckToggle = ESPTab:CreateToggle({
   Name = "Проверка команды (только враги)",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
      TeamCheckEnabled = Value
   end
})

local BoxToggle = ESPTab:CreateToggle({
   Name = "Коробка (Box)",
   CurrentValue = false,
   Flag = "BoxESP",
   Callback = function(Value)
      BoxEnabled = Value
   end
})

local NameToggle = ESPTab:CreateToggle({
   Name = "Имя + дистанция",
   CurrentValue = false,
   Flag = "NameESP",
   Callback = function(Value)
      NameEnabled = Value
   end
})

local TracerToggle = ESPTab:CreateToggle({
   Name = "Трейсер",
   CurrentValue = false,
   Flag = "TracerESP",
   Callback = function(Value)
      TracerEnabled = Value
   end
})

ESPTab:CreateSection("Настройки")

local BoxColorPicker = ESPTab:CreateColorPicker({
   Name = "Цвет коробки",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "BoxColor",
   Callback = function(Value)
      BoxColor = Value
      for _, Drawings in pairs(ESP) do
         if Drawings.Box then Drawings.Box.Color = Value end
      end
   end
})

local NameColorPicker = ESPTab:CreateColorPicker({
   Name = "Цвет имени",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "NameColor",
   Callback = function(Value)
      NameColor = Value
      for _, Drawings in pairs(ESP) do
         if Drawings.Name then Drawings.Name.Color = Value end
      end
   end
})

local TracerColorPicker = ESPTab:CreateColorPicker({
   Name = "Цвет трейсера",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "TracerColor",
   Callback = function(Value)
      TracerColor = Value
      for _, Drawings in pairs(ESP) do
         if Drawings.Tracer then Drawings.Tracer.Color = Value end
      end
   end
})

local TransSlider = ESPTab:CreateSlider({
   Name = "Прозрачность",
   Range = {0, 1},
   Increment = 0.01,
   CurrentValue = 1,
   Flag = "Transparency",
   Callback = function(Value)
      Transparency = Value
      for _, Drawings in pairs(ESP) do
         Drawings.Box.Transparency = Value
         Drawings.Name.Transparency = Value
         Drawings.Tracer.Transparency = Value
      end
   end
})

local ThickSlider = ESPTab:CreateSlider({
   Name = "Толщина линий",
   Range = {1, 5},
   Increment = 0.1,
   CurrentValue = 2,
   Flag = "Thickness",
   Callback = function(Value)
      Thickness = Value
      for _, Drawings in pairs(ESP) do
         Drawings.Box.Thickness = Value
         Drawings.Tracer.Thickness = Value
      end
   end
})

local PlayerTab = Window:CreateTab("Игрок")
PlayerTab:CreateSection("Характеристики движения")

local SpeedSlider = PlayerTab:CreateSlider({
   Name = "Скорость ходьбы",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      Speed = Value
      ApplyWalkSpeed()
   end
})

local JumpSlider = PlayerTab:CreateSlider({
   Name = "Сила прыжка",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      JumpPower = Value
      ApplyJumpPower()
   end
})

local InfJumpToggle = PlayerTab:CreateToggle({
   Name = "Бесконечный прыжок",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      InfiniteJumpEnabled = Value
   end
})

local MiscTab = Window:CreateTab("Прочее")
MiscTab:CreateSection("Разное")

local FPSBoostToggle = MiscTab:CreateToggle({
   Name = "Бустер FPS",
   CurrentValue = false,
   Flag = "FPSBoost",
   Callback = function(Value)
      FPSBoostEnabled = Value
      if Value then
         settings().Rendering.QualityLevel = "Level01"
         for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") then
               v.Enabled = false
            end
         end
         Lighting.GlobalShadows = false
         Lighting.FogEnd = math.huge
         Lighting.Brightness = 2
      end
   end
})

MiscTab:CreateButton({
   Name = "Переподключиться к серверу",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end
})

-- Load Flags and Init
BoxEnabled = Rayfield.Flags.BoxESP or false
NameEnabled = Rayfield.Flags.NameESP or false
TracerEnabled = Rayfield.Flags.TracerESP or false
TeamCheckEnabled = Rayfield.Flags.TeamCheck or false
BoxColor = Rayfield.Flags.BoxColor or Color3.fromRGB(255, 0, 0)
NameColor = Rayfield.Flags.NameColor or Color3.fromRGB(255, 255, 255)
TracerColor = Rayfield.Flags.TracerColor or Color3.fromRGB(255, 0, 0)
Transparency = Rayfield.Flags.Transparency or 1
Thickness = Rayfield.Flags.Thickness or 2
Speed = Rayfield.Flags.WalkSpeed or 16
JumpPower = Rayfield.Flags.JumpPower or 50
InfiniteJumpEnabled = Rayfield.Flags.InfiniteJump or false
FPSBoostEnabled = Rayfield.Flags.FPSBoost or false

-- Apply initial
ApplyWalkSpeed()
ApplyJumpPower()
if FPSBoostEnabled then
   settings().Rendering.QualityLevel = "Level01"
   for _, v in pairs(Lighting:GetChildren()) do
      if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") then
         v.Enabled = false
      end
   end
   Lighting.GlobalShadows = false
   Lighting.FogEnd = math.huge
   Lighting.Brightness = 2
end

-- ESP Init
for _, player in ipairs(Players:GetPlayers()) do
   if player ~= LocalPlayer then
      CreateESP(player)
   end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
RunService.Heartbeat:Connect(UpdateESP)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
   if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   end
end)

-- Auto apply on respawn
LocalPlayer.CharacterAdded:Connect(function()
   task.wait(0.1)
   ApplyWalkSpeed()
   ApplyJumpPower()
end)

Rayfield:Notify({
   Title = "Sirius Menu",
   Content = "Меню загружено! Первый таб — ESP.",
   Duration = 4,
   Image = 4483362458
})
