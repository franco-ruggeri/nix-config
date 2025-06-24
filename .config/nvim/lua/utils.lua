local M = {}

M.is_location_list = function(window)
	window = window or vim.api.nvim_get_current_win()
	return vim.fn.getwininfo(window)[1].loclist == 1
end

M.is_cmake_project = function(cwd)
	return #vim.fs.find("CMakeLists.txt", { path = cwd, type = "file" }) > 0
end

M.is_make_project = function(cwd)
	return #vim.fs.find("Makefile", { path = cwd, type = "file" }) > 0
end

return M
