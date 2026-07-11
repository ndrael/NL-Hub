local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Logic = loadstring(game:HttpGet("https://raw.githubusercontent.com/ndrael/NL-Hub/refs/heads/main/logic.lua"))()

WindUI:AddTheme({
    Name = "Default",
    Accent = Color3.fromHex("#1a1611"),
    Background = Color3.fromHex("#0a0908"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#d4af37"),
    Text = Color3.fromHex("#f0d78c"),
    Placeholder = Color3.fromHex("#8a7645"),
    Button = Color3.fromHex("#2b2410"),
    Icon = Color3.fromHex("#ffd700"),
    Hover = Color3.fromHex("#ffdf70"),
    WindowBackground = Color3.fromHex("#0a0908"),
    WindowShadow = Color3.fromHex("#000000"),
    DialogBackground = Color3.fromHex("#0a0908"),
    DialogBackgroundTransparency = 0,
    DialogTitle = Color3.fromHex("#ffd700"),
    DialogContent = Color3.fromHex("#f0d78c"),
    DialogIcon = Color3.fromHex("#ffd700"),
    WindowTopbarButtonIcon = Color3.fromHex("#ffd700"),
    WindowTopbarTitle = Color3.fromHex("#ffd700"),
    WindowTopbarAuthor = Color3.fromHex("#8a7645"),
    WindowTopbarIcon = Color3.fromHex("#ffd700"),
    TabBackground = Color3.fromHex("#1a1611"),
    TabTitle = Color3.fromHex("#f0d78c"),
    TabIcon = Color3.fromHex("#ffd700"),
    ElementBackground = Color3.fromHex("#1a1611"),
    ElementTitle = Color3.fromHex("#f0d78c"),
    ElementDesc = Color3.fromHex("#8a7645"),
    ElementIcon = Color3.fromHex("#ffd700"),
    PopupBackground = Color3.fromHex("#0a0908"),
    PopupBackgroundTransparency = 0,
    PopupTitle = Color3.fromHex("#ffd700"),
    PopupContent = Color3.fromHex("#f0d78c"),
    PopupIcon = Color3.fromHex("#ffd700"),
    Toggle = Color3.fromHex("#1a1611"),
    ToggleBar = Color3.fromHex("#ffd700"),
    Checkbox = Color3.fromHex("#1a1611"),
    CheckboxIcon = Color3.fromHex("#f0d78c"),
    Slider = Color3.fromHex("#1a1611"),
    SliderThumb = Color3.fromHex("#ffd700"),
})

local Window = WindUI:CreateWindow({
    Title = "NL Hub",
    Icon = "crown",
    Author = "by ndrael",
    Theme = "Default"
})

Window:EditOpenButton({
    Title = "NL Hub",
    Icon = "crown",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("#FFD700")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "v1.0 (Alpha)",
    Color = Color3.fromHex("#FFD700"),
    Radius = 13,
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
    Locked = false,
})

local EspTab = Window:Tab({
    Title = "Esp",
    Icon = "eye",
    Locked = false,
})

local Section = EspTab:Section({ 
    Title = "Player Esp",
})

local Toggle = EspTab:Toggle({
    Title = "Survivors",
    Value = false,
    Callback = function(state)
        Logic.ESPSurvivors()
    end
})

local Toggle = EspTab:Toggle({
    Title = "Killer",
    Value = false,
    Callback = function(state)
        Logic.ESPKiller()
    end
})

local Toggle = EspTab:Toggle({
    Title = "Spectator",
    Value = false,
    Callback = function(state)
        Logic.ESPSpectator()
    end
})

local Section = EspTab:Section({ 
    Title = "Object Esp",
})

local Toggle = EspTab:Toggle({
    Title = "Generator",
    Value = false,
    Callback = function(state)
        -- ...
    end
})

local Toggle = EspTab:Toggle({
    Title = "Pallet",
    Value = false,
    Callback = function(state)
        -- ...
    end
})

local Toggle = EspTab:Toggle({
    Title = "Hook",
    Value = false,
    Callback = function(state)
        -- ...
    end
})

local Toggle = EspTab:Toggle({
    Title = "Exit Gate",
    Value = false,
    Callback = function(state)
        -- ...
    end
})

local AutoTab = Window:Tab({
    Title = "Auto",
    Icon = "infinity",
    Locked = false,
})

local CombatSection = Window:Section({
    Title = "Combat",
    Icon = "swords",
})

local SurvivorsTab = CombatSection:Tab({
    Title = "Survivors",
    Icon = "shield",
    Locked = false,
})

local KillerTab = CombatSection:Tab({
    Title = "Killer",
    Icon = "axe",
    Locked = false,
})

local EventTab = Window:Tab({
    Title = "Event",
    Icon = "gift",
    Locked = false,
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "sliders-horizontal",
    Locked = false,
})

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
    Locked = false,
})

MainTab:Select()
