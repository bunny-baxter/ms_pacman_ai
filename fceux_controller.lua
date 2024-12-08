local socket = require("socket")

local t = 0

local s = socket.tcp()
local connected = s:connect("localhost", 7000)

-- load savestate slot 0
local state = savestate.object(10)
savestate.load(state)

while (true) do
  local pac_x = memory.readbyte(0x60)
  local pac_y = memory.readbyte(0x62)
  if connected then
    s:send("pac is at " .. pac_x .. ", " .. pac_y .. "\n")
  end

  local data = s:receive()
  if data then
    local joypad_table = { up = false, down = false, right = false, left = false }
    local joypad_direction = string.match(data, "joypad (%a+)")
    if joypad_direction == "up" then
      joypad_table.up = true
    elseif joypad_direction == "down" then
      joypad_table.down = true
    elseif joypad_direction == "left" then
      joypad_table.right = true
    elseif joypad_direction == "right" then
      joypad_table.left = true
    end
    joypad.write(1, joypad_table)
  end

  emu.frameadvance()
  t = t + 1
end

s:close()
