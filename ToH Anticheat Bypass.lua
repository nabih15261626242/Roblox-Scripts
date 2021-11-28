-- For discord join
if syn then request = syn.request end

-- Hooking kick
OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
    if getnamecallmethod() == "Kick" then
        return wait(9e9)
    end

    return OldNameCall(Self, ...)
end)

-- Removing anticheat
game:GetService("Players").LocalPlayer.PlayerScripts.LocalScript2:Destroy()
game:GetService("Players").LocalPlayer.PlayerScripts.LocalScript:Destroy()

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Anticheat Bypassed",
    Text = "Made by kubuntuclaps#1337",
    Button1 = "Nice!"
})

-- Discord auto join
request({
   Url = "http://127.0.0.1:6463/rpc?v=1",
   Method = "POST",
   Headers = {
       ["Content-Type"] = "application/json",
       ["Origin"] = "https://discord.com"
   },
   Body = game:GetService("HttpService"):JSONEncode({
       cmd = "INVITE_BROWSER",
       args = {
           code = "MKVr5DunmQ"
       },
       nonce = game:GetService("HttpService"):GenerateGUID(false)
   }),
})