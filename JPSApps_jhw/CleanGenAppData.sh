find JPSApplication/Logs -maxdepth 3 -type f -name "*.log" -delete
find JPSApplication/Resources -maxdepth 3 -type f -name "*.fdb" -delete
find JPSApplication/Resources -maxdepth 3 -type f -name "*.lay" -delete
find JPSApplication/Resources -maxdepth 3 -type f -name "*.dat" -delete
find JPSApplication/Resources -maxdepth 3 -type f -name "*.roi" -delete

find JPSDemoLua_TestCase/Logs -maxdepth 3 -type f -name "*.log" -delete
find JPSDemoLua_TestCase/Resources -maxdepth 3 -type f -name "*.fdb" -delete
find JPSDemoLua_TestCase/Resources -maxdepth 3 -type f -name "*.lay" -delete
find JPSDemoLua_TestCase/Resources -maxdepth 3 -type f -name "*.dat" -delete
find JPSDemoLua_TestCase/Resources -maxdepth 3 -type f -name "*.roi" -delete

read -p "Press [Enter] key continue..."
