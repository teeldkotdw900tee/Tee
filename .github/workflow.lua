--[[
    Team Switch Exploit — Clean & Universal Version
    - ย้ายมาใช้ PlayerGui ป้องกันรันไม่ติด
    - ดึงรายชื่อทีมจากเกมแบบเรียลไทม์
    - รองรับการยิง Remote เปลี่ยนทีมอัตโนมัติ
]]

print("========================================")
print("[EXPLOIT] เริ่มต้นสคริปต์เวอร์ชันใหม่...")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamsService = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[EXPLOIT] ERROR: LocalPlayer เป็น nil")
    return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. ลบ UI เก่า (ถ้ามี)
pcall(function()
    local old = PlayerGui:FindFirstChild("UniversalTeamUI")
    if old then old:Destroy() end
end)

-- 2. สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalTeamUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 3. สร้าง MainFrame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- หัวข้อ UI
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🎯 Team Switcher (New)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- แสดงทีมปัจจุบัน
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Text = "ทีมปัจจุบัน: " .. tostring(LocalPlayer.Team and LocalPlayer.Team.Name or "ไม่มีทีม")
StatusLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

-- หาโฟลเดอร์ทีมในเกม
local TeamsFolder = TeamsService or workspace:FindFirstChild("Teams") or ReplicatedStorage:FindFirstChild("Teams")
local AvailableTeams = {}

if TeamsFolder then
    for _, t in ipairs(TeamsFolder:GetChildren()) do
        if t:IsA("Team") then
            table.insert(AvailableTeams, t.Name)
        end
    end
end

-- ปุ่มเลือกทีมถัดไป
local SwitchBtn = Instance.new("TextButton")
SwitchBtn.Size = UDim2.new(1, -20, 0, 40)
SwitchBtn.Position = UDim2.new(0, 10, 0, 80)
SwitchBtn.Text = "🔄 เปลี่ยนทีมถัดไป"
SwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchBtn.TextSize = 13
SwitchBtn.Font = Enum.Font.GothamBold
SwitchBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SwitchBtn

-- Log ข้อความด้านล่าง
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, -20, 0, 60)
LogLabel.Position = UDim2.new(0, 10, 0, 135)
LogLabel.Text = "สถานะ: พร้อมใช้งาน (พบทีมทั้งหมด: " .. #AvailableTeams .. " ทีม)"
LogLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
LogLabel.TextSize = 11
LogLabel.TextWrapped = true
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.BackgroundTransparency = 1
LogLabel.Parent = MainFrame

-- ฟังก์ชันกดเปลี่ยนทีม
local teamIndex = 0
SwitchBtn.MouseButton1Click:Connect(function()
    if #AvailableTeams == 0 then
        LogLabel.Text = "สถานะ: ไม่พบโฟลเดอร์ทีมในเกมนี้"
        return
    end

    teamIndex = (teamIndex % #AvailableTeams) + 1
    local targetName = AvailableTeams[teamIndex]
    local targetTeam = TeamsFolder:FindFirstChild(targetName)

    LogLabel.Text = "สถานะ: กำลังเปลี่ยนเป็นทีม [" .. targetName .. "]..."

    -- พยายามเปลี่ยนทีมผ่าน RemoteEvent ของเกม (ถ้ามี)
    local fired = false
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (string.lower(obj.Name):match("team") or string.lower(obj.Name):match("spawn")) then
            pcall(function()
                obj:FireServer(targetTeam)
                obj:FireServer(targetName)
                fired = true
            end)
        end
    end

    -- บังคับเปลี่ยนฝั่ง Client สำรอง
    pcall(function()
        LocalPlayer.Team = targetTeam
    end)

    task.wait(0.3)
    StatusLabel.Text = "ทีมปัจจุบัน: " .. tostring(LocalPlayer.Team and LocalPlayer.Team.Name or "None")
    LogLabel.Text = "สถานะ: สลับไปทีม " .. targetName .. " เรียบร้อย!"
end)

print("[EXPLOIT] โหลด UI สำเร็จแล้ว!")
