-----------------------------------------------------------
-- Jupyter Workflow Utilities
-----------------------------------------------------------

local M = {}

local NEOPYTER_DEFAULT_ADDRESS = "127.0.0.1:9001"

local function trim_or_default(text)
  local trimmed = vim.trim(text or "")
  if trimmed == "" then
    return "no output"
  end
  return trimmed
end

local function run_system(command)
  local output = vim.fn.system(command)
  return vim.v.shell_error == 0, output
end

local function python312()
  local python = vim.fn.exepath("python3.12")
  if python == "" then
    return nil
  end
  return python
end

local function normalize_path(path)
  return vim.fn.fnamemodify(path, ":p"):gsub("/+$", "")
end

local function is_within(path, root)
  local absolute = normalize_path(path)
  local base = normalize_path(root)
  return absolute == base or vim.startswith(absolute, base .. "/")
end

local function notebook_paths_from_current_buffer()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path == "" then
    return nil, "Current buffer has no file path"
  end

  local absolute = normalize_path(buffer_path)
  if absolute:match("%.ipynb$") then
    return {
      source_path = absolute,
      ipynb_path = absolute,
      is_ju_source = false,
    }
  end

  if absolute:match("%.ju%.[^%.]+$") then
    return {
      source_path = absolute,
      ipynb_path = absolute:gsub("%.ju%.[^%.]+$", ".ipynb"),
      is_ju_source = true,
    }
  end

  return nil, "Current file is not a notebook source (.ju.* or .ipynb)"
end

local function refresh_ipynb_from_ju(python, source_path, ipynb_path)
  local ok, output = run_system({
    python,
    "-m",
    "jupytext",
    "--to",
    "ipynb",
    source_path,
    "-o",
    ipynb_path,
  })

  if not ok then
    vim.notify("Failed to refresh .ipynb from .ju source: " .. trim_or_default(output), vim.log.levels.WARN)
    return false
  end

  return true
end

