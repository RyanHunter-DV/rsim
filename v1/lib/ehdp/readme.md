Error handling and dispatch processing dir, storing objects for error processing and threads control.
# Feature list
## Error handling
**User nodes errors**
- Direct errors, like using commands or options illegally.
- Indirect errors, normal config combinations but caused an error.
- Unpredict errors.
**User option errors**
- Use options illegally.
- Illegal combination of options.
**
#TODO
## Threads control and multiple threads
**Main threads cancelling with CTRL-C or other kill operations**
#TODO
Threads are treated as steps, the steps has concepts of dependency, ...

---
# DispatchManager
The main object used by Rsim module, and then passed to plugin manager, this is the direct API object that all calling the major feature shall be through this object.
