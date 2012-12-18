-- luajit ffi based bindings for gphoto2
-- http://www.gphoto.org/

local ffi = require"ffi"

ffi.cdef[[

	typedef enum 
	{
		GP_CAPTURE_IMAGE = 0,	
		GP_CAPTURE_MOVIE = 1,	
		GP_CAPTURE_SOUND = 2	
	} CameraCaptureType;

	typedef enum 
	{
		GP_DRIVER_STATUS_PRODUCTION = 0,	/**< Driver is production ready. */
		GP_DRIVER_STATUS_TESTING = 1,		/**< Driver is beta quality. */
		GP_DRIVER_STATUS_EXPERIMENTAL = 2,	/**< Driver is alpha quality and might even not work. */
		GP_DRIVER_STATUS_DEPRECATED = 3		/**< Driver is no longer recommended to use and will be removed. */
	} CameraDriverStatus;

	typedef enum 
	{
			GP_DEVICE_STILL_CAMERA          = 0,	 /**< Traditional still camera */
			GP_DEVICE_AUDIO_PLAYER          = 1 << 0 /**< Audio player */
	} GphotoDeviceType;

	typedef enum 
	{
			GP_OPERATION_NONE       		= 0,	  /**< No remote control operation supported. */
			GP_OPERATION_CAPTURE_IMAGE      = 1 << 0, /**< Capturing images supported. */
			GP_OPERATION_CAPTURE_VIDEO      = 1 << 1, /**< Capturing videos supported. */
			GP_OPERATION_CAPTURE_AUDIO      = 1 << 2, /**< Capturing audio supported. */
			GP_OPERATION_CAPTURE_PREVIEW    = 1 << 3, /**< Capturing image previews supported. */
			GP_OPERATION_CONFIG             = 1 << 4, /**< Camera and Driver configuration supported. */
			GP_OPERATION_TRIGGER_CAPTURE    = 1 << 5  /**< Camera can trigger capture and wait for events. */
	} CameraOperation;

	typedef enum 
	{
			GP_FILE_OPERATION_NONE          = 0,      /**< No special file operations, just download. */
			GP_FILE_OPERATION_DELETE        = 1 << 1, /**< Deletion of files is possible. */
			GP_FILE_OPERATION_PREVIEW       = 1 << 3, /**< Previewing viewfinder content is possible. */
			GP_FILE_OPERATION_RAW           = 1 << 4, /**< Raw retrieval is possible (used by non-JPEG cameras) */
			GP_FILE_OPERATION_AUDIO         = 1 << 5, /**< Audio retrieval is possible. */
			GP_FILE_OPERATION_EXIF          = 1 << 6  /**< EXIF retrieval is possible. */
	} CameraFileOperation;

	typedef enum 
	{
			GP_FOLDER_OPERATION_NONE        = 0,	  /**< No special filesystem operation. */
			GP_FOLDER_OPERATION_DELETE_ALL  = 1 << 0, /**< Deletion of all files on the device. */
			GP_FOLDER_OPERATION_PUT_FILE    = 1 << 1, /**< Upload of files to the device possible. */
			GP_FOLDER_OPERATION_MAKE_DIR    = 1 << 2, /**< Making directories on the device possible. */
			GP_FOLDER_OPERATION_REMOVE_DIR  = 1 << 3  /**< Removing directories from the device possible. */
	} CameraFolderOperation;

	typedef enum
	{ 
		GP_PORT_NONE			=      0,	/**< \brief No specific type associated. */
		GP_PORT_SERIAL			= 1 << 0,	/**< \brief Serial port. */
		GP_PORT_USB				= 1 << 2,	/**< \brief USB port. */
		GP_PORT_DISK			= 1 << 3,	/**< \brief Disk / local mountpoint port. */
		GP_PORT_PTPIP			= 1 << 4,	/**< \brief PTP/IP port. */
		GP_PORT_USB_DISK_DIRECT = 1 << 5,	/**< \brief Direct IO to an usb mass storage device. */
		GP_PORT_USB_SCSI		= 1 << 6	/**< \brief USB Mass Storage raw SCSI port. */
	} GPPortType;

	typedef enum 
	{	
		GP_WIDGET_WINDOW = 0,	/**< \brief Window widget
		GP_WIDGET_SECTION = 1,	/**< \brief Section widget (think Tab) */
		GP_WIDGET_TEXT = 2,		/**< \brief Text widget. */						/* char *		*/
		GP_WIDGET_RANGE = 3,	/**< \brief Slider widget. */					/* float		*/
		GP_WIDGET_TOGGLE = 4,	/**< \brief Toggle widget (think check box) */	/* int			*/
		GP_WIDGET_RADIO = 5,	/**< \brief Radio button widget. */				/* char *		*/
		GP_WIDGET_MENU = 6,		/**< \brief Menu widget (same as RADIO). */		/* char *		*/
		GP_WIDGET_BUTTON = 7,	/**< \brief Button press widget. */				/* CameraWidgetCallback */
		GP_WIDGET_DATE = 8		/**< \brief Date entering widget. */			/* int			*/
	} CameraWidgetType;

	typedef enum {
		GP_EVENT_UNKNOWN = 0,			/**< unknown and unhandled event */
		GP_EVENT_TIMEOUT = 1,			/**< timeout, no arguments */
		GP_EVENT_FILE_ADDED = 2,		/**< CameraFilePath* = file path on camfs */
		GP_EVENT_FOLDER_ADDED = 3,		/**< CameraFilePath* = folder on camfs */
		GP_EVENT_CAPTURE_COMPLETE = 4	/**< last capture is complete */
	} CameraEventType;

	typedef struct
	{
		char name [128];	
		char folder [1024];
	} CameraFilePath;

	typedef struct 
	{
		char text [32 * 1024]; /**< \brief Character string containing the translated text. */
	} CameraText;

	typedef struct 
	{
        char model [128];			// Name of camera model
        CameraDriverStatus status;	// Driver quality
		
		GPPortType port; // Supported port types
        int speed [64]; // Supported serial port speeds (terminated with a value of 0)

		// Supported operations
        CameraOperation       operations;
        CameraFileOperation   file_operations;
        CameraFolderOperation folder_operations;

		int usb_vendor;		// USB Vendor ID
		int usb_product;	// USB Product ID
		int usb_class;      // USB device class
		int usb_subclass;	// USB device subclass
		int usb_protocol;	// USB device protocol

		// Internal
		char library[1024];
		char id[1024];	

		GphotoDeviceType device_type;

		int reserved2;
		int reserved3;
		int reserved4;
		int reserved5;
		int reserved6;
		int reserved7;
		int reserved8;
	} CameraAbilities;

	typedef struct _CameraAbilitiesList CameraAbilitiesList;

	typedef struct _GPContext GPContext;
	typedef struct _Camera Camera;
	typedef struct _CameraWidget CameraWidget;
	
	const char* gp_port_result_as_string (int result);	

	GPContext* gp_context_new();
	int gp_camera_new(Camera** camera);
	int gp_camera_init(Camera* camera, GPContext* context);
	int gp_camera_exit(Camera* camera, GPContext* context);
	//int gp_camera_autodetect(CameraList *list, GPContext *context);

	int gp_camera_capture(Camera* camera, CameraCaptureType type, CameraFilePath* path, GPContext* context);

	int gp_camera_set_abilities(Camera* camera, CameraAbilities abilities);
	int gp_camera_get_abilities(Camera* camera, CameraAbilities* abilities);
	//int gp_camera_set_port_info(Camera* camera, GPPortInfo info);
	//int gp_camera_get_port_info(Camera* camera, GPPortInfo *info);

	int gp_camera_get_config(Camera* camera, CameraWidget** window, GPContext* context);
	int gp_camera_set_config(Camera* camera, CameraWidget* window, GPContext* context);
	int gp_camera_get_summary(Camera* camera, CameraText* text, GPContext* context);



	typedef int (* CameraWidgetCallback) (Camera *, CameraWidget *, GPContext *);

int 	gp_widget_new 	(CameraWidgetType type, const char *label, 
		         CameraWidget **widget);
int    	gp_widget_free 	(CameraWidget *widget);
int     gp_widget_ref   (CameraWidget *widget);
int     gp_widget_unref (CameraWidget *widget);

int	gp_widget_append	(CameraWidget *widget, CameraWidget *child);
int 	gp_widget_prepend	(CameraWidget *widget, CameraWidget *child);

int 	gp_widget_count_children     (CameraWidget *widget);
int	gp_widget_get_child	     (CameraWidget *widget, int child_number, 
				      CameraWidget **child);

/* Retrieve Widgets */
int	gp_widget_get_child_by_label (CameraWidget *widget,
				      const char *label,
				      CameraWidget **child);
int	gp_widget_get_child_by_id    (CameraWidget *widget, int id, 
				      CameraWidget **child);
int	gp_widget_get_child_by_name  (CameraWidget *widget,
                                      const char *name,
				      CameraWidget **child);
int	gp_widget_get_root           (CameraWidget *widget,
                                      CameraWidget **root);
int     gp_widget_get_parent         (CameraWidget *widget,
				      CameraWidget **parent);

int	gp_widget_set_value     (CameraWidget *widget, const void *value);
int	gp_widget_get_value     (CameraWidget *widget, void *value);

int     gp_widget_set_name      (CameraWidget *widget, const char  *name);
int     gp_widget_get_name      (CameraWidget *widget, const char **name);

int	gp_widget_set_info      (CameraWidget *widget, const char  *info);
int	gp_widget_get_info      (CameraWidget *widget, const char **info);

int	gp_widget_get_id	(CameraWidget *widget, int *id);
int	gp_widget_get_type	(CameraWidget *widget, CameraWidgetType *type);
int	gp_widget_get_label	(CameraWidget *widget, const char **label);

int	gp_widget_set_range	(CameraWidget *range, 
				 float  low, float  high, float  increment);
int	gp_widget_get_range	(CameraWidget *range, 
				 float *min, float *max, float *increment);

int	gp_widget_add_choice     (CameraWidget *widget, const char *choice);
int	gp_widget_count_choices  (CameraWidget *widget);
int	gp_widget_get_choice     (CameraWidget *widget, int choice_number, 
                                  const char **choice);

int	gp_widget_changed        (CameraWidget *widget);
int     gp_widget_set_changed    (CameraWidget *widget, int changed);

int     gp_widget_set_readonly   (CameraWidget *widget, int readonly);
int     gp_widget_get_readonly   (CameraWidget *widget, int *readonly);
]]

