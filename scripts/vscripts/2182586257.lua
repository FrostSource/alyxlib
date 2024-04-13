-- Some addons search the vscripts root for workshop IDs, but overwrite core/coreinit.lua, thus preventing Scalable Init Support from initializing if it doesn't have priority
-- This file allows Scalable Init Support to successfully initialize in such a context; using require() ensures the file is only called once

require("core/scalableinit")