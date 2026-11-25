if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	Players.ChildAdded:Wait()
	LocalPlayer = Players.LocalPlayer
end

local env = (getgenv and getgenv()) or _G
if env.__MobileFPSConns then
	for _, conn in ipairs(env.__MobileFPSConns) do
		pcall(conn.Disconnect, conn)
	end
end
local conns = {}
env.__MobileFPSConns = conns

local function trackConn(conn)
	conns[#conns + 1] = conn
	return conn
end

pcall(function()
	trackConn(LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end))
end)

local setfps = setfpscap or (syn and syn.set_fps_cap) or set_fps_cap
if setfps then
	pcall(setfps, 9999)
end

if setfflag then
	local fflags = {
		DFFlagTextureQualityOverrideEnabled = "True",
		DFIntTextureQualityOverride = "0",
		DFIntDebugFRMQualityLevelOverride = "1",
		FIntDebugForceMSAASamples = "1",
		DFFlagDebugPauseVoxelizer = "True",
		FIntFRMMaxGrassDistance = "0",
		FIntFRMMinGrassDistance = "0",
		FIntGrassMovementReducedMotionFactor = "0",
		DFIntCSGLevelOfDetailSwitchingDistance = "0",
		DFIntCSGLevelOfDetailSwitchingDistanceL12 = "0",
		DFIntCSGLevelOfDetailSwitchingDistanceL23 = "0",
		DFIntCSGLevelOfDetailSwitchingDistanceL34 = "0",
		FFlagDisablePostFx = "True",
		FIntRenderShadowIntensity = "0",
		FFlagFastGPULightCulling3 = "True",
		DFFlagDebugRenderForceTechnologyVoxel = "True"
	}
	for k, v in pairs(fflags) do
		if not getfflag or pcall(getfflag, k) then
			pcall(setfflag, k, v)
		end
	end
end

local function safeAssign(fn)
	pcall(fn)
end