local libgphoto2 = ffi.load("gphoto2")
local context

local Results = {}
Results.Ok = 0
Results.Error = -1
Results.BadParameters = -2
Results.NoMemory = -3
Results.Library = -4
Results.UnknownPort = -5
Results.NotSupported = -6
Results.Io = -7
Results.FixedLimitExceeded = -8
Results.TimeOut = -10
Results.IoSupportedSerial = -20
Results.IoSupportedUsb = -21
Results.IoInit = -31
Results.IoRead = -34
Results.IoWrite = -35
Results.IoUpdate = -37
Results.IoSerialSpeed = -41
Results.IoUsbClearHalt = -51
Results.IoUsbFind = -52
Results.IoUsbClaim = -53
Results.IoLock = -60
Results.Hal = -70

local CameraCaptureType = {}
CameraCaptureType.Image = libgphoto2.GP_CAPTURE_IMAGE
CameraCaptureType.Movie = libgphoto2.GP_CAPTURE_MOVIE
CameraCaptureType.Sound = libgphoto2.GP_CAPTURE_SOUND

local CameraEvent = {}
CameraEvent.Unknown = libgphoto2.GP_EVENT_UNKNOWN
CameraEvent.Timeout = libgphoto2.GP_EVENT_TIMEOUT
CameraEvent.FileAdded = libgphoto2.GP_EVENT_FILE_ADDED
CameraEvent.FolderAdded = libgphoto2.GP_EVENT_FOLDER_ADDED
CameraEvent.CaptureComplete = libgphoto2.GP_EVENT_CAPTURE_COMPLETE