local function list_jupyter_servers(python)
  local ok, output = run_system({ python, "-m", "jupyter", "server", "list", "--json" })
  if not ok then
    return {}
  end

  local servers = {}
  for line in output:gmatch("[^\r\n]+") do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      local parsed_ok, json = pcall(vim.json.decode, trimmed)
      if parsed_ok and type(json) == "table" and type(json.url) == "string" then
        servers[#servers + 1] = json
      end
    end
  end

  return servers
end

local function find_server_for_notebook(python, ipynb_path)
  local servers = list_jupyter_servers(python)
  for _, server in ipairs(servers) do
    local root_dir = server.root_dir or server.notebook_dir
    if type(root_dir) == "string" and root_dir ~= "" and is_within(ipynb_path, root_dir) then
      return server
    end
  end
  return nil
end

local function start_jupyter_server(python, root_dir)
  local job_id = vim.fn.jobstart({
    python,
    "-m",
    "jupyter",
    "lab",
    "--no-browser",
    "--ServerApp.root_dir=" .. root_dir,
  }, { detach = true })

  return job_id > 0
end

local function ensure_server_for_notebook(python, ipynb_path)
  local server = find_server_for_notebook(python, ipynb_path)
  if server then
    return server
  end

  local root_dir = vim.fn.fnamemodify(ipynb_path, ":h")
  if not start_jupyter_server(python, root_dir) then
    return nil
  end

  vim.notify("Starting JupyterLab server for notebook directory...", vim.log.levels.INFO)

  for _ = 1, 50 do
    vim.wait(200)
    server = find_server_for_notebook(python, ipynb_path)
    if server then
      return server
    end
  end

  return nil
end

local function relative_notebook_path(ipynb_path, server)
  local root = server.root_dir or server.notebook_dir
  if type(root) ~= "string" or root == "" then
    return vim.fn.fnamemodify(ipynb_path, ":t")
  end

  local root_abs = normalize_path(root)
  local ipynb_abs = normalize_path(ipynb_path)
  if is_within(ipynb_abs, root_abs) then
    return ipynb_abs:sub(#root_abs + 2)
  end

  return vim.fn.fnamemodify(ipynb_path, ":t")
end

local function url_encode(path)
  local encoded = path:gsub("\\", "/")
  encoded = encoded:gsub("%%", "%%25")
  encoded = encoded:gsub(" ", "%%20")
  encoded = encoded:gsub("#", "%%23")
  encoded = encoded:gsub("%?", "%%3F")
  return encoded
end

local function notebook_url(server, relative_path)
  local base = server.url
  if not base:match("/$") then
    base = base .. "/"
  end

  local url = base .. "lab/tree/" .. url_encode(relative_path)
  if type(server.token) == "string" and server.token ~= "" then
    url = url .. "?token=" .. server.token
  end

  return url
end

local function resolve_qutebrowser_launcher()
  local candidates = {
    "qutebrowser",
  }

  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return nil
end

local function open_in_qutebrowser(url)
  local launcher = resolve_qutebrowser_launcher()
  if not launcher then
    vim.notify("No qutebrowser launcher found", vim.log.levels.ERROR)
    return false
  end

  local stderr_lines = {}
  local job_id = vim.fn.jobstart({ launcher, url }, {
    stderr_buffered = true,
    on_stderr = function(_, data)
      if type(data) ~= "table" then
        return
      end
      for _, line in ipairs(data) do
        if line and line ~= "" then
          stderr_lines[#stderr_lines + 1] = line
        end
      end
    end,
  })

  if job_id <= 0 then
    vim.notify("Failed to launch qutebrowser", vim.log.levels.ERROR)
    return false
  end

  local exit_code = vim.fn.jobwait({ job_id }, 1200)[1]
  if exit_code > 0 then
    local detail = stderr_lines[1] or ("exit code " .. tostring(exit_code))
    vim.notify("Failed to launch qutebrowser: " .. detail, vim.log.levels.ERROR)
    return false
  end

  return true
end

local function neopyter_port_busy_by_other_nvim(address)
  local _, port = address:match("^([^:]+):(%d+)$")
  if not port then
    return false, nil
  end

  local ok, output = run_system({ "ss", "-ltnp" })
  if not ok then
    return false, nil
  end

  local current_pid = vim.fn.getpid()
  for line in output:gmatch("[^\r\n]+") do
    if line:find(":" .. port .. " ", 1, true) then
      for name, pid in line:gmatch('"([^"]+)",pid=(%d+)') do
        local owner_pid = tonumber(pid)
        if name == "nvim" and owner_pid and owner_pid ~= current_pid then
          return true, owner_pid
        end
      end
    end
  end

  return false, nil
end

local function neopyter_connected()
  local ok, jupyter = pcall(require, "neopyter.jupyter")
  if not ok or not jupyter or not jupyter.jupyterlab or not jupyter.jupyterlab.client then
    return false
  end

  local client = jupyter.jupyterlab.client
  if type(client.is_connecting) ~= "function" then
    return false
  end

  local state_ok, connected = pcall(client.is_connecting, client)
  return state_ok and connected == true
end

local function connect_and_sync(relative_ipynb_path)
  local address = NEOPYTER_DEFAULT_ADDRESS
  local ok_neopyter, neopyter = pcall(require, "neopyter")
  if ok_neopyter and type(neopyter.config) == "table" and type(neopyter.config.remote_address) == "string" then
    address = neopyter.config.remote_address
  end

  local busy, owner_pid = neopyter_port_busy_by_other_nvim(address)
  if busy then
    vim.notify(
      "Neopyter address " .. address .. " is used by another Neovim (pid " .. owner_pid .. ")",
      vim.log.levels.ERROR
    )
    vim.notify("Close that session or run :Neopyter disconnect there, then retry <leader>jo.", vim.log.levels.WARN)
    return false
  end

  pcall(vim.cmd, "Neopyter disconnect")

  local ok_connect, connect_err = pcall(vim.cmd, "Neopyter connect " .. address)
  if not ok_connect then
    vim.notify("Neopyter connect failed: " .. tostring(connect_err), vim.log.levels.ERROR)
    return false
  end

  for _ = 1, 60 do
    vim.wait(200)
    if neopyter_connected() then
      local ok_sync = pcall(vim.cmd, "Neopyter sync " .. vim.fn.fnameescape(relative_ipynb_path))
      if ok_sync then
        vim.notify("Opened and synced " .. relative_ipynb_path, vim.log.levels.INFO)
        return true
      end

      local ok_sync_current = pcall(vim.cmd, "Neopyter sync current")
      if ok_sync_current then
        vim.notify("Opened and synced current notebook tab", vim.log.levels.INFO)
        return true
      end

      vim.notify("Neopyter connected but sync failed", vim.log.levels.ERROR)
      return false
    end
  end

  vim.notify(
    "Timed out waiting for Neopyter browser connection (check if another Neovim session already uses " .. address .. ")",
    vim.log.levels.ERROR
  )
  return false
end

function M.setup_project_venv()
  local python = python312()
  if not python then
    vim.notify("python3.12 was not found on PATH", vim.log.levels.ERROR)
    return
  end

  local cwd = vim.fn.getcwd()
  local venv_dir = cwd .. "/.venv"

  if vim.fn.isdirectory(venv_dir) ~= 1 then
    local ok, output = run_system({ python, "-m", "venv", venv_dir })
    if not ok then
      vim.notify("Creating .venv failed: " .. trim_or_default(output), vim.log.levels.ERROR)
      return
    end
  end

  local venv_python = venv_dir .. "/bin/python"
  local ok_pip, pip_output = run_system({ venv_python, "-m", "pip", "install", "--upgrade", "pip" })
  if not ok_pip then
    vim.notify("Upgrading pip in .venv failed: " .. trim_or_default(pip_output), vim.log.levels.ERROR)
    return
  end

  local ok_kernel, kernel_output = run_system({ venv_python, "-m", "pip", "install", "ipykernel" })
  if not ok_kernel then
    vim.notify("Installing ipykernel in .venv failed: " .. trim_or_default(kernel_output), vim.log.levels.ERROR)
    return
  end

  local project_name = vim.fn.fnamemodify(cwd, ":t")
  local kernel_name = sanitize_kernel_name(project_name .. "-py312")
  local display_name = "Python 3.12 (" .. project_name .. ")"

  local ok_register, register_output = run_system({
    venv_python,
    "-m",
    "ipykernel",
    "install",
    "--user",
    "--name",
    kernel_name,
    "--display-name",
    display_name,
  })

  if not ok_register then
    vim.notify("Registering Jupyter kernel failed: " .. trim_or_default(register_output), vim.log.levels.ERROR)
    return
  end

  local activate_fish = venv_dir .. "/bin/activate.fish"
  if vim.fn.executable("fish") == 1 and vim.fn.filereadable(activate_fish) == 1 then
    local activation_cmd = "source " .. vim.fn.shellescape(activate_fish) .. "; exec fish"
    vim.cmd("botright split")
    vim.cmd("terminal fish -ic " .. vim.fn.shellescape(activation_cmd))
  end

  vim.notify(".venv ready. Kernel installed as '" .. kernel_name .. "'.", vim.log.levels.INFO)
end

function M.save_current_as_ipynb()
  local paths, err = notebook_paths_from_current_buffer()
  if not paths then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local relative_name = vim.fn.fnamemodify(paths.ipynb_path, ":t")
  local ok_sync = pcall(vim.cmd, "Neopyter sync " .. vim.fn.fnameescape(relative_name))
  if not ok_sync then
    vim.notify("Neopyter sync failed", vim.log.levels.ERROR)
    return
  end

  vim.defer_fn(function()
    local ok_save = pcall(vim.cmd, "Neopyter execute docmanager:save")
    if not ok_save then
      vim.notify("Notebook save failed", vim.log.levels.ERROR)
      return
    end

    vim.notify("Notebook saved as " .. relative_name .. " (with outputs)", vim.log.levels.INFO)
  end, 250)
end

function M.convert_current_ipynb_to_ju()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.ERROR)
    return
  end

  if buffer_path:match("%.ju%.[^%.]+$") then
    vim.notify("Current file is already a .ju.* notebook source", vim.log.levels.INFO)
    return
  end

  if not buffer_path:match("%.ipynb$") then
    vim.notify("Current file is not an .ipynb notebook", vim.log.levels.ERROR)
    return
  end

  local python = python312()
  if not python then
    vim.notify("python3.12 was not found on PATH", vim.log.levels.ERROR)
    return
  end

  local output_path = buffer_path:gsub("%.ipynb$", ".ju.py")
  local ok, output = run_system({
    python,
    "-m",
    "jupytext",
    "--to",
    "py:percent",
    buffer_path,
    "-o",
    output_path,
  })

  if not ok then
    vim.notify("Failed to convert notebook: " .. trim_or_default(output), vim.log.levels.ERROR)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(output_path))
  vim.notify("Converted and opened " .. vim.fn.fnamemodify(output_path, ":."), vim.log.levels.INFO)
end

function M.open_current_notebook()
  local python = python312()
  if not python then
    vim.notify("python3.12 was not found on PATH", vim.log.levels.ERROR)
    return
  end

  local paths, err = notebook_paths_from_current_buffer()
  if not paths then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  if paths.is_ju_source then
    refresh_ipynb_from_ju(python, paths.source_path, paths.ipynb_path)
  end

  local server = ensure_server_for_notebook(python, paths.ipynb_path)
  if not server then
    vim.notify("Could not find or start JupyterLab server", vim.log.levels.ERROR)
    return
  end

  local rel_path = relative_notebook_path(paths.ipynb_path, server)
  local url = notebook_url(server, rel_path)

  if not open_in_qutebrowser(url) then
    return
  end

  connect_and_sync(rel_path)
end

function M.setup()
  if M._setup_done then
    return true
  end

  vim.api.nvim_create_user_command("JupyterVenvSetup", M.setup_project_venv, {
    desc = "Create .venv, install ipykernel, register kernel",
  })

  vim.api.nvim_create_user_command("JupyterSaveIpynb", M.save_current_as_ipynb, {
    desc = "Sync and save current notebook as .ipynb",
  })

  vim.api.nvim_create_user_command("JupyterConvertToJu", M.convert_current_ipynb_to_ju, {
    desc = "Convert current .ipynb to .ju.py and open it",
  })

  vim.api.nvim_create_user_command("JupyterOpenNotebook", M.open_current_notebook, {
    desc = "Open current notebook in qutebrowser and sync with Neopyter",
  })

  M._setup_done = true
  return true
end

return M