safeAssign(function()
	local rs = settings().Rendering
	safeAssign(function() rs.QualityLevel = Enum.QualityLevel.Level01 end)
	safeAssign(function() rs.EditQualityLevel = Enum.QualityLevel.Level01 end)
	safeAssign(function() rs.EagerBulkExecution = false end)
	safeAssign(function() rs.EnableFRM = false end)
	safeAssign(function() rs.FrameRateManager = Enum.FramerateManagerMode.Off end)
	if not pcall(function() rs.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level09 end) then
		safeAssign(function() rs.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
	end
end)

safeAssign(function()
	local ps = settings():GetService("PhysicsSettings")
	safeAssign(function() ps.AllowSleep = true end)
	safeAssign(function() ps.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto end)
end)

safeAssign(function()
	local ugs = UserSettings():GetService("UserGameSettings")
	safeAssign(function() ugs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
	safeAssign(function() ugs.GraphicsOptimizationMode = Enum.GraphicsOptimizationMode.Performance end)
	safeAssign(function() ugs.GraphicsQualityLevel = 1 end)
	safeAssign(function() ugs.VignetteEnabled = false end)
	safeAssign(function() ugs.ReducedMotion = true end)
	safeAssign(function() ugs.FramerateCap = 9999 end)
end)

local function applyLightingDefaults()
	if Lighting.GlobalShadows then
		Lighting.GlobalShadows = false
	end
	if Lighting.ShadowSoftness ~= 0 then
		Lighting.ShadowSoftness = 0
	end
	if Lighting.EnvironmentDiffuseScale ~= 0 then
		Lighting.EnvironmentDiffuseScale = 0
	end
	if Lighting.EnvironmentSpecularScale ~= 0 then
		Lighting.EnvironmentSpecularScale = 0
	end
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	safeAssign(function() Lighting.Outlines = false end)
	if sethiddenproperty then
		pcall(sethiddenproperty, Lighting, "Technology", 2)
		pcall(sethiddenproperty, Lighting, "PrioritizeLightingQuality", false)
		pcall(function()
			sethiddenproperty(Lighting, "LightingStyle", Enum.LightingStyle.Soft)
		end)
	end
end

applyLightingDefaults()
trackConn(Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
	if Lighting.GlobalShadows then
		Lighting.GlobalShadows = false
	end
end))
trackConn(Lighting:GetPropertyChangedSignal("EnvironmentDiffuseScale"):Connect(function()
	if Lighting.EnvironmentDiffuseScale ~= 0 then
		Lighting.EnvironmentDiffuseScale = 0
	end
end))
trackConn(Lighting:GetPropertyChangedSignal("EnvironmentSpecularScale"):Connect(function()
	if Lighting.EnvironmentSpecularScale ~= 0 then
		Lighting.EnvironmentSpecularScale = 0
	end
end))

safeAssign(function() MaterialService.Use2022Materials = false end)
safeAssign(function() Workspace.ClientAnimatorThrottling = Enum.ClientAnimatorThrottlingMode.Enabled end)
safeAssign(function() Workspace.GlobalWind = Vector3.zero end)
if sethiddenproperty then
	pcall(function()
		sethiddenproperty(Workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Enabled)
	end)
end

local function optimizeTerrain(terrain)
	if not terrain then
		return
	end
	terrain.WaterWaveSize = 0
	terrain.WaterWaveSpeed = 0
	terrain.WaterReflectance = 0
	terrain.WaterTransparency = 0
	if sethiddenproperty then
		pcall(sethiddenproperty, terrain, "Decoration", false)
		pcall(sethiddenproperty, terrain, "GrassLength", 0.1)
	end
end

optimizeTerrain(Workspace:FindFirstChildOfClass("Terrain"))
trackConn(Workspace:GetPropertyChangedSignal("Terrain"):Connect(function()
	optimizeTerrain(Workspace.Terrain)
end))

local LocalChar = LocalPlayer.Character
trackConn(LocalPlayer.CharacterAdded:Connect(function(char)
	LocalChar = char
end))
trackConn(LocalPlayer.CharacterRemoving:Connect(function()
	LocalChar = nil
end))

local Camera = Workspace.CurrentCamera
local ignoreList = type(_G.Ignore) == "table" and _G.Ignore or nil

local function isIgnored(inst)
	if table.find(ignoreList, inst) then
		return true
	end
	for i = 1, #ignoreList do
		local target = ignoreList[i]
		if typeof(target) == "Instance" and inst:IsDescendantOf(target) then
			return true
		end
	end
	return false
end

local function isProtectedVisual(inst)
	if LocalChar and inst:IsDescendantOf(LocalChar) then
		return true
	end
	if Camera and inst:IsDescendantOf(Camera) then
		return true
	end
	if inst:FindFirstAncestorWhichIsA("BackpackItem") then
		return true
	end
	return false
end

local SmoothPlastic = Enum.Material.SmoothPlastic
local PerfFidelity = Enum.RenderFidelity.Performance
local SourceSans = Enum.Font.SourceSans
local ZeroRange = NumberRange.new(0)
local FullTransSeq = NumberSequence.new(1)
local okLOD, LowLOD = pcall(function() return Enum.LevelOfDetailSetting.Low end)
if not okLOD then
	LowLOD = nil
end

local rfMode
local function applyPerfFidelity(inst)
	if inst.RenderFidelity == PerfFidelity then
		return
	end
	if rfMode == nil then
		if pcall(function() inst.RenderFidelity = PerfFidelity end) then
			rfMode = 1
		elseif sethiddenproperty and pcall(sethiddenproperty, inst, "RenderFidelity", PerfFidelity) then
			rfMode = 2
		else
			rfMode = 0
		end
	elseif rfMode == 1 then
		inst.RenderFidelity = PerfFidelity
	elseif rfMode == 2 then
		pcall(sethiddenproperty, inst, "RenderFidelity", PerfFidelity)
	end
end

local function optimizeBasePart(inst)
	if inst.CastShadow then
		inst.CastShadow = false
	end
	if inst.Reflectance ~= 0 then
		inst.Reflectance = 0
	end
	if not isProtectedVisual(inst) then
		if inst.Material ~= SmoothPlastic then
			inst.Material = SmoothPlastic
		end
		if inst.MaterialVariant ~= "" then
			inst.MaterialVariant = ""
		end
	end
end

local function optimizeMeshPart(inst)
	if inst.CastShadow then
		inst.CastShadow = false
	end
	if inst.Reflectance ~= 0 then
		inst.Reflectance = 0
	end
	if not isProtectedVisual(inst) then
		if inst.Material ~= SmoothPlastic then
			inst.Material = SmoothPlastic
		end
		if inst.MaterialVariant ~= "" then
			inst.MaterialVariant = ""
		end
		applyPerfFidelity(inst)
		if inst.DoubleSided then
			inst.DoubleSided = false
		end
		if inst.TextureID ~= "" then
			inst.TextureID = ""
		end
	end
end

local function optimizePartOperation(inst)
	if inst.CastShadow then
		inst.CastShadow = false
	end
	if inst.Reflectance ~= 0 then
		inst.Reflectance = 0
	end
	if not isProtectedVisual(inst) then
		if inst.Material ~= SmoothPlastic then
			inst.Material = SmoothPlastic
		end
		if inst.MaterialVariant ~= "" then
			inst.MaterialVariant = ""
		end
		applyPerfFidelity(inst)
	end
end

local function optimizeDecal(inst)
	if not isProtectedVisual(inst) then
		if inst.Transparency ~= 1 then
			inst.Transparency = 1
		end
		if inst.Texture ~= "" then
			inst.Texture = ""
		end
	end
end

local function optimizeDataModelMesh(inst)
	if inst.ClassName == "SpecialMesh" and not isProtectedVisual(inst) then
		if inst.TextureId ~= "" then
			inst.TextureId = ""
		end
	end
	if LowLOD and sethiddenproperty then
		pcall(sethiddenproperty, inst, "LODX", LowLOD)
		pcall(sethiddenproperty, inst, "LODY", LowLOD)
	end
end

local function optimizeParticleEmitter(inst)
	inst.Enabled = false
	inst.Rate = 0
	inst.Lifetime = ZeroRange
	inst.LightEmission = 0
	inst.LightInfluence = 0
	inst:Clear()
end

local function optimizeTrail(inst)
	inst.Enabled = false
	inst.Lifetime = 0.01
	inst.LightEmission = 0
	inst.LightInfluence = 0
	inst:Clear()
end

local function optimizeBeam(inst)
	inst.Enabled = false
	inst.Segments = 1
	inst.Width0 = 0
	inst.Width1 = 0
	inst.LightEmission = 0
	inst.LightInfluence = 0
	inst.Transparency = FullTransSeq
	inst.Texture = ""
end

local function optimizeFire(inst)
	if inst.Enabled then
		inst.Enabled = false
	end
end

local function optimizeSmoke(inst)
	if inst.Enabled then
		inst.Enabled = false
	end
	if inst.Opacity ~= 0 then
		inst.Opacity = 0
	end
end

local function optimizeSparkles(inst)
	if inst.Enabled then
		inst.Enabled = false
	end
end

local function optimizeExplosion(inst)
	if inst.Visible then
		inst.Visible = false
	end
end

local function optimizeLight(inst)
	if inst.Shadows then
		inst.Shadows = false
	end
end

local function optimizeHighlight(inst)
	if inst.Enabled then
		inst.Enabled = false
	end
end

local function optimizeSurfaceAppearance(inst)
	if not isProtectedVisual(inst) then
		pcall(inst.Destroy, inst)
	end
end

local function optimizeWrapLayer(inst)
	if not isProtectedVisual(inst) and inst.Enabled then
		inst.Enabled = false
	end
end

local function optimizeShirt(inst)
	if not isProtectedVisual(inst) and inst.ShirtTemplate ~= "" then
		inst.ShirtTemplate = ""
	end
end

local function optimizePants(inst)
	if not isProtectedVisual(inst) and inst.PantsTemplate ~= "" then
		inst.PantsTemplate = ""
	end
end

local function optimizeShirtGraphic(inst)
	if not isProtectedVisual(inst) and inst.Graphic ~= "" then
		inst.Graphic = ""
	end
end

local function optimizeTextLabel(inst)
	inst.Font = SourceSans
	if inst.RichText then
		inst.RichText = false
	end
end

local function optimizePostEffect(inst)
	if inst.Enabled then
		inst.Enabled = false
	end
end

local function optimizeAtmosphere(inst)
	if inst.Density ~= 0 then
		inst.Density = 0
	end
	if inst.Glare ~= 0 then
		inst.Glare = 0
	end
	if inst.Haze ~= 0 then
		inst.Haze = 0
	end
end

local function optimizeClouds(inst)
	if inst.Enabled then
		inst.Enabled = false
	end
	if inst.Cover ~= 0 then
		inst.Cover = 0
	end
	if inst.Density ~= 0 then
		inst.Density = 0
	end
end

local function optimizeSky(inst)
	if inst.CelestialBodiesShown then
		inst.CelestialBodiesShown = false
	end
	if inst.StarCount ~= 0 then
		inst.StarCount = 0
	end
end

local function optimizeAttachment(inst)
	if inst.Visible then
		inst.Visible = false
	end
end

local Handlers = {
	Part = optimizeBasePart,
	WedgePart = optimizeBasePart,
	CornerWedgePart = optimizeBasePart,
	TrussPart = optimizeBasePart,
	SpawnLocation = optimizeBasePart,
	Seat = optimizeBasePart,
	VehicleSeat = optimizeBasePart,
	FlagStand = optimizeBasePart,
	SkateboardPlatform = optimizeBasePart,
	Platform = optimizeBasePart,
	MeshPart = optimizeMeshPart,
	UnionOperation = optimizePartOperation,
	NegateOperation = optimizePartOperation,
	IntersectOperation = optimizePartOperation,
	Terrain = optimizeTerrain,
	Decal = optimizeDecal,
	Texture = optimizeDecal,
	SpecialMesh = optimizeDataModelMesh,
	BlockMesh = optimizeDataModelMesh,
	CylinderMesh = optimizeDataModelMesh,
	ParticleEmitter = optimizeParticleEmitter,
	Trail = optimizeTrail,
	Beam = optimizeBeam,
	Fire = optimizeFire,
	Smoke = optimizeSmoke,
	Sparkles = optimizeSparkles,
	Explosion = optimizeExplosion,
	PointLight = optimizeLight,
	SpotLight = optimizeLight,
	SurfaceLight = optimizeLight,
	Highlight = optimizeHighlight,
	SurfaceAppearance = optimizeSurfaceAppearance,
	WrapLayer = optimizeWrapLayer,
	Shirt = optimizeShirt,
	Pants = optimizePants,
	ShirtGraphic = optimizeShirtGraphic,
	TextLabel = optimizeTextLabel,
	BloomEffect = optimizePostEffect,
	BlurEffect = optimizePostEffect,
	ColorCorrectionEffect = optimizePostEffect,
	SunRaysEffect = optimizePostEffect,
	DepthOfFieldEffect = optimizePostEffect,
	ColorGradingEffect = optimizePostEffect,
	Atmosphere = optimizeAtmosphere,
	Clouds = optimizeClouds,
	Sky = optimizeSky,
	Attachment = optimizeAttachment
}

local function optimizeInstance(inst)
	if not inst or not inst.Parent then
		return
	end
	if ignoreList and #ignoreList > 0 and isIgnored(inst) then
		return
	end
	local fn = Handlers[inst.ClassName]
	if fn then
		fn(inst)
	end
end

trackConn(Lighting.DescendantAdded:Connect(function(inst)
	task.defer(optimizeInstance, inst)
end))

trackConn(Workspace.DescendantAdded:Connect(function(inst)
	task.defer(optimizeInstance, inst)
end))

local cameraConn
local function hookCamera(cam)
	if cameraConn then
		cameraConn:Disconnect()
		cameraConn = nil
	end
	Camera = cam
	if not cam then
		return
	end
	for _, inst in ipairs(cam:GetDescendants()) do
		optimizeInstance(inst)
	end
	cameraConn = trackConn(cam.DescendantAdded:Connect(function(inst)
		task.defer(optimizeInstance, inst)
	end))
end

hookCamera(Workspace.CurrentCamera)
trackConn(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	hookCamera(Workspace.CurrentCamera)
end))

for _, inst in ipairs(Lighting:GetDescendants()) do
	optimizeInstance(inst)
end

task.spawn(function()
	local descendants = Workspace:GetDescendants()
	local total = #descendants
	local start = os.clock()
	for i = 1, total do
		optimizeInstance(descendants[i])
		if i % 256 == 0 and (os.clock() - start) >= 0.004 then
			task.wait()
			start = os.clock()
		end
	end
	pcall(collectgarbage, "collect")
end)
