local function setup()
	local home = os.getenv("HOME")
	local downloads = home and Url(home .. "/Downloads")

	ps.sub("ind-sort", function(opt)
		if downloads and cx.active.current.cwd == downloads then
			opt.by, opt.reverse, opt.dir_first = "mtime", true, false
		end

		return opt
	end)
end

return { setup = setup }
