local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local HttpService = game:GetService("HttpService")
local UID = game:GetService("RbxAnalyticsService"):GetClientId()

local SECRET_KEY = "XANZSIMPLE"
local BASE_URL = "https://373d-69-176-153-227.ngrok-free.app/getsecure"
local KeyEntered = ""
local ScriptLoaded = false

-- Base64 decode
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64_decode(data)
    data = data:gsub('[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c=c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Decrypt
local function custom_decrypt(encoded, key)
    local decoded = base64_decode(encoded)
    if not decoded or decoded == "" then return nil end
    local result = ""
    for i = 1, #decoded do
        local c = string.byte(decoded, i)
        local k = key:byte(((i - 1) % #key) + 1)
        local decryptedByte = bit32.bxor(bit32.bxor(c, k), (i - 1) % 13)
        result = result .. string.char(decryptedByte)
    end
    return result
end

-- GUI
local Window = OrionLib:MakeWindow({
    Name = "Xanz Loader",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "🔐 Xanz Secure Script"
})

local Tab = Window:MakeTab({ Name = "Key System", Icon = "", PremiumOnly = false })
Tab:AddTextbox({
    Name = "Enter Your Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        KeyEntered = Value
    end
})

Tab:AddButton({
    Name = "Submit Key",
    Callback = function()
        if ScriptLoaded then return end
        if KeyEntered == "" then
            OrionLib:MakeNotification({ Name = "No Key", Content = "Please enter a key.", Time = 3 })
            return
        end

        local request = (http and http.request) or (syn and syn.request)
        if not request then
            OrionLib:MakeNotification({ Name = "❌ Unsupported", Content = "No HTTP support in executor.", Time = 4 })
            return
        end

        local url = BASE_URL .. "?key=" .. KeyEntered .. "&uid=" .. UID
        local response = request({ Url = url, Method = "GET" })

        local body = HttpService:JSONDecode(response.Body)
        if not body.success then
            OrionLib:MakeNotification({ Name = "❌ Invalid Key", Content = body.message or "Unknown error", Time = 5 })
            return
        end

        local decrypted = custom_decrypt(body.payload, SECRET_KEY)
        print("======== DECRYPTED SCRIPT ========")
        print(decrypted or "nil")
        print("==================================")

        local exec = loadstring or load
        if decrypted and exec then
            local fn = loadstring(decrypted)
if fn then
    local success, err = pcall(fn)
    if success then
        ScriptLoaded = true
        OrionLib:MakeNotification({ Name = "✅ Loaded", Content = "Script loaded and executed.", Time = 5 })
    else
        OrionLib:MakeNotification({ Name = "❌ Runtime Error", Content = tostring(err), Time = 5 })
    end
else
    OrionLib:MakeNotification({ Name = "❌ Compile Error", Content = "Invalid Lua code.", Time = 5 })
end

            if not fn then
                warn("❌ Compile Error:", err)
                OrionLib:MakeNotification({ Name = "❌ Decrypt Error", Content = tostring(err), Time = 5 })
            else
                ScriptLoaded = true
                OrionLib:MakeNotification({ Name = "✅ Loaded", Content = "Script loaded successfully.", Time = 5 })
            end
        else
            OrionLib:MakeNotification({ Name = "❌ Failed", Content = "Decryption or execution failed.", Time = 4 })
        end
    end
})
