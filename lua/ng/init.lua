local req = require('ng.requests')

local tcb_content_provider = {
  _buffer = nil,
  _uri = nil,
  _ns = nil,

  update = function(self, uri, content)
    if not self._buffer or not vim.api.nvim_buf_is_loaded(self._buffer) then
      self._buffer = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(self._buffer, 'buftype', 'nofile')
      self._ns = vim.api.nvim_create_namespace('ng.nvim')
    end

    -- TODO: find a better way to do this (if it's even needed)
    uri = tostring(uri):gsub('file:///', 'ng:///')
    if self._uri ~= uri then
      self._uri = uri
      vim.api.nvim_buf_set_name(self._buffer, self._uri)
      vim.api.nvim_buf_set_option(self._buffer, 'filetype', 'typescript')
    end

    vim.api.nvim_buf_set_lines(self._buffer, 0, -1, false, vim.fn.split(content, '\n'))
    vim.api.nvim_buf_set_option(self._buffer, 'modified', false)
  end,

  show = function(self, ranges)
    vim.cmd.tabnew(self._uri)
    if ranges and #ranges ~= 0 then
      for _, range in ipairs(ranges) do
        vim.highlight.range(
          self._buffer,
          self._ns,
          'Visual',
          { range.start.line, range.start.character },
          { range['end'].line, range['end'].character }
        )
      end

      vim.api.nvim_win_set_cursor(0, { ranges[1].start.line + 1, ranges[1].start.character })
    end
  end,
}

local M = {}

local function get_base(filename)
  -- enlève .ts, .html, ou .spec.ts à la fin pour obtenir le préfixe commun
  return filename:gsub('%.component%.spec%.ts$', '.component')
                :gsub('%.component%.ts$', '.component')
                :gsub('%.component%.html$', '.component')
end

M.goto_component_ts = function()
  local filename = vim.api.nvim_buf_get_name(0)
  local base = get_base(filename)
  local ts = base .. '.ts'
  if vim.fn.filereadable(ts) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(ts))
  else
    vim.notify('.ts non trouvé : ' .. ts, vim.log.levels.INFO)
  end
end

M.goto_component_html = function()
  local filename = vim.api.nvim_buf_get_name(0)
  local base = get_base(filename)
  local html = base .. '.html'
  if vim.fn.filereadable(html) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(html))
  else
    vim.notify('.html non trouvé : ' .. html, vim.log.levels.INFO)
  end
end

M.goto_component_spec = function()
  local filename = vim.api.nvim_buf_get_name(0)
  local base = get_base(filename)
  local spec = base .. '.spec.ts'
  if vim.fn.filereadable(spec) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(spec))
  else
    vim.notify('.spec.ts non trouvé : ' .. spec, vim.log.levels.INFO)
  end
end

return M