local widgetTypeLookup = {}
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_WINDOW)] = "window"
widgetTypeLookup[1] = "section"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_TEXT)] = "text"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_RANGE)] = "range"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_TOGGLE)] = "toggle"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_RADIO)] = "radio"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_MENU)] = "menu"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_BUTTON)] = "button"
widgetTypeLookup[tonumber(libgphoto2.GP_WIDGET_DATE)] = "date"

local function resultToString(result)
	return ffi.string(libgphoto2.gp_port_result_as_string(result))
end

local function lookupWidgetById(widget, id) 
	local child = ffi.new("CameraWidget*[1]")
	local status = libgphoto2.gp_widget_get_child_by_id(widget, id, child);
	if status ~= Results.Ok then error("Failed to find child widget '"..id.."': " .. resultToString(status)) end
	return child[0];
end

local function lookupWidgetByName(widget, name) 
	local child = ffi.new("CameraWidget*[1]")
	local status = libgphoto2.gp_widget_get_child_by_name(widget, name, child);
	if status ~= Results.Ok then error("Failed to find child widget '"..name.."': " .. resultToString(status)) end	
	return child[0]
end


Class = {}
function Class:new(super)
    local class, metatable, properties = {}, {}, {}
    class.metatable = metatable
    class.properties = properties

    function metatable:__index(key)
        local prop = properties[key]
        if prop then
            return prop.get(self)
        elseif class[key] ~= nil then
            return class[key]
        elseif super then
            return super.metatable.__index(self, key)
        else
            return nil
        end
    end

    function metatable:__newindex(key, value)
        local prop = properties[key]
        if prop then
            return prop.set(self, value)
        elseif super then
            return super.metatable.__newindex(self, key, value)
        else
            rawset(self, key, value)
        end
    end

    function class:new(...)
        local obj = setmetatable({}, self.metatable)
        if obj.__new then
            obj:__new(...)
        end
        return obj
    end

    return class
