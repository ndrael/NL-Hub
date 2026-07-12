local Logic = {}

-- ============================================
-- ESP PLAYER LOGIC
-- ============================================

local ESPEnabled = {
    Survivors = false,
    Killer = false,
    Spectator = false,
}

local ESPDrawings = {}
local ESPHighlights = {}

-- Function untuk get role dari player (try multiple methods)
local function GetPlayerRole(player)
    if not player or not player.Character then return nil end
    
    local character = player.Character
    
    -- Method 1: Check player.Team
    if player.Team then
        local teamName = player.Team.Name
        if teamName == "Survivors" then return "Survivors"
        elseif teamName == "Killer" then return "Killer"
        elseif teamName == "Spectator" then return "Spectator"
        end
    end
    
    -- Method 2: Check character Humanoid Team
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Team then
        local teamName = humanoid.Team.Name
        if teamName == "Survivors" then return "Survivors"
        elseif teamName == "Killer" then return "Killer"
        elseif teamName == "Spectator" then return "Spectator"
        end
    end
    
    -- Method 3: Check custom Role value di character
    local roleValue = character:FindFirstChild("Role")
    if roleValue and roleValue:IsA("StringValue") then
        local roleName = roleValue.Value
        if roleName == "Survivors" then return "Survivors"
        elseif roleName == "Killer" then return "Killer"
        elseif roleName == "Spectator" then return "Spectator"
        end
    end
    
    -- Method 4: Check custom attribute
    local success, roleAttr = pcall(function()
        return character:GetAttribute("Role")
    end)
    if success and roleAttr then
        if roleAttr == "Survivors" then return "Survivors"
        elseif roleAttr == "Killer" then return "Killer"
        elseif roleAttr == "Spectator" then return "Spectator"
        end
    end
    
    return nil
end

-- Function untuk get distance antara 2 player
local function GetDistance(player1, player2)
    local pos1 = player1.Character and player1.Character:FindFirstChild("HumanoidRootPart")
    local pos2 = player2.Character and player2.Character:FindFirstChild("HumanoidRootPart")
    
    if pos1 and pos2 then
        return (pos1.Position - pos2.Position).Magnitude
    end
    return 0
end

-- Function untuk create body highlight (75% opacity)
local function CreateBodyHighlight(character, teamName)
    local teamColors = {
        Survivors = Color3.fromRGB(0, 100, 255),      -- Blue
        Killer = Color3.fromRGB(255, 0, 0),           -- Red
        Spectator = Color3.fromRGB(200, 200, 200),    -- Gray/White
    }
    
    local color = teamColors[teamName] or Color3.fromRGB(255, 255, 255)
    
    -- Create highlight untuk character
    if not character:FindFirstChild("ESPHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.25  -- 75% opacity (0.25 = 75% visible)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        
        return highlight
    end
    
    return character:FindFirstChild("ESPHighlight")
end

-- Function untuk create ESP text
local function CreateESPText(player, teamName)
    local character = player.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    -- Color per team
    local teamColors = {
        Survivors = Color3.fromRGB(0, 100, 255),      -- Blue
        Killer = Color3.fromRGB(255, 0, 0),           -- Red
        Spectator = Color3.fromRGB(200, 200, 200),    -- Gray/White
    }
    
    local textColor = teamColors[teamName] or Color3.fromRGB(255, 255, 255)
    
    -- Create drawing
    local drawing = Drawing.new("Text")
    drawing.Size = 18
    drawing.Color = textColor
    drawing.Outline = true
    drawing.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawing.Font = 2
    drawing.Visible = true
    
    return drawing
end

-- Main ESP Loop - Realtime update
local espLoop = game:GetService("RunService").RenderStepped:Connect(function()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return end
    
    local camera = workspace.CurrentCamera
    
    -- Clear old drawings
    for _, drawing in pairs(ESPDrawings) do
        drawing:Remove()
    end
    ESPDrawings = {}
    
    -- Loop semua players
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            local roleName = GetPlayerRole(player)
            
            if roleName then
                local character = player.Character
                if character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        -- Check apakah ESP untuk role ini aktif
                        if ESPEnabled[roleName] then
                            local distance = GetDistance(localPlayer, player)
                            
                            -- Create body highlight
                            CreateBodyHighlight(character, roleName)
                            
                            -- Create text
                            local drawing = CreateESPText(player, roleName)
                            if drawing then
                                -- Format text: Username ([Distance])
                                drawing.Text = player.Name .. " ([" .. math.floor(distance) .. "])"
                                
                                -- Get screen position (di atas kepala)
                                local screenPos, onScreen = camera:WorldToScreenPoint(humanoidRootPart.Position + Vector3.new(0, 3, 0))
                                
                                if onScreen then
                                    drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                                else
                                    drawing.Visible = false
                                end
                                
                                table.insert(ESPDrawings, drawing)
                            end
                        else
                            -- Remove highlight jika ESP dioff
                            local highlight = character:FindFirstChild("ESPHighlight")
                            if highlight then
                                highlight:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Function untuk toggle ESP Survivors
function Logic.ESPSurvivors()
    ESPEnabled.Survivors = not ESPEnabled.Survivors
end

-- Function untuk toggle ESP Killer
function Logic.ESPKiller()
    ESPEnabled.Killer = not ESPEnabled.Killer
end

-- Function untuk toggle ESP Spectator
function Logic.ESPSpectator()
    ESPEnabled.Spectator = not ESPEnabled.Spectator
end

return Logic
