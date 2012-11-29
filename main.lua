--[[ Vortex 0.1 main program

 Author: q66 <quaker66@gmail.com>
 Available under the terms of the MIT license.
]]

package.path = package.path .. ";./src/?.lua"

local util   = require("util")
local parser = require("parser")

local help = function(args)
    print("Vortex compiler v" .. META.general.version)
    print("Usage:")
    print("  " .. args[-1] .. " " .. args[0] .. " [-o opt=val] [files.vx]")
end

local test_opt = function(section, field, value)
    local sect = META[section]
    if not sect or sect[field] == nil then return nil end

    local t = type(sect[field])
    if t == "number" then
        return tonumber(value)
    elseif t == "string" then
        return tostring(value)
    end
end

local compile_all = function(args)
    local opts, args = util.getopt(args, "so:", { "stdout" })

    local stdo
    for i = 1, #opts do
        local v = opts[i]
        local key, val = v[1], v[2]
        if key == "stdout" then
            stdo = true
        end
    end
    for i = 1, #args do
        local  ifname = args[i]
        local  rs = io.open(ifname, "r")
        if not rs then
            io.stderr:write(ifname .. ": No such file or directory\n")
            return 1
        end

        local ast  = parser.parse(ifname, util.file_istream(rs))
        local code = parser.build(ast)
        io.close(rs)

        if stdo then
            print("--- output for file " .. ifname .. " ---")
            print(code)
        else
            local  ofname
            local  has_ext = ifname:find("%.vx")
            if not has_ext then
                ofname = ifname .. ".lua"
            else
                ofname = ifname:gsub("%.vx", ".lua")
            end

            local  ws = io.open(ofname, "w")
            if not ws then
                io.stderr:write("Cannot open " .. ofname ..
                    " for writing.\n")
                io.close(rs)
                return 1
            end
            ws:write(code)
            io.close(ws)
        end
    end
end

local main = function(args)
    if #args == 0 then
        help(args)
        return 0
    end
    return compile_all(args) or 0
end

os.exit(main(arg))