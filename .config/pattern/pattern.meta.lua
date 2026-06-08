---@meta

---@class Pattern
pattern = {}

---Allows you to add bindings.
---@param keys string The key chord (e.g., "SUPER + Q")
---@param cb fun() The action to execute when triggered
---@param opts? table Additional bind options
function pattern.bind(keys, cb, opts) end

---Add a function to execute to this hook function list.
---@param hook_name "@start"|string The hook's name (e.g., "@start")
---@param cb fun() function to execute
function pattern.on(hook_name, cb) end

---Adding or updating a field to the configuration fragments.
---@param fragment table The configuration parameters to apply.
function pattern.config(fragment) end

---@class InputConfig
---@field kb_layout string The keyboard layout (e.g., "be", "us", "de").
---@field kb_variant string The keyboard layout variant (e.g., "oss").
---@field kb_model? string The hardware keyboard model.
---@field kb_rules? string Rules for the keyboard layout.
---@field repeat_rate? number Key repeat rate in Hz.
---@field repeat_delay? number Delay before key repeat begins, in milliseconds.
---@field sensitivity? number Pointer sensitivity multiplier, (-1.0..=1.0) 0 means no modification
---@field touchpad? InputTouchpadConfig Touchpad-specific configuration.
---@field gestures? InputGesturesConfig Gesture-specific configuration.

---@class InputTouchpadConfig
---@field natural_scroll? boolean Inverts the scroll direction to match physical movement.
---@field disable_while_typing? boolean Prevents touchpad input while the keyboard is active.

---@class InputGesturesConfig
---@field workspace_swipe_invert boolean Inverts the direction of workspace swipe gestures.
---@field workspace_swipe_threshold? number The delta threshold in pixels to trigger a workspace switch on swipe.

---Registering or updating a gesture (keyed by fingers count).
---@param config GestureConfig Gesture configuration parameters.
function pattern.gesture(config) end

---@class GestureConfig
---@field fingers number Number of fingers that trigger the gesture (required).
---@field direction? "horizontal"|"vertical" Direction to swipe.
---@field action? "workspace" Action to trigger upon completion.

---Execute a new shell command.
---@param cmd string The command to run (e.g., "seekr").
function pattern.exec_cmd(cmd) end

---Dispatch an action.
---@param action_cb fun() The action to execute.
function pattern.dispatch(action_cb) end

---@class DefinedActions
---Predefined actions.
pattern.actions = {}

---Focus a workspace directly
---@param opts {id?: number, workspace?: number, next?: boolean, previous?: boolean} Workspace focus options.
---@return fun() Callback function that performs the workspace focus action.
function pattern.actions.focus(opts) end

---@class DefinedWindowActions
---Defined window actions
pattern.actions.window = {}

---Close a window
---@param id? number Specify the window id or leave empty for the focused one
---@return fun() Callback function that performs the close action.
function pattern.actions.window.close(id) end

---Toggle or set window fullscreen
---@param opts? {id?: number, toggle?: boolean, value?: boolean} Fullscreen configuration options.
---@return fun() Callback function that performs the fullscreen action.
function pattern.actions.window.fullscreen(opts) end

---Move a window to a workspace
---@param opts {workspace: number, id?: number} Workspace move options (workspace is 1-indexed, id defaults to focused window).
---@return fun() Callback function that performs the move action.
function pattern.actions.window.move(opts) end

---Initiate window dragging with the mouse
---@return fun() Callback function that begins window dragging.
function pattern.actions.window.drag() end

---Initiate window resizing with the mouse
---@return fun() Callback function that begins window resizing.
function pattern.actions.window.resize() end

---@class DefinedWorkspaceActions
---Defined workspace actions
pattern.actions.workspace = {}

---Focus a workspace
---@param opts {id?: number, workspace?: number, next?: boolean, previous?: boolean} Workspace focus options.
---@return fun() Callback function that performs the workspace focus action.
function pattern.actions.workspace.focus(opts) end

---Quits the compositor.
---@return fun() Callback function that performs the quit action.
function pattern.actions.quit() end

---Action to execute a new shell command.
---@param cmd string The command to run (e.g., "seekr").
---@return fun() Callback function that executes the given command.
function pattern.actions.exec_cmd(cmd) end
