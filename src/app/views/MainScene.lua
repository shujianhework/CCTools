
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    local node = self:getResourceNode():getChildByName("TempStringValue")
    node:setInvalidString("無")
	local txt = "無 最了adk 指令，将常量a 加载到線，下載即日免費使用時長寄存器 0 中。然后 se的key5，也就是这"
	print(txt)
    dump(node:getInvalidCharacterSets(txt))
	node:setString(txt)
    self.textstate = node
    local img = self:getResourceNode():getChildByName("Image_2")
    local pt1 = cc.p(img:getPosition())
    local size = img:getContentSize()
    local draw = cc.DrawNode:create()
    draw:setPosition(cc.p(10,10))
    self:addChild(draw)
    local Button_2 = self:getResourceNode():getChildByName("Button_2")
    img:addTouchEventListener(function(sender,eventType)
    end)
    self.draw = draw
    local tf = self:getResourceNode():getChildByName("TextField_1")
    Button_2.visible = function (_,vis)
        tf:setVisible(vis)
        Button_2:setVisible(vis)
    end
    Button_2:addTouchEventListener(function ()
        local str = tf:getString()
        local num = tonumber(str)
        if num and num > 0 and num < 60 then
            self.Round = num
        end
    end)
    self.Button_2 = Button_2
    Button_2:visible(false)
    local act = cc.Sequence:create(cc.CallFunc:create(function ()
        xpcall(function ( ... )
            self:onUpdate()
        end,function ( ... )
            --print(...)
        end)
    end),cc.DelayTime:create(0.05))
    img:runAction(cc.RepeatForever:create(act))
    local pt = img:getAnchorPoint()
    self.img = img
    self.img.size = size
    self.img.idx = 0
    self.img.AllSize = size.width * size.height
    self.stattempvalue = ""
end
function MainScene:onUpdate()
    
