local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ploppyspoofer",
   LoadingTitle = "version 0.9.4",
   LoadingSubtitle = "wiggleguy",
   ConfigurationSaving = { Enabled = true, FolderName = "ploppyconfigs", FileName = "version094" }
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local function StopAllEmotes()
    for _, track in ipairs(ActiveTracks) do track:Stop() end
    if ActiveSound then ActiveSound:Stop(); ActiveSound:Destroy() end
    table.clear(ActiveTracks)
end

UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and input.KeyCode == Enum.KeyCode.Space then StopAllEmotes() end
end)

task.spawn(function()
    while true do
        if NameLoop then
            pcall(function()
                lp.Name = TargetName
            end)
        end
        if DispLoop then
            pcall(function()
                lp.DisplayName = TargetDisp
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.DisplayName = TargetDisp
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- [[ DYNAMIC LIST GENERATION ]] --
local emoteList = {}
for _, mod in ipairs(ReplicatedStorage.Assets.Emotes:GetDescendants()) do
    if mod:IsA("ModuleScript") then table.insert(emoteList, mod.Name) end
end

local killerList = {}
local survList = {}
pcall(function()
    for _, k in ipairs(ReplicatedStorage.Assets.Killers:GetChildren()) do table.insert(killerList, k.Name) end
    for _, s in ipairs(ReplicatedStorage.Assets.Survivors:GetChildren()) do table.insert(survList, s.Name) end
end)

-- [[ TABS ]] --
local UnlocksTab = Window:CreateTab("Visual Unlock All", 4483362458)
local EmoteTab = Window:CreateTab("Emotes", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)
local SpooferTab = Window:CreateTab("Spoofers", 4483362458)

UnlocksTab:CreateSection("Unlock All")

UnlocksTab:CreateButton({
   Name = "Unlock All Killers",
   Callback = function()
      local pKillers = lp:WaitForChild("PlayerData"):WaitForChild("Purchased"):WaitForChild("Killers")
      local count = 0
      for _, name in ipairs(killerList) do
         if not pKillers:FindFirstChild(name) then
            Instance.new("StringValue", pKillers).Name = name; count = count + 1
         end
      end
      Rayfield:Notify({Title = "ploppyspoofer", Content = "unlocked " .. count .. " killers", Duration = 3})
   end,
})

UnlocksTab:CreateButton({
   Name = "Unlock All Survivors",
   Callback = function()
      local pSurv = lp:WaitForChild("PlayerData"):WaitForChild("Purchased"):WaitForChild("Survivors")
      local count = 0
      for _, name in ipairs(survList) do
         if not pSurv:FindFirstChild(name) then
            Instance.new("StringValue", pSurv).Name = name; count = count + 1
         end
      end
      Rayfield:Notify({Title = "ploppyspoofer", Content = "unlocked " .. count .. " survivors", Duration = 3})
   end,
})

UnlocksTab:CreateButton({
   Name = "unlock all",
   Callback = function()
      local purchased = lp:WaitForChild("PlayerData"):WaitForChild("Purchased"):WaitForChild("Skins")
      local skinsRoot = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skins")
      local count = 0
      for _, skin in ipairs(skinsRoot:GetDescendants()) do
         if (skin:IsA("Folder") or skin:IsA("Model")) and not purchased:FindFirstChild(skin.Name) then
            Instance.new("StringValue", purchased).Name = skin.Name; count = count + 1
         end
      end
      Rayfield:Notify({Title = "ploppyspoofer", Content = "unlocked " .. count .. " skins!", Duration = 3})
   end,
})

UnlocksTab:CreateSection("skin equip")

UnlocksTab:CreateDropdown({
   Name = "select killer/survivor",
   Options = (function() 
      local combined = {}
      for _,v in ipairs(killerList) do table.insert(combined, v) end
      for _,v in ipairs(survList) do table.insert(combined, v) end
      return combined
   end)(),
   Callback = function(o) currentEquipTarget = o[1] end,
})

UnlocksTab:CreateInput({
   Name = "OR type manually",
   PlaceholderText = "name here",
   Callback = function(t) currentEquipTarget = t end,
})

UnlocksTab:CreateInput({
   Name = "skin name",
   PlaceholderText = "e.g. Milestone100Guest1337",
   Callback = function(t) currentEquipSkin = t end,
})

UnlocksTab:CreateButton({
   Name = "Force Equip",
   Callback = function()
      local equipped = lp:WaitForChild("PlayerData"):WaitForChild("Equipped"):WaitForChild("Skins")
      local val = equipped:FindFirstChild(currentEquipTarget) or Instance.new("StringValue", equipped)
      val.Name = currentEquipTarget; val.Value = currentEquipSkin
      val:SetAttribute("UniqueId", "00000000-0000-0000-0000-000000000000")
      Rayfield:Notify({Title = "Success", Content = "Forced " .. currentEquipSkin .. " on " .. currentEquipTarget, Duration = 2})
   end,
})

EmoteTab:CreateSection("emotes")
EmoteTab:CreateButton({
   Name = "unlock every emote",
   Callback = function()
      local pEmotes = lp:WaitForChild("PlayerData"):WaitForChild("Purchased"):WaitForChild("Emotes")
      local count = 0
      for _, name in ipairs(emoteList) do
         if not pEmotes:FindFirstChild(name) then
            Instance.new("StringValue", pEmotes).Name = name; count = count + 1
         end
      end
      Rayfield:Notify({Title = "ploppyspoofer", Content = "unlocked " .. count .. " emotes", Duration = 3})
   end,
})

EmoteTab:CreateSection("emote player")
local emoteToPlay = ""

local function PlayEmoteAction(name)
    local module = ReplicatedStorage.Assets.Emotes:FindFirstChild(name, true)
    if module and module:IsA("ModuleScript") then
        local data = require(module)
        StopAllEmotes()
        local char = lp.Character or lp.CharacterAdded:Wait()
        local anims = type(data.AssetID) == "table" and data.AssetID or {data.AssetID}
        for _, id in ipairs(anims) do
            local a = Instance.new("Animation") a.AnimationId = id
            local t = char.Humanoid.Animator:LoadAnimation(a)
            t.Priority = Enum.AnimationPriority.Action4
            t.Looped = data.SFXProperties and data.SFXProperties.Looped or false
            t:Play() table.insert(ActiveTracks, t)
        end
        if data.SFX then
            ActiveSound = Instance.new("Sound", char.HumanoidRootPart)
            ActiveSound.SoundId = data.SFX
            if data.SFXProperties then for p,v in pairs(data.SFXProperties) do pcall(function() ActiveSound[p]=v end) end end
            ActiveSound:Play()
        end
    end
end

EmoteTab:CreateDropdown({
   Name = "select emote",
   Options = emoteList,
   Callback = function(o) emoteToPlay = o[1] end,
})

EmoteTab:CreateInput({
   Name = "OR type emote name",
   PlaceholderText = "e.g. #Tuffy",
   Callback = function(t) emoteToPlay = t end,
})

EmoteTab:CreateButton({
   Name = "play selected (space to stop)",
   Callback = function() PlayEmoteAction(emoteToPlay) end,
   Rayfield:Notify({Title = "ploppy spoofer", Content = "sucessfully playing", Duration = 2})
})

StatsTab:CreateSection("statistics")
local statsToChange = {
    ["Money"] = 67, ["NetWorth"] = 67, ["KillerChance"] = 67, 
    ["TimePlayed"] = 67, ["KillerWins"] = 67, ["Kills"] = 67,
    ["SurvivorWins"] = 67, ["ObjectivesCompleted"] = 67
}

for n, v in pairs(statsToChange) do
    StatsTab:CreateInput({
        Name = "Set " .. n, PlaceholderText = "Val: " .. v,
        Callback = function(t) 
            local s = lp:WaitForChild("PlayerData"):WaitForChild("Stats"):FindFirstChild(n, true)
            if s then s.Value = tonumber(t) or 0 end
        end
    })
end

SpooferTab:CreateSection("username spoofer (kicks in pubs)")

SpooferTab:CreateInput({
    Name = "target username",
    PlaceholderText = "username...",
    Callback = function(t) TargetName = t end
})
SpooferTab:CreateToggle({
    Name = "set username",
    CurrentValue = false,
    Callback = function(v) NameLoop = v end
})

SpooferTab:CreateInput({
    Name = "target displayname",
    PlaceholderText = "displayname...",
    Callback = function(t) TargetDisp = t end
})
SpooferTab:CreateToggle({
    Name = "set displayname",
    CurrentValue = false,
    Callback = function(v) DispLoop = v end
})

SpooferTab:CreateSection("spoofers")

SpooferTab:CreateButton({
    Name = "VIP giver (visual)",
    Callback = function()
        lp:SetAttribute("VIP", true)
        local pData = lp:FindFirstChild("PlayerData")
        if pData then
            local vVal = pData:FindFirstChild("VIP", true) or Instance.new("BoolValue", pData)
            vVal.Name = "VIP"
            vVal.Value = true
        end
        Rayfield:Notify({Title = "ploppyspoofer", Content = "u got vip now cool", Duration = 2})
    end
})

SpooferTab:CreateDropdown({
   Name = "device spoofer",
   Options = {"PC", "Mobile", "Console"},
   CurrentOption = {"PC"},
   Callback = function(o) lp:SetAttribute("Device", o[1]) end,
})

Rayfield:LoadConfiguration()
