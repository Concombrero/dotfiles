local subscribed = false

local function setup()
	if subscribed then
		return
	end

	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd

		if cwd and cwd:ends_with("Downloads") then
			opt.by, opt.reverse, opt.dir_first = "mtime", true, false
		else
			opt.by, opt.reverse, opt.dir_first = "natural", false, true
		end

		return opt
	end)

	subscribed = true
end

return { setup = setup }
