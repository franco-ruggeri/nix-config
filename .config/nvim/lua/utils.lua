local M = {}

M.is_location_list = function(window)
	window = window or vim.api.nvim_get_current_win()
	return vim.fn.getwininfo(window)[1].loclist == 1
end

M.is_cmake_project = function(cwd)
	return #vim.fs.find("CMakeLists.txt", { path = cwd, type = "file" }) > 0
end

M.is_python_project = function(cwd)
	return #vim.fs.find("pyproject.toml", { path = cwd, type = "file" }) > 0
end

M.get_lualine_component_lazy = function(lazy_module, component)
	local M_ = require("lualine.component"):extend()

	function M_:init(options)
		M_.super.init(self, options)
		self.options = options or {}
	end

	function M_:update_status()
		if not package.loaded[lazy_module] then
			-- Module not loaded yet. Act as a dummy component that shows nothing.
			return nil
		else
			-- Module loaded. It's time to initialize the component.
			-- Make self:<method> point to the mcphub component's respective method.
			-- So, after this call, self:update_status() will point to the actual component's method.
			setmetatable(self, { __index = require(component) })
			self:init(self.options)
		end
	end

	return M_
end

return M
