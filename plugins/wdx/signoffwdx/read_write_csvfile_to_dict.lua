-- read_write_csvfile_to_dict.lua (cross-platform)
-- 2023.04.14

function ReadCSVFileToDict(CSVFilePath)
  local result = {}
  local CSVFile = io.open(CSVFilePath, 'r')
  if CSVFile ~= nil then
    for line in CSVFile:lines() do
      local tokens = split(line, ",")
      if #tokens > 0 then
        local filepathkey = table.remove(tokens, 1)
        if #tokens == 0 then
          result[filepathkey] = ""
        else
          result[filepathkey] = tokens[1] .. '(' .. tokens[2] .. ',' .. tokens[3] .. ')'
        end
      end
    end
    CSVFile:close()
  end
  return result
end

function WriteCSDictToFile(CSVDict,CSVFilePath)
  local CSVFile = io.open(CSVFilePath, 'w+')
  if CSVFile ~= nil then
    if getTableSize(CSVDict) == 0 then
      CSVFile:write('\n')
    else
      r = {}
      c = 1
      for k, v in pairs(CSVDict) do
        if v ~= "" then
          local tokens = split(v, ",()")
          r[c] = k .. "," .. table.concat(tokens, ",")
          c = c + 1
        end
      end
      CSVFile:write(table.concat(r, '\n') .. '\n')
    end
    CSVFile:close()
  end
end

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function getTableSize(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

function createHiddenFolder(folder_path)
  local command
  if package.config:sub(1, 1) == "\\" then
      -- Windows
      command = "mkdir " .. folder_path .. " && attrib +h " .. folder_path
  else
      -- Unix-like systems (Linux, macOS, etc.)
      local hidden_folder_path = folder_path:gsub("([^/]+)$", ".%1")
      command = "mkdir -p " .. hidden_folder_path
  end
  os.execute(command)
end

function getDirectoryPath(file_path)
  return file_path:match("(.*[/\\])")
end