if not game:IsLoaded() then game.Loaded:Wait() end


local LIBRARY_URL = "https://raw.githubusercontent.com/TRcalled/TRFpsBooster/main/Lib.lua"

local success, Library = pcall(function()
    return loadstring(game:HttpGet(LIBRARY_URL))()
end)

if not success or not Library then
    warn("[FPS Engine] Failed to fetch Library from URL. Falling back to local/debug error: " .. tostring(Library))
    return
end

-- ==========================================
-- 2. SERVICES & REFERENCES
-- ==========================================
local Players         = game:GetService("Players")
local Lighting        = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local Workspace       = game:GetService("Workspace")
local VirtualUser     = game:GetService("VirtualUser")

local ME = Players.LocalPlayer

-- ==========================================
-- 3. CONFIGURATION
-- ==========================================
_G.Ignore            = _G.Ignore or {}
_G.SendNotifications = _G.SendNotifications == nil and true or _G.SendNotifications
_G.ConsoleLogs       = _G.ConsoleLogs == nil and false or _G.ConsoleLogs

_G.Settings = {
    Players = {
        ["Ignore Me"]     = true,
        ["Ignore Others"] = true,
        ["Ignore Tools"]  = true
    },
    Meshes = {
        NoMesh    = false,
        NoTexture = true,
        Destroy   = false
    },
    Images = {
        Invisible = true,
        Destroy   = false
    },
    Explosions = {
        Smaller   = true,
        Invisible = true,
        Destroy   = false
    },
    Particles = {
        Invisible = true,
        Destroy   = true
    },
    TextLabels = {
        LowerQuality = true,
        Invisible    = false,
        Destroy      = false
    },
    MeshParts = {
        LowerQuality = true,
        Invisible    = false,
        NoTexture    = true,
        NoMesh       = false,
        Destroy      = false
    },
    Other = {
        ["FPS Cap"]            = true,
        ["No Camera Effects"]  = true,
        ["No Clothes"]         = false,
        ["Low Water Graphics"] = true,
        ["No Shadows"]         = true,
        ["Low Rendering"]      = true,
        ["Low Quality Parts"]  = true,
        ["Low Quality Models"] = true,
        ["Reset Materials"]    = true,
        ["ClearNilInstances"]  = false
    }
}

local SensitiveDefinitions = {
    {
        name = "Meshes: Destroy",
        reason = "Deletes SpecialMesh instances entirely; may break interactive props.",
        check = function(s) return s.Meshes.Destroy end
    },
    {
        name = "Meshes: No Mesh",
        reason = "Hides mesh geometry; models will turn invisible.",
        check = function(s) return s.Meshes.NoMesh end
    },
    {
        name = "MeshParts: Destroy",
        reason = "Permanently removes MeshParts. Can break world collision and terrain.",
        check = function(s) return s.MeshParts.Destroy end
    },
    {
        name = "MeshParts: No Mesh",
        reason = "Empties Mesh IDs; structural objects will turn invisible.",
        check = function(s) return s.MeshParts.NoMesh end
    },
    {
        name = "Images: Destroy",
        reason = "Permanently strips 2D textures and decals for the session.",
        check = function(s) return s.Images.Destroy end
    },
    {
        name = "TextLabels: Destroy",
        reason = "Removes in-game overhead labels, prompts, and world billboard text.",
        check = function(s) return s.TextLabels.Destroy end
    },
    {
        name = "No Clothes",
        reason = "Removes clothing items and surface wraps from avatars.",
        check = function(s) return s.Other["No Clothes"] end
    },
    {
        name = "Clear Nil Instances",
        reason = "Forces memory sweep on unparented items; may break external scripts.",
        check = function(s) return s.Other.ClearNilInstances end
    }
}

local BadClasses = {
    "ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles", "PostEffect", 
    "BloomEffect", "BlurEffect", "ColorCorrectionEffect", "SunRaysEffect", "DepthOfFieldEffect"
}

local ValidTargetClasses = {
    Part = true, MeshPart = true, Decal = true, Texture = true, SpecialMesh = true, BlockMesh = true, 
    CylinderMesh = true, ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, 
    Explosion = true, ShirtGraphic = true, Clothing = true, SurfaceAppearance = true, BaseWrap = true, 
    TextLabel = true, Model = true
}

