local Logic = {}

-- ============================================
-- ESP PLAYER LOGIC
-- ============================================

local ESPEnabled = {
    Survivors = false,
    Killer = false,
    Spectator = false,
}

local ESPTextDrawings = {}  -- key: player, value: Drawing.Text (persist, update in-place)

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
local function CreateESPText()
    local drawing = Drawing.new("Text")
    drawing.Size = 20
    drawing.Center = true
    drawing.Outline = true
    drawing.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawing.Font = 2
    drawing.Color = Color3.fromRGB(255, 255, 255)
    drawing.Visible = true
    
    return drawing
end

-- Main ESP Loop - Realtime update
local espLoop = game:GetService("RunService").RenderStepped:Connect(function()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return end
    
    local camera = workspace.CurrentCamera
    
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
                            pcall(function()
                                local distance = GetDistance(localPlayer, player)
                                
                                -- Create body highlight (cuma sekali, reused)
                                CreateBodyHighlight(character, roleName)
                                
                                -- Ambil drawing yang udah ada, atau bikin baru kalo belum ada
                                local drawing = ESPTextDrawings[player]
                                if not drawing then
                                    drawing = CreateESPText()
                                    ESPTextDrawings[player] = drawing
                                end
                                
                                -- Set color sesuai role
                                local teamColors = {
                                    Survivors = Color3.fromRGB(0, 100, 255),      -- Blue
                                    Killer = Color3.fromRGB(255, 0, 0),           -- Red
                                    Spectator = Color3.fromRGB(200, 200, 200),    -- Gray/White
                                }
                                drawing.Color = teamColors[roleName] or Color3.fromRGB(255, 255, 255)
                                
                                -- Format text: Username (Distance) -- update in-place
                                drawing.Text = player.Name .. " (" .. math.floor(distance) .. ")"
                                
                                -- Auto-scale size berdasarkan distance (makin jauh makin kecil)
                                local maxDistance = 150
                                local minSize = 10
                                local maxSize = 22
                                drawing.Size = math.clamp(maxSize - (distance / maxDistance) * (maxSize - minSize), minSize, maxSize)
                                
                                -- Get screen position (di atas kepala) -- update in-place
                                local screenPos, onScreen = camera:WorldToScreenPoint(humanoidRootPart.Position + Vector3.new(0, 3.5, 0))
                                
                                if onScreen then
                                    drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                                    drawing.Visible = true
                                else
                                    drawing.Visible = false
                                end
                            end)
                        else
                            -- ESP role ini dimatiin -> bersihin highlight + text punya player ini
                            local highlight = character:FindFirstChild("ESPHighlight")
                            if highlight then
                                highlight:Destroy()
                            end
                            if ESPTextDrawings[player] then
                                ESPTextDrawings[player]:Remove()
                                ESPTextDrawings[player] = nil
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Cleanup drawing punya player yang udah keluar/respawn tanpa character
    for p, drawing in pairs(ESPTextDrawings) do
        if not p.Parent or not p.Character then
            drawing:Remove()
            ESPTextDrawings[p] = nil
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