end
function MainScene:shows()
    local cout = 0
    local itemcout = 13
    local pt1 = cc.p(830,620)
    for k,v in pairs(self.showcopy or {}) do
        if #v > 0 then
            cout = cout + 1
            if pt1.y > 5 then
                local color1 = v.rgb
                local pt = string.split(v[1],"|")
                pt.x = tonumber(pt[1])
                pt.y = tonumber(pt[2]) + 120
                local c4f = cc.c4f(color1.r/255, color1.g/255, color1.b/255, 1.0)
                self.draw:drawDot(pt,10,c4f)
                -- local tb = {}
                -- for ii,vv in ipairs(v) do
                --     local pt = string.split(v[1],"|")
                --     tb[#tb + 1] = {x = tonumber(pt[1]),y = tonumber(pt[2])}
                -- end
                -- self.draw:drawPoints(tb,#tb,c4f)
            else
                itemcout = cout
            end
            if cout % itemcout then
                pt1.x = 830 + (cout % itemcout) * 8
            end
            pt1.y = 620 - math.floor(cout/itemcout) * 8
        end
    end
end
--以最多的颜色当作背景色，并最后删除最多的颜色
function MainScene:onUpdate1()
    self.state = self.state or 0
    if self.state == 0 then
        self.textstate:setString("遍历所有颜色开始")
        self.stattempvalue = "遍历所有颜色开始"
        self.cors = {color = {},back = nil}
        self.state = 100
        self.singlevalue = 1000
        local f = io.open("flg.lua","r")
        if f == nil then
            self.state = 1
        else
            self.state = 3
            local s = f:read("*a")
            f:close()
            self.cors = load(s)()
        end
    end
    if self.state == 1 then
        self.textstate:setString(self.stattempvalue..self.img.idx.."/"..self.img.AllSize)
        for i=1,self.singlevalue do
            local idx = self.img.idx + i
            if idx > self.img.AllSize then
                self.img.idx = idx
                self.textstate:setString("遍历所有颜色结束")
                self.stattempvalue = "遍历所有颜色结束"
                self.state = 2
                return
            end
            local pt = cc.p(idx % self.img.size.width,math.floor(idx/self.img.size.width))
            local tab = self.img:getPtColor(pt.x,pt.y)
            if tab then
                local cor = tab.r.."|"..tab.g.."|"..tab.b
                if self.cors.back and self.cors.back == cor then
                    --背景色过滤不存储
                else
                    self.cors.color[cor] = self.cors.color[cor] or {}
                    if #self.cors.color[cor] < self.img.AllSize/2 then
                        local xy = pt.x.."|"..pt.y
                        self.cors.color[cor][#self.cors.color[cor] + 1] = xy
                    else
                        self.cors.back = cor
                        self.textstate:setString("遍历中找出背景色,并删除，继续遍历\n")
                        self.stattempvalue = "遍历中找出背景色,并删除，继续遍历\n"
                        self.cors.color[cor] = nil
                    end
                end
            end
        end
        self.img.idx = self.img.idx + self.singlevalue
    elseif self.state == 2 then
        self.state = 3
        self.textstate:setString("删除背景色")
        if self.cors.back == nil then
            local cn = {max = 0,col = nil}
            for k,v in pairs(self.cors.color) do
                if cn.max < #v then
                    cn.col = k
                    cn.max = #v
                end
            end
            self.cors.color[cn.col] = nil
            self.cors.back = cn.col
        end
        local s = "return { back = \""..self.cors.back.."\",\ncolor = {\n"
        for k,v in pairs(self.cors.color) do
            local tempstr = "{"
            for ii,vv in ipairs(v) do
                tempstr = tempstr.."\""..vv.."\","
            end
            tempstr = tempstr.."nil},\n"
            s = s.."[\""..k.."\"] = "..tempstr
        end
        s = s.."nil},nil}"
        local f = io.open("flg.lua","w")
        f:write(s)
        f:close()
    elseif self.state == 3 then
        self.state = 4
        self.stattempvalue = "获取hsv列表"
        self.textstate:setString(self.stattempvalue)

        local t1a = {}
        local jkl = {}
        local removekeys = {}
        --按照hsv的方式移除相同颜色
        local src_all_px = 0
        for k,v in pairs(self.cors.color) do
            if #v > 0 then
                src_all_px = src_all_px + #v
                local pt = string.split(v[1],"|")
                pt.x = tonumber(pt[1])
                pt.y = tonumber(pt[2])
                local color1 = self.img:getPtColor(pt.x,pt.y)
                v.rgb = color1
                
                color1 = self.img:getPtColor(pt.x,pt.y,true)
                v.hsv = color1
                v.selfkey = k
                local key = color1.r.."|"..color1.g.."|"..color1.b
                if t1a[key] == nil then
                    t1a[key] = {cout = 1,byv = v,byk = k}
                else
                    removekeys[#removekeys + 1] = k
                    self.cors.color[k] = nil
                    local tmpk = self.cors.color[t1a[key].byk]
                    for iii,vvv in ipairs(v) do
                        tmpk[#tmpk + 1] = vvv
                    end
                end
            end
        end
        
        for k,v in ipairs(removekeys) do
            self.cors.color[v] = nil
        end
        
        local temptab2 = {}
        for k,v in pairs(t1a) do
            temptab2[#temptab2 + 1] = {k,v}
        end
        t1a = nil
        local temptab = {}
        for k,v in pairs(self.cors.color) do
            temptab[#temptab + 1] = v
        end
        table.sort(temptab,function (a,b)
            return #a>#b
        end)
        print("src size ",#temptab," px = ", src_all_px)
        -- self.cors.color = temptab
        -- table.sort(temptab2,function (a,b)
        --     return #a > #b
        -- end)  
    elseif self.state == 4 then
        --移除小于3的key
        local tab1 = {}
        local tab2 = {}
        local nj = 0
        for k,v in pairs(self.cors.color) do
            nj = nj + #v
            tab1[#v] = tab1[#v] or {}
            tab1[#v][#tab1[#v] + 1] = k
            tab2[v.hsv.r] = tab2[v.hsv.r] or {}
            tab2[v.hsv.r][v.hsv.g] = tab2[v.hsv.r][v.hsv.g] or {}
            tab2[v.hsv.r][v.hsv.g][v.hsv.b] = tab2[v.hsv.r][v.hsv.g][v.hsv.b] or k
        end
        --dump(tab2)
        for i,v in ipairs(tab1) do
            table.sort(v,function (a,b)
                local h1 = self.cors.color[a].hsv
                local h2 = self.cors.color[b].hsv
                local br = h1.r < h2.r
                local bg = h1.b < h2.b
                local bb = h1.b < h2.b
                if br and bg then
                    return true
                elseif bg and bb then
                    return true
                elseif br and bb  then
                    return true
                end
                return false
            end)
        end
        local fun = nil
        fun = function (idx)
            local removekeys = {}
            for i,v in ipairs(tab1[idx] or {}) do
                local myt = self.cors.color[v]
                if #myt <= idx then
                    --想法子删除这一组
                    local loopflg = true
                    for ii=-3,3 do
                        local hsvr = myt.hsv.r + ii
                        if tab2[hsvr] and loopflg then
                            for iii=-3,3 do
                                local hsvg = myt.hsv.g + iii
                                if tab2[hsvr][hsvg] and loopflg then
                                    for iiii=-3,3 do
                                        if loopflg == false then
                                            break
                                        end
                                        local hsvb = myt.hsv.b + iiii
                                        if iiii == 0 and iii == 0 and ii == 0 then
                                        elseif tab2[hsvr][hsvg][hsvb] then
                                            --需要跳出并移除自己
                                            local byk = tab2[hsvr][hsvg][hsvb]
                                            if self.cors.color[byk] then
                                                removekeys[#removekeys + 1] = {v,byk}
                                                tab2[myt.hsv.r][myt.hsv.g][myt.hsv.b] = nil
                                                loopflg = false
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            local tab3 = {}
            for i,v in ipairs(removekeys) do
                tab3[v[1]] = v[2]
            end
            local findNoQueueKey = nil
            findNoQueueKey = function (curkey)
                if tab3[tab3[curkey]] then
                    return findNoQueueKey(tab3[curkey])
                else
                    return tab3[curkey]
                end
            end
            --dump(tab3)
            local removekeys2 = {}
            for i,v in ipairs(removekeys) do
                -- --转移项也在被移除的队列中
                local NoQueueKey = findNoQueueKey(v[1])
                local t1 = self.cors.color[v[1]]
                local t2 = self.cors.color[NoQueueKey]
                for ii,vv in ipairs(t1) do
                    t2[#t2 + 1] = vv
                end
                removekeys2[#removekeys2 + 1] = v[1]
            end
            for i,v in ipairs(removekeys2) do
                self.cors.color[v] = nil
            end
            return #removekeys2
        end
        local allremove = 0
        self.singval = self.singval or 0
        self.singval = self.singval + 1
        local nti = 0
        for i=1,self.singval do
            nti = nti + #tab1[i]
            allremove = allremove + fun(i)
        end
        if allremove == 0 then
            self.state = 5
        end
        if self.singval > 28 then
            self.singval = nil
            self.state = 5
        end
    elseif self.state == 5 then
        self.state = 6
        local tab = {}
        for i,v in pairs(self.cors.color) do
            tab[#tab + 1] = v
        end
        table.sort(tab,function (a,b)
            return #a>#b
        end)
        self.cors.color = tab
    elseif self.state == 6 then
        self.idx = self.idx or 0
        self.idx = self.idx + 1
        if self.cors.color[self.idx] then
            local t1 = self.cors.color[self.idx]
            local t2 = {}
            for i,v in ipairs(t1) do
                local pt = v:split("|")
                t2[i] = {x = tonumber(pt[1]),y = tonumber(pt[2])}
            end
            for i = 1,#t1 do
                t1[i] = t2[i]
            end
            t2 = nil
        else
            self.idx = 0
            self.state = 7
        end
    elseif self.state == 7 then
        self.idx = self.idx + 1
        if self.cors.color[self.idx] then
            local t1 = self.cors.color[self.idx]
            local t2 = {}
            local t3 = {}
            for i,v in ipairs(t1) do
                t2[i] = v
                t3[v.x] = t3[v.x] or {}
                t3[v.x][v.y] = {i,flg = true}
            end
            --非孤立像素 
            local t4 = {}
            --孤立像素
            local hashPx = {}
            for ii,vv in ipairs(t2) do
                if vv.pl == nil then
                    for i=1,1 do
                        local flg = false
                        for j=0-i,i do
                            if (j == 0-i or j == i) and vv.pl then
                                for l=0-i,i do
                                    if l == 0-i or l == i then
                                        if t3[vv.x + j] and t3[vv.x + j][vv.y + l] and t3[vv.x + j][vv.y + l].flg then
                                            t3[vv.x + j][vv.y + l].flg = false
                                            flg = true
                                            vv.pl = 1
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if flg then
                        else
                            --这是有一个散列的点
                        end
                    end
                end
            end
            self.state = 8
        else
            self.idx = 0
            self.state = 7
        end
    elseif self.state == 100 then
        self.state = 101
        local tab = {}
        local allsizes = {}
        local src_all_px = 0
        for k,v in pairs(self.cors.color) do
            local tb = {hsv = v.hsv,rgb = v.rgb}
            src_all_px = src_all_px + #v
            for ii,vv in ipairs(v) do
                tb[#tb + 1] = vv
                break
            end
            tab[#tab + 1] = tb
        end
        print("cur size ",#tab," px = ", src_all_px)
        self.showcopy = tab
        self:shows()
    end
end
return MainScene
