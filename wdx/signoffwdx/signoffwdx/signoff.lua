-- signoff.lua (cross-platform)
-- 2023.04.14

require('read_write_csvfile_to_dict')

local fields = {
  "Signoff By",
  "Reviewed By",
  "Approved By"
}

local params = {...}
local CSVDict = {}
local lu = {}

-- Check if a folder exists
function FolderExists(folderPath)
  local file = io.open(folderPath, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

-- Create a hidden folder in the given directory if it doesn't exist
-- function CreateHiddenFolderIfNotExist(directory, folderName)
--   local fullPath = directory .. '\\' .. folderName
--   if not FolderExists(fullPath) then
--     os.execute('mkdir "' .. fullPath .. '"')
--     os.execute('attrib +h "' .. fullPath .. '"')
--     print("Hidden folder created: " .. fullPath)
--   else
--     print("Folder already exists: " .. fullPath)
--   end
--   return fullPath
-- end

if #params == 0 then
  Dialogs.MessageBox('Check parameters!', 'signoff.lua', 0x0030)
  return
end

-- hiddenPath = CreateHiddenFolderIfNotExist(DC.GetActivePanelPath(),"dblcmd_hidden")
local sn = debug.getinfo(1).source
if string.sub(sn, 1, 1) == '@' then sn = string.sub(sn, 2, -1) end
fname = string.lower(fields[tonumber(params[2])])
fname = string.gsub(fname, " ", "_")
dbName = SysUtils.ExtractFilePath(sn) .. fname .. '.csv'

if CSVDict[fields[tonumber(params[2])]] == nil then
  CSVDict[fields[tonumber(params[2])]] = ReadCSVFileToDict(dbName)
end

h, err = io.open(params[3], 'r')
if h == nil then
  Dialogs.MessageBox('Error 2: ' .. err, 'signoff.lua', 0x0030)
  return
end
c = 1
for l in h:lines() do
  lu[c] = l
  c = c + 1
end
h:close()
if #lu == 0 then
  Dialogs.MessageBox('Error 3', 'signoff.lua', 0x0030)
  return
end

if params[1] == '--update' then
  result, userinput = Dialogs.InputQuery('signoff.lua', fields[tonumber(params[2])], false, '')
  if result == false then return end
  for i = 1, #lu do
    CSVDict[fields[tonumber(params[2])]][lu[i]] = userinput .. " " .. os.date("%d/%m/%Y")
  end
elseif params[1] == '--remove' then
  for i = 1, #lu do
    CSVDict[fields[tonumber(params[2])]][lu[i]] = ""
  end
end

if CSVDict[fields[tonumber(params[2])]] ~= nil then
  WriteCSDictToFile(CSVDict[fields[tonumber(params[2])]],dbName)
end

os.setenv('SignOffDB' .. fname, 'Read')

if params[4] == '--auto' then
  DC.ExecuteCommand('cm_Refresh')
end