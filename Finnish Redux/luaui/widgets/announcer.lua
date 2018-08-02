function widget:GetInfo()
	return {
		name      = "Announcement",
		desc      = "Massive damage detected!",
		author    = "_Shaman",
		date      = "July 31, 2017",
		license   = "Burn the heretic. Purge the Alien.",
		layer     = 5,
		enabled   = true,
	}
end

local announcement = {}
local fontsize = 0
local font = ":o:LuaUI/Fonts/FreeSansBold_14"
fontHandler.UseFont(font)
Spring.Echo("Fontsize: " .. tostring(fontHandler.GetFontSize()))
fontsize = fontHandler.GetFontSize()

function widget:RecvLuaMsg(msg, playerID)
	if playerID == Spring.GetMyPlayerID() and msg:find("FFR") then
		msg = msg:gsub("FFR ","",1)
		local strings = {}
		local i=1
		for w in string.gmatch(msg,"[%d*%a*%s*&?!&.#@^%%_-]+,") do
			strings[#strings+1] = w
			i=i+1
		end
		i=nil
		for i=1,#strings do
			strings[i] = strings[i]:gsub(",","")
		end
		announcement[#announcement+1] = {text = strings[1],type = strings[2],duration = strings[3], color = {r=tonumber(strings[4]),g=tonumber(strings[5]),b=tonumber(strings[6]),a=tonumber(strings[7])},flash=strings[8],size=tonumber(strings[9]),timer=Spring.GetTimer(), framecreated = Spring.GetGameFrame()}
		Spring.Echo("Table info: \ntext:" .. tostring(announcement[#announcement].text) .. "\ntype: " .. tostring(announcement[#announcement].type) .. "\nduration:" .. tostring(announcement[#announcement].duration) .. "\nColor: " .. tostring(announcement[#announcement].color.r,announcement[#announcement].color.g,announcement[#announcement].color.b) .. "\nflash: " .. tostring(announcement[#announcement].flash) .. "\nSize: " .. tostring(announcement[#announcement].size))
	end
end

function widget:DrawScreen()
	viewSizeX, viewSizeY = gl.GetViewSizes()
	if announcement and #announcement > 0 then
		local t = Spring.GetTimer()
		local announceY
		for i=1, #announcement do
			gl.PushMatrix()
			gl.Billboard()
			fontHandler.UseFont(font)
			local scaling = announcement[i].size/fontsize
			announceY = 0
			gl.Color(announcement[i].color.r,announcement[i].color.g,announcement[i].color.b,announcement[i].color.a)
			if announcement[i].flash == "random" then
				gl.Color(math.random(1,255)/255, math.random(1,255)/255,math.random(1,255)/255,1)
			end
			if announcement[i].flash == "loss" then
				local r,g,b
				local cost = math.cos(Spring.DiffTimers(t, announcement[i].timer))
				if announcement[i].color.r ~= 0 then r = math.min(math.abs(announcement[i].color.r*cost),1) else r=0 end
				if announcement[i].color.g ~= 0 then g = math.min(math.abs(announcement[i].color.g*cost),1) else g=0 end
				if announcement[i].color.b ~= 0 then b = math.min(math.abs(announcement[i].color.b*cost),1) else b=0 end
				gl.Color(r,g,b,1)
			end
			if announcement[i].flash == "gain" then
				local r,g,b
				local sint = math.sin(Spring.DiffTimers(t, announcement[i].timer))
				if announcement[i].color.r ~= 0 then r = math.abs(announcement[i].color.r*sint) else r=0 end
				if announcement[i].color.g ~= 0 then g = math.abs(announcement[i].color.g*sint) else g=0 end
				if announcement[i].color.b ~= 0 then b = math.abs(announcement[i].color.b*sint) else b=0 end
				gl.Color(r,g,b,1)
			end
			if announcement[i].flash == "flash" then
				local r,g,b,a
				r = announcement[i].color.r
				g = announcement[i].color.g
				b = announcement[i].color.b
				a = math.abs(math.cos(Spring.DiffTimers(t, announcement[i].timer)))
				gl.Color(r,g,b,a)
			end
			gl.Scale(announcement[i].size/fontsize,announcement[i].size/fontsize,announcement[i].size/fontsize)
			if announcement[i].type == "scrolling" then
				if announcement[i].speed == nil then
					announcement[i]["speed"] = viewSizeY/(announcement[i].duration*300)
					Spring.Echo(tostring(announcement[i].speed))
				end
				--Spring.Echo(i .. ": " .. Spring.DiffTimers(t, announcement[i].timer))
				announceY = viewSizeY - (Spring.DiffTimers(t, announcement[i].timer)*announcement[i].speed*viewSizeY)
				--Spring.Echo("announceY: " .. announceY)
				if (announceY > 0) then
					gl.PushMatrix()
					gl.Translate(viewSizeX/(2*scaling),announceY,0)
					gl.Scale(scaling, scaling, scaling)
					fontHandler.DrawCentered(announcement[i].text, 0, 0)
					gl.PopMatrix()
				end
			elseif announcement[i].type == "staticbot" then
				gl.PushMatrix()
				gl.Translate(viewSizeX/(2*scaling),viewSizeY/(2*scaling),0)
				gl.Scale(scaling,scaling,scaling)
				fontHandler.DrawCentered(announcement[i].text, 0, 0)
				gl.PopMatrix()
			elseif announcement[i].type == "static" then
				gl.PushMatrix()
				gl.Translate(viewSizeX/2,viewSizeY/2,0)
				gl.Scale(scaling,scaling,scaling)
				fontHandler.DrawCentered(announcement[i].text,0,0)
				gl.PopMatrix()
			end
			gl.Color(1,1,1,1)
			gl.PopMatrix()
			announceY = viewSizeY
		end
		announceY = 0
		for index,_ in pairs(announcement) do
			if announcement[index].type == "scrolling" or announcement[index].type == "scrollingup" then
				announceY = viewSizeY - (Spring.DiffTimers(t, announcement[index].timer)*announcement[index].speed*viewSizeY)
			end
			if (announcement[index].type == "scrolling" or announcement[index].type == "scrollingup") and announceY < 0 then
				table.remove(announcement, index)
			elseif announcement[index].type == "static" and Spring.GetGameFrame() > announcement[index].framecreated + announcement[index].duration*30 then
				table.remove(announcement,index)
			end
		end
	end
end
