local function is_cmake_project(cwd)
	return #vim.fs.find("CMakeLists.txt", { path = cwd, type = "file" }) > 0
end

return {
	name = "cmake",
	builder = function()
		return {
			cmd = "sh",
			args = { "-c", "mkdir -p build && cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build" },
			components = {
				{ "on_output_quickfix", open = true },
				{ "default" },
			},
		}
	end,
	condition = {
		callback = function(opts)
			return is_cmake_project(opts.dir)
		end,
	},
}