-- ==========================================
-- 4. ANTI-AFK
-- ==========================================
local function StartAntiAFK()
    local success, err = pcall(function()
        ME.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            if _G.ConsoleLogs then warn("[Anti-AFK] Prevented idle disconnect.") end
        end)
    end)
    if success then
        Library:Notify("Anti-AFK Active: 20-min idle kick protected.", 3)
    else
        Library:Notify("Anti-AFK hook warning: " .. tostring(err), 3)
    end
end

-- ==========================================
-- 5. OPTIMIZER 
-- ==========================================
local function PartOfCharacter(Inst)
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Inst:IsDescendantOf(v.Character) then return true end
    end
    return false
end

local function DescendantOfIgnore(Inst)
    for _, v in ipairs(_G.Ignore) do
        if Inst:IsDescendantOf(v) then return true end
    end
    return false
end

local function CheckIfBad(Inst)
    if not Inst or not Inst.Parent or Inst:IsDescendantOf(Players) then return end
    
    local s = _G.Settings
    if s.Players["Ignore Others"] and PartOfCharacter(Inst) then return end
    if s.Players["Ignore Me"] and ME.Character and Inst:IsDescendantOf(ME.Character) then return end
    if s.Players["Ignore Tools"] and (Inst:IsA("BackpackItem") or Inst:FindFirstAncestorWhichIsA("BackpackItem")) then return end
    if #_G.Ignore > 0 and (table.find(_G.Ignore, Inst) or DescendantOfIgnore(Inst)) then return end

    if Inst:IsA("DataModelMesh") then
        if Inst:IsA("SpecialMesh") then
            if s.Meshes.NoMesh then Inst.MeshId = "" end
            if s.Meshes.NoTexture then Inst.TextureId = "" end
        end
        if s.Meshes.Destroy then Inst:Destroy() end

    elseif Inst:IsA("FaceInstance") or Inst:IsA("Decal") or Inst:IsA("Texture") then
        if s.Images.Invisible then Inst.Transparency = 1 end
        if s.Images.Destroy then Inst:Destroy() end

    elseif Inst:IsA("ShirtGraphic") then
        if s.Images.Invisible then Inst.Graphic = "" end
        if s.Images.Destroy then Inst:Destroy() end

    elseif table.find(BadClasses, Inst.ClassName) then
        if s.Particles.Invisible then Inst.Enabled = false end
        if s.Particles.Destroy or s.Other["No Camera Effects"] then Inst:Destroy() end

    elseif Inst:IsA("Explosion") then
        if s.Explosions.Smaller then Inst.BlastPressure, Inst.BlastRadius = 1, 1 end
        if s.Explosions.Invisible then Inst.Visible = false end
        if s.Explosions.Destroy then Inst:Destroy() end

    elseif Inst:IsA("Clothing") or Inst:IsA("SurfaceAppearance") or Inst:IsA("BaseWrap") then
        if s.Other["No Clothes"] then Inst:Destroy() end

    elseif Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
        if s.Other["Low Quality Parts"] then
            Inst.Material = Enum.Material.SmoothPlastic
            Inst.Reflectance = 0
        end

    elseif Inst:IsA("TextLabel") and Inst:IsDescendantOf(Workspace) then
        if s.TextLabels.LowerQuality then
            Inst.Font = Enum.Font.SourceSans
            Inst.TextScaled = false
            Inst.RichText = false
        end
        if s.TextLabels.Invisible then Inst.Visible = false end
        if s.TextLabels.Destroy then Inst:Destroy() end

    elseif Inst:IsA("Model") then
        if s.Other["Low Quality Models"] then
            pcall(function() Inst.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled end)
        end

    elseif Inst:IsA("MeshPart") then
        if s.MeshParts.LowerQuality then
            Inst.Reflectance = 0
            Inst.Material = Enum.Material.SmoothPlastic
        end
        if s.MeshParts.Invisible then Inst.Transparency = 1 end
        if s.MeshParts.NoTexture then Inst.TextureID = "" end
        if s.MeshParts.NoMesh then Inst.MeshId = "" end
        if s.MeshParts.Destroy then Inst:Destroy() end
    end
end