end

local Camera = Class:new()
function Camera:__new()
	self.handlePtr = ffi.new("Camera*[1]")
	local status = libgphoto2.gp_camera_new(self.handlePtr)
	if status ~= Results.Ok then error("Failed to acquire camera: " .. resultToString(status)) end

	self.handle = self.handlePtr[0]
	status = libgphoto2.gp_camera_init(self.handle, context)
	if status ~= Results.Ok then error("Failed to acquire camera: " .. resultToString(status)) end	

	local abilities = ffi.new("CameraAbilities")
	local status = libgphoto2.gp_camera_get_abilities(self.handle, abilities)
	if status ~= Results.Ok then error("Failed to get camera abilities: " .. resultToString(status)) end

	self.model = ffi.string(abilities.model)

	self:updateParameters()
end

function Camera:updateParameters()
	self.parameters = {}

	local widget = self:getRootWidget()
	self:parseParameters(widget, "")
	libgphoto2.gp_widget_free(widget)

	self.properties = {}
	for k,v in pairs(self.parameters) do
		if k ~= "aperture" then
			self:registerParameterProperty(k)
		end
	end

	self.autoApertureExists =  false
	local apertureInfo = self:getParameterInfo("aperture")
	if apertureInfo ~= nil then
		local lastAperture = 0

		for _,v in pairs(apertureInfo.apertureChoices) do
			local aperture = tonumber(v)
			if aperture ~= nil then
				local apertureSetting = {}
				apertureSetting.start = lastAperture
				apertureSetting.end = aperture
				apertureSetting.range = aperture - lastAperture
				
				table.insert(self.apertureChoices, apertureSetting)

				lastAperture = aperture
			else
				-- Not numeric!  Check to see if this is an auto value...
				if aperture == "Auto" then
					self.autoApertureExists = true
				else
					-- Error...
					warning("Unknown aperture setting '"..aperture.."'")
				end
			end
		end
	end

	self.autoShutterExists = false
end

