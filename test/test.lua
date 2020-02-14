local test_files =
{
    -- "test_misc",
    "test_field",
    "test_static",
}

for i = 1, #test_files do
    local file = test_files[i]
    dofile(file .. ".lua")
    print(file .. " done.")
end