local function RunOptimizer()
    -- Apply Engine Environment Defaults
    task.spawn(function()
        local s = _G.Settings.Other
        if s["Low Water Graphics"] then
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize, terrain.WaterWaveSpeed = 0, 0
                terrain.WaterReflectance, terrain.WaterTransparency = 0, 0
                if sethiddenproperty then pcall(sethiddenproperty, terrain, "Decoration", false) end
            end
        end

        if s["No Shadows"] then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            Lighting.Brightness = 2
            if sethiddenproperty then pcall(sethiddenproperty, Lighting, "Technology", 2) end
        end

        if s["Low Rendering"] then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end

        if s["Reset Materials"] then
            MaterialService.Use2022Materials = false
        end

        if s["FPS Cap"] and setfpscap then
            setfpscap(1000000)
        end
    end)

    -- Dynamic Added Listener
    Workspace.DescendantAdded:Connect(function(Inst)
        if ValidTargetClasses[Inst.ClassName] or Inst:IsA("BasePart") or Inst:IsA("DataModelMesh") then
            task.defer(CheckIfBad, Inst)
        end
    end)

    -- Nil Instance Sweeper
    if _G.Settings.Other.ClearNilInstances and getnilinstances then
        task.spawn(function()
            while task.wait(60) do
                for _, inst in ipairs(getnilinstances()) do
                    pcall(inst.Destroy, inst)
                end
            end
        end)
    end

    -- Batch Processing with Progress UI
    local ProgressBar = Library:CreateProgressBar("Optimizing World Assets...")
    local descendants = Workspace:GetDescendants()
    local totalDescendants = #descendants

    task.spawn(function()
        local batchSize = 1500
        for i, target in ipairs(descendants) do
            if ValidTargetClasses[target.ClassName] or target:IsA("BasePart") or target:IsA("DataModelMesh") then
                CheckIfBad(target)
            end
            
            if i % batchSize == 0 or i == totalDescendants then
                local pct = math.floor((i / totalDescendants) * 100)
                ProgressBar:Update(i / totalDescendants, "Optimizing World Assets... " .. pct .. "%")
                task.wait()
            end
        end

        ProgressBar:Update(1, "Optimization Complete! 100%")
        task.wait(0.8)
        ProgressBar:Destroy()

        Library:Notify("Ultimate FPS Engine Active & Protected!", 4)
    end)
end

-- ==========================================
-- 6. UI CONSTRUCTION & RUN
-- ==========================================
local Window = Library:CreateWindow({
    Title = "ENGINE CONFIGURATOR",
    Subtitle = "Configure FPS booster settings before activating Anti-AFK"
})

-- Toggles List
local Toggles = {}

Toggles["Ignore Me"] = Window:AddToggle({
    Title = "Safe: Ignore Local Character",
    Tip = "Preserves your own avatar meshes, textures, & accessories.",
    Default = _G.Settings.Players["Ignore Me"],
    Callback = function(val) _G.Settings.Players["Ignore Me"] = val end
})

Toggles["Ignore Others"] = Window:AddToggle({
    Title = "Safe: Ignore Other Players",
    Tip = "Keeps other players' characters looking fully normal.",
    Default = _G.Settings.Players["Ignore Others"],
    Callback = function(val) _G.Settings.Players["Ignore Others"] = val end
})

Toggles["Ignore Tools"] = Window:AddToggle({
    Title = "Safe: Ignore Equipped Tools",
    Tip = "Prevents weapon/tool visual glitches.",
    Default = _G.Settings.Players["Ignore Tools"],
    Callback = function(val) _G.Settings.Players["Ignore Tools"] = val end
})

Toggles["SpecialMesh Textures"] = Window:AddToggle({
    Title = "Strip SpecialMesh Textures",
    Tip = "Clears texture IDs from 3D models for big VRAM savings.",
    Default = _G.Settings.Meshes.NoTexture,
    Callback = function(val) _G.Settings.Meshes.NoTexture = val end
})

Toggles["Invisible Decals"] = Window:AddToggle({
    Title = "Make Decals/Images Invisible",
    Tip = "Sets 2D surface decals and billboard images to invisible.",
    Default = _G.Settings.Images.Invisible,
    Callback = function(val) _G.Settings.Images.Invisible = val end
})

Toggles["Destroy Images"] = Window:AddToggle({
    Title = "Delete 2D Images & Textures",
    Tip = "Permanently deletes texture assets for heavy memory drops.",
    Default = _G.Settings.Images.Destroy,
    Callback = function(val) _G.Settings.Images.Destroy = val end
})