function Camera:parseParameters(widget, parentName)
	local widgetType = ffi.new("CameraWidgetType[1]")
	local status = libgphoto2.gp_widget_get_type(widget, widgetType)
	if status ~= Results.Ok then error("Failed to get widget type: " .. resultToString(status)) end

	local name = ffi.new("const char*[1]")
	local status = libgphoto2.gp_widget_get_name(widget, name)
	if status ~= Results.Ok then error("Failed to get widget name: " .. resultToString(status)) end

	name = ffi.string(name[0])
	local fullName =  parentName..'/'..name

	if widgetType[0] ~= libgphoto2.GP_WIDGET_WINDOW and widgetType[0] ~= 1 then
		local id = ffi.new("int[1]")
		status = libgphoto2.gp_widget_get_id(widget, id)
		if status ~= Results.Ok then error("Failed to get widget ID: " .. resultToString(status)) end

		local label = ffi.new("const char*[1]")
		status = libgphoto2.gp_widget_get_label(widget, label)
		if status ~= Results.Ok then error("Failed to get widget label: " .. resultToString(status)) end

		local readOnly = ffi.new("int[1]")
		status = libgphoto2.gp_widget_get_readonly(widget, readOnly)
		if status ~= Results.Ok then error("Failed to get read only status: " .. resultToString(status)) end

		local ret = {}
		ret.name = name
		ret.fullName = fullName
		ret.type = tonumber(widgetType[0])
		ret.typeName = widgetTypeLookup[ret.type]
		ret.id = id[0]--tonumber(id[0])
		ret.label = ffi.string(label[0])
		if readOnly[0] == 0 then ret.readOnly = false else ret.readOnly = true end

		if widgetType[0] == libgphoto2.GP_WIDGET_RANGE then
			local min = ffi.new("float[1]")
			local max = ffi.new("float[1]")
			local increment = ffi.new("float[1]")
			status = libgphoto2.gp_widget_get_range(widget, min, max, increment)
			if status ~= Results.Ok then error("Failed to get value range: " .. resultToString(status)) end

			ret.min = tonumber(min[0])
			ret.max = tonumber(max[0])
			ret.increment = tonumber(increment[0])
			ret.range = ret.max - ret.min
		end

		if widgetType[0] == libgphoto2.GP_WIDGET_RADIO then
			ret.choices = {}
			local choiceCount = libgphoto2.gp_widget_count_choices(widget)
			for i=0, choiceCount-1 do
				local choice = ffi.new("const char*[1]")
				status = libgphoto2.gp_widget_get_choice(widget, i, choice)
				if status ~= Results.Ok then error("Failed to get widget label: " .. resultToString(status)) end

				table.insert(ret.choices, ffi.string(choice[0]))
			end
		end

		self.parameters[name] = ret
	end

	local childCount = libgphoto2.gp_widget_count_children(widget)
	for i=0, childCount-1 do
		local child = ffi.new("CameraWidget*[1]")
		local status = libgphoto2.gp_widget_get_child(widget, i, child)
		if status ~= Results.Ok then error("Failed to get child widget: " .. resultToString(status)) end

		self:parseParameters(child[0], fullName)
	end

	return target
end

function Camera:registerParameterProperty(propertyName, configName)
	if configName == nil then configName = string.lower(propertyName) end
	if Camera.properties[propertyName] == nil then Camera.properties[propertyName] = {} end
	Camera.properties[propertyName].get = function(self) return self:getParameter(configName) end
	Camera.properties[propertyName].set = function(self, value) self:setParameter(configName, value) end
end

Camera.properties.summary = {}
function Camera.properties.summary:get()  
	local text = ffi.new("CameraText")
	local status = libgphoto2.gp_camera_get_summary(self.handle, text, context);
	if status ~= Results.Ok then error("Failed to get camera summary: " .. resultToString(status)) end
	return ffi.string(text.text)
end

Camera.properties.aperture = {}
function Camera.properties.summary:get()  
	return self:getParameter("aperture")
end
function Camera.properties.summary:set(value) 
	local info = self:getParameter("aperture")

	if type(value) == "string" then
		if table.contains(info.choices, value) then
			self:setParameter("aperture", value)
		else

		end
	elseif type(value) == "number" then
		local lastChoice = self.apertureChoices[1]

		for i=2, #self.apertureChoices do
			if value < v then
				self:setParameter("aperture", tostring())
			end
		end
	end
end
		
function Camera:getRootWidget()
	local widget = ffi.new("CameraWidget*[1]")
	local status = libgphoto2.gp_camera_get_config(self.handle, widget, context);
	if status ~= Results.Ok then error("Failed to get camera configuration: " .. resultToString(status)) end

	return widget[0]
end

function Camera:widgetExists(name)
	local rootWidget = self:getRootWidget()
	local exists = lookupWidgetByName(rootWidget, name) ~= nil
	libgphoto2.gp_widget_free(widget)
	return exists
end

function Camera:getParameterInfo(name)
	local ret = self.parameters[name]
	
	-- Parameter not found - do one last check on the camera to see if it's available
	if ret == nil and self:widgetExists(name) then 
		-- Exists, parameters are out of date
		self:updateParameters() 
		-- Look again...
		ret = self.parameters[name]
		if ret == nil then 
			error("Parameter '"..name.."' does not exist!") 
		end
	end

	return ret
end

