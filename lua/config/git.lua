vim.api.nvim_create_user_command("Git", function(opts)
	vim.cmd("!" .. "git " .. table.concat(opts.fargs, " "))
end, {
	nargs = "*",
	complete = function(_, line)
		local subcommands = {
			"st",
			"status",
			"add",
			"commit",
			"comm",
			"push",
			"pull",
			"checkout",
			"branch",
			"log",
			"diff",
			"staash",
			"stashl",
			"stash",
		}

		local parts = vim.split(line, "%s+")
		local prefix = parts[#parts] or ""

		local matches = {}
		for _, cmd in ipairs(subcommands) do
			if cmd:sub(1, #prefix) == prefix then
				table.insert(matches, cmd)
			end
		end

		return matches
	end,
})