Toggles["Disable Particles"] = Window:AddToggle({
    Title = "Disable Particle Emitters",
    Tip = "Turns off fire, sparks, smoke, and trails.",
    Default = _G.Settings.Particles.Invisible,
    Callback = function(val) _G.Settings.Particles.Invisible = val end
})

Toggles["Destroy Particles"] = Window:AddToggle({
    Title = "Delete Particle Objects",
    Tip = "Completely removes particle instances from game memory.",
    Default = _G.Settings.Particles.Destroy,
    Callback = function(val) _G.Settings.Particles.Destroy = val end
})

Toggles["Optimize MeshParts"] = Window:AddToggle({
    Title = "Optimize MeshParts",
    Tip = "Forces SmoothPlastic material and disables reflection.",
    Default = _G.Settings.MeshParts.LowerQuality,
    Callback = function(val) _G.Settings.MeshParts.LowerQuality = val end
})

Toggles["No Shadows"] = Window:AddToggle({
    Title = "Disable Shadows & Fog",
    Tip = "Disables global lighting shadows and extends fog distance.",
    Default = _G.Settings.Other["No Shadows"],
    Callback = function(val) _G.Settings.Other["No Shadows"] = val end
})

Toggles["Low Water Graphics"] = Window:AddToggle({
    Title = "Flat Water Graphics",
    Tip = "Removes water waves, reflections, and water transparency.",
    Default = _G.Settings.Other["Low Water Graphics"],
    Callback = function(val) _G.Settings.Other["Low Water Graphics"] = val end
})

Toggles["FPS Cap"] = Window:AddToggle({
    Title = "Unlock FPS Limit",
    Tip = "Uncaps framerate past standard engine limits.",
    Default = _G.Settings.Other["FPS Cap"],
    Callback = function(val) _G.Settings.Other["FPS Cap"] = val end
})

Toggles["Destroy MeshParts"] = Window:AddToggle({
    Title = "Destroy MeshParts (Aggressive)",
    Tip = "Permanently deletes MeshParts. May remove physical map props.",
    Default = _G.Settings.MeshParts.Destroy,
    Callback = function(val) _G.Settings.MeshParts.Destroy = val end
})

Toggles["No Clothes"] = Window:AddToggle({
    Title = "No Player Clothes",
    Tip = "Strips avatar shirts, pants, and 3D layered clothing.",
    Default = _G.Settings.Other["No Clothes"],
    Callback = function(val) _G.Settings.Other["No Clothes"] = val end
})

-- Presets
Window:AddPreset("Balanced (Safe)", function()
    Toggles["SpecialMesh Textures"]:Set(true)
    Toggles["Invisible Decals"]:Set(true)
    Toggles["Destroy Images"]:Set(false)
    Toggles["Disable Particles"]:Set(true)
    Toggles["Destroy Particles"]:Set(false)
    Toggles["Optimize MeshParts"]:Set(true)
    Toggles["Destroy MeshParts"]:Set(false)
    Toggles["No Clothes"]:Set(false)
    Toggles["No Shadows"]:Set(true)
    Toggles["Low Water Graphics"]:Set(true)
    Toggles["FPS Cap"]:Set(true)
end)

Window:AddPreset("Potato Mode", function()
    Toggles["SpecialMesh Textures"]:Set(true)
    Toggles["Invisible Decals"]:Set(true)
    Toggles["Destroy Images"]:Set(true)
    Toggles["Disable Particles"]:Set(true)
    Toggles["Destroy Particles"]:Set(true)
    Toggles["Optimize MeshParts"]:Set(true)
    Toggles["Destroy MeshParts"]:Set(false)
    Toggles["No Clothes"]:Set(true)
    Toggles["No Shadows"]:Set(true)
    Toggles["Low Water Graphics"]:Set(true)
    Toggles["FPS Cap"]:Set(true)
end)

-- Proceed Handler
Window:OnProceed(function()
    local detectedSensitive = {}
    for _, def in ipairs(SensitiveDefinitions) do
        if def.check(_G.Settings) then
            table.insert(detectedSensitive, {name = def.name, reason = def.reason})
        end
    end

    local function StartAll()
        Window:Close(function()
            StartAntiAFK()
            RunOptimizer()
        end)
    end

    if #detectedSensitive > 0 then
        Window:ShowWarning(detectedSensitive, function()
        end, function()
            StartAll()
        end)
    else
        StartAll()
    end
end)