function Camera:getParameter(name)
	local info = self:getParameterInfo(name)
	local rootWidget = self:getRootWidget()
	--local widget = lookupWidgetById(rootWidget, info.id)
	local widget = lookupWidgetByName(rootWidget, name)

	local target = ffi.new("void*[1]")
	status = libgphoto2.gp_widget_get_value(widget, target)
	if status ~= Results.Ok then error("Failed to get widget value: " .. resultToString(status)) end

	local ret
	if info.typeName == "text" or info.typeName == "radio" or info.typeName == "menu" then
		ret = ffi.string(target[0])
	elseif info.typeName == "range" or info.typeName == "toggle" then
		ret = tonumber(target[0])
	elseif info.typeName == "date" then
		ret = tonumber(target[0])
	elseif info.typeName == "window" then
		-- NYI
	elseif info.typeName == "section" then
		-- NYI
	elseif info.typeName == "button" then
		-- NYI
	end

	libgphoto2.gp_widget_free(rootWidget)

	return ret
end

function Camera:setParameters(values)
	for k,v in pairs(name) do self:setParameter(k, v) end
end 

function Camera:setParameter(name, value)
	local info = self:getParameterInfo(name)
	local rootWidget = self:getRootWidget()
	--local widget = lookupWidgetById(rootWidget, info.id)
	local widget = lookupWidgetByName(rootWidget, name)

	local pushValue
	if info.typeName == "text" or info.typeName == "radio" or info.typeName == "menu" then

		assert(type(value) == "string", name.." must be a string!")
		pushValue = value

	elseif info.typeName == "range" then
		
		-- TODO: We need to make sure that the value the user has provided is in the range specified by the camera
		assert(type(value) == "number", name.." must be a number!")
		pushValue = ffi.new("float[1]", value)

	elseif info.typeName == "toggle" then
		
		-- Must be a boolean or a number.
		if type(value) == "boolean" then
			if value == true then value = 1 else value = 0 end
		elseif type(value) == "number" then
			if value < 0 then value = 0 end
			if value > 1 then value = 1 end
		else
			error(name.." must be a bool or an integer!")
		end

		pushValue = ffi.new("int[1]", value)

	elseif info.typeName == "button" then

		-- NYI
		error("Not implemented")

	elseif info.typeName == "date" then

		assert(type(value) == "number", name.." must be a date!")
		pushValue = ffi.new("int[1]", value)
		
	end

	status = libgphoto2.gp_widget_set_value(widget, pushValue)
	if status ~= Results.Ok then error("Failed to set widget value: " .. resultToString(status)) end

	status = libgphoto2.gp_camera_set_config(self.handle, rootWidget, context)
	if status ~= Results.Ok then error("Failed to set widget value: " .. resultToString(status)) end

	libgphoto2.gp_widget_free(rootWidget)
end

function Camera:waitForEvent(timeout)
	if timeout == nil then timeout = 1000 end
		
	local event_type = ffi.new("CameraEventType[1]")
	local event_data = ffi.new("void*[1]")
	local status = libgphoto2.gp_camera_wait_for_event(self, timeout, event_type, event_data, context)
	if status ~= Results.Ok then error("Failed to wait for camera event: " .. result_to_string(status)) end
			
	local data = event_data[0]
	if (event_type[0] == CameraEvent.FileAdded or event_type[0] == CameraEvent.FolderAdded) then 
		data = ffi.cast("CameraFilePath*", event_data[0])
	end
			
	return event_type[0], data
end

function Camera:capture(captureType, settings)
	if settings ~= nil then self:setParameters(settings) end

	local cameraFilePath = ffi.new("CameraFilePath");
	local status = libgphoto2.gp_camera_capture(self.handle, captureType, cameraFilePath, context)
	if status ~= Results.Ok then error("Failed to capture image: " .. resultToString(status)) end

	return ffi.string(cameraFilePath.name), ffi.string(cameraFilePath.folder)
end

function Camera:captureImage(settings)
	return self:capture(CameraCaptureType.Image, settings)
end

function Camera:captureVideo(settings)
	return self:capture(CameraCaptureType.Movie, settings)
end

function Camera:captureSound(settings)
	return self:capture(CameraCaptureType.Sound, settings)
end

function Camera:close()
	libgphoto2.gp_camera_exit(self, context)
end

Camera.__gc = Camera.close

local function acquireCamera()
	if context == nil then context = libgphoto2.gp_context_new() end
	return Camera:new()
end

return { acquireCamera = acquireCamera }