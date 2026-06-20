-----------------------------------------------------------
-- C/C++ Exam Training Mode
--
-- Provides a plain editing mode for handwritten exam practice:
-- no LSP, diagnostics, syntax highlighting, completion, snippets,
-- Copilot suggestions, auto-pairs, auto-linting, or formatting helpers.
-----------------------------------------------------------

local M = {}

local cpp_filetypes = {
  c = true,
  cpp = true,
}

local function normalize_bufnr(bufnr)
  if not bufnr or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end

  return bufnr
end

local function is_cpp_buffer(bufnr)
  bufnr = normalize_bufnr(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr) and cpp_filetypes[vim.bo[bufnr].filetype] == true
end

local function get_diagnostic_enabled(bufnr)
  if not vim.diagnostic or not vim.diagnostic.is_enabled then
    return true
  end

  local ok, enabled = pcall(vim.diagnostic.is_enabled, { bufnr = bufnr })
  if not ok then
    return true
  end

  return enabled
end

local function save_state(bufnr)
  local buffer_vars = vim.b[bufnr]
  if type(buffer_vars.cpp_training_state) == "table" then
    return buffer_vars.cpp_training_state
  end

  local state = {
    completefunc = vim.bo[bufnr].completefunc,
    copilot_enabled = buffer_vars.copilot_enabled,
    copilot_suggestion_hidden = buffer_vars.copilot_suggestion_hidden,
    cindent = vim.bo[bufnr].cindent,
    diagnostic_enabled = get_diagnostic_enabled(bufnr),
    disable_autolint = buffer_vars.disable_autolint,
    formatexpr = vim.bo[bufnr].formatexpr,
    indentexpr = vim.bo[bufnr].indentexpr,
    minicursorword_disable = buffer_vars.minicursorword_disable,
    minipairs_disable = buffer_vars.minipairs_disable,
    omnifunc = vim.bo[bufnr].omnifunc,
    smartindent = vim.bo[bufnr].smartindent,
    syntax = vim.bo[bufnr].syntax,
    tagfunc = vim.bo[bufnr].tagfunc,
  }

  buffer_vars.cpp_training_state = state
  return state
end

local function set_buffer_var(bufnr, name, value)
  vim.b[bufnr][name] = value
end

local function stop_lsp(bufnr)
  if not vim.lsp or not vim.lsp.get_clients then
    return
  end

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.lsp.buf_detach_client then
      pcall(vim.lsp.buf_detach_client, bufnr, client.id)
    end

    if type(client.stop) == "function" then
      pcall(function()
        client:stop()
      end)
    end
  end
end

local function disable_diagnostics(bufnr)
  if not vim.diagnostic then
    return
  end

  if vim.diagnostic.enable then
    pcall(vim.diagnostic.enable, false, { bufnr = bufnr })
  elseif vim.diagnostic.disable then
    pcall(vim.diagnostic.disable, bufnr)
  end

  pcall(vim.diagnostic.reset, nil, bufnr)
end

local function restore_diagnostics(bufnr, state)
  if not vim.diagnostic then
    return
  end

  local enabled = state.diagnostic_enabled ~= false
  if vim.diagnostic.enable then
    pcall(vim.diagnostic.enable, enabled, { bufnr = bufnr })
  end
end

function M.enable_buffer(bufnr)
  bufnr = normalize_bufnr(bufnr)
  if not is_cpp_buffer(bufnr) then
    return false
  end

  save_state(bufnr)

  set_buffer_var(bufnr, "cpp_training_mode", true)
  set_buffer_var(bufnr, "disable_autolint", true)
  set_buffer_var(bufnr, "minicursorword_disable", true)
  set_buffer_var(bufnr, "minipairs_disable", true)
  set_buffer_var(bufnr, "copilot_enabled", false)
  set_buffer_var(bufnr, "copilot_suggestion_hidden", true)

  vim.bo[bufnr].completefunc = ""
  vim.bo[bufnr].formatexpr = ""
  vim.bo[bufnr].indentexpr = ""
  vim.bo[bufnr].omnifunc = ""
  vim.bo[bufnr].smartindent = false
  vim.bo[bufnr].cindent = false
  vim.bo[bufnr].tagfunc = ""

  if vim.treesitter and vim.treesitter.stop then
    pcall(vim.treesitter.stop, bufnr)
  end

  vim.bo[bufnr].syntax = "OFF"

  if vim.lsp and vim.lsp.inlay_hint then
    pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
  end

  if package.loaded["cmp"] then
    local ok, cmp = pcall(require, "cmp")
    if ok then
      pcall(cmp.abort)
    end
  end

  if package.loaded["copilot.suggestion"] then
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if ok and type(suggestion.dismiss) == "function" then
      pcall(suggestion.dismiss)
    end
  end

  disable_diagnostics(bufnr)
  stop_lsp(bufnr)

  return true
end

function M.disable_buffer(bufnr)
  bufnr = normalize_bufnr(bufnr)

  local buffer_vars = vim.b[bufnr]
  local state = buffer_vars.cpp_training_state
  if type(state) ~= "table" then
    return false
  end

  set_buffer_var(bufnr, "cpp_training_mode", nil)
  set_buffer_var(bufnr, "disable_autolint", state.disable_autolint)
  set_buffer_var(bufnr, "minicursorword_disable", state.minicursorword_disable)
  set_buffer_var(bufnr, "minipairs_disable", state.minipairs_disable)
  set_buffer_var(bufnr, "copilot_enabled", state.copilot_enabled)
  set_buffer_var(bufnr, "copilot_suggestion_hidden", state.copilot_suggestion_hidden)

  vim.bo[bufnr].completefunc = state.completefunc
  vim.bo[bufnr].formatexpr = state.formatexpr
  vim.bo[bufnr].indentexpr = state.indentexpr
  vim.bo[bufnr].omnifunc = state.omnifunc
  vim.bo[bufnr].smartindent = state.smartindent
  vim.bo[bufnr].cindent = state.cindent
  vim.bo[bufnr].syntax = (state.syntax ~= "" and state.syntax ~= "OFF") and state.syntax
    or vim.bo[bufnr].filetype
  vim.bo[bufnr].tagfunc = state.tagfunc

  restore_diagnostics(bufnr, state)

  if vim.treesitter and vim.treesitter.start then
    pcall(vim.treesitter.start, bufnr)
  end

  set_buffer_var(bufnr, "cpp_training_state", nil)
  return true
end

local function apply_to_cpp_buffers(callback)
  local count = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if is_cpp_buffer(bufnr) and callback(bufnr) then
      count = count + 1
    end
  end

  return count
end

function M.enable()
  vim.g.cpp_training_mode = true
  local count = apply_to_cpp_buffers(M.enable_buffer)
  local suffix = count > 0 and (" for " .. count .. " C/C++ buffer(s)") or ""
  vim.notify("C/C++ training mode enabled" .. suffix, vim.log.levels.INFO)
end

function M.disable()
  vim.g.cpp_training_mode = false
  local count = 0

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[bufnr].cpp_training_mode == true and M.disable_buffer(bufnr) then
      count = count + 1
    end
  end

  if is_cpp_buffer(0) then
    pcall(vim.cmd, "LspStart clangd")
  end

  local suffix = count > 0 and (" for " .. count .. " C/C++ buffer(s)") or ""
  vim.notify("C/C++ training mode disabled" .. suffix, vim.log.levels.INFO)
end

function M.toggle()
  if vim.g.cpp_training_mode == true then
    M.disable()
  else
    M.enable()
  end
end

function M.setup()
  vim.g.cpp_training_mode = vim.g.cpp_training_mode == true

  local group = vim.api.nvim_create_augroup("CppTrainingMode", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "LspAttach" }, {
    group = group,
    pattern = "*",
    callback = function(event)
      if vim.g.cpp_training_mode ~= true then
        return
      end

      if is_cpp_buffer(event.buf) then
        M.enable_buffer(event.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("Syntax", {
    group = group,
    pattern = "*",
    callback = function(event)
      if vim.g.cpp_training_mode == true
        and vim.b[event.buf].cpp_training_mode == true
        and is_cpp_buffer(event.buf)
        and vim.bo[event.buf].syntax ~= "OFF"
      then
        vim.bo[event.buf].syntax = "OFF"
      end
    end,
  })

  vim.api.nvim_create_user_command("CppTrainingMode", M.toggle, {
    desc = "Toggle C/C++ exam training mode",
    force = true,
  })

  if vim.g.cpp_training_mode == true then
    apply_to_cpp_buffers(M.enable_buffer)
  end

  return true
end

return M
