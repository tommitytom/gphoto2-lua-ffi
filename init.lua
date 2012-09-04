-- luajit ffi based bindings for gphoto2
-- http://www.gphoto.org/

local ffi = require("ffi")

assert(jit, "jit table unavailable")

ffi.cdef[[

	typedef enum 
	{
		GP_CAPTURE_IMAGE,	
		GP_CAPTURE_MOVIE,	
		GP_CAPTURE_SOUND	
	} CameraCaptureType;

	typedef enum 
	{
		GP_DRIVER_STATUS_PRODUCTION,	/**< Driver is production ready. */
		GP_DRIVER_STATUS_TESTING,	/**< Driver is beta quality. */
		GP_DRIVER_STATUS_EXPERIMENTAL,	/**< Driver is alpha quality and might even not work. */
		GP_DRIVER_STATUS_DEPRECATED	/**< Driver is no longer recommended to use and will be removed. */
	} CameraDriverStatus;

	typedef enum 
	{
		GP_DEVICE_STILL_CAMERA          = 0,	 /**< Traditional still camera */
		GP_DEVICE_AUDIO_PLAYER          = 1 << 0 /**< Audio player */
	} GphotoDeviceType;

	typedef enum 
	{
		GP_OPERATION_NONE       	= 0,	  /**< No remote control operation supported. */
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
		GP_WIDGET_WINDOW,	/**< \brief Window widget
		GP_WIDGET_SECTION,	/**< \brief Section widget (think Tab) */
		GP_WIDGET_TEXT,		/**< \brief Text widget. */			/* char *		*/
		GP_WIDGET_RANGE,	/**< \brief Slider widget. */			/* float		*/
		GP_WIDGET_TOGGLE,	/**< \brief Toggle widget (think check box) */	/* int			*/
		GP_WIDGET_RADIO,	/**< \brief Radio button widget. */		/* char *		*/
		GP_WIDGET_MENU,		/**< \brief Menu widget (same as RADIO). */	/* char *		*/
		GP_WIDGET_BUTTON,	/**< \brief Button press widget. */		/* CameraWidgetCallback */
		GP_WIDGET_DATE		/**< \brief Date entering widget. */		/* int			*/
	} CameraWidgetType;
	
	typedef enum 
	{
		GP_EVENT_UNKNOWN,	/**< unknown and unhandled event */
		GP_EVENT_TIMEOUT,	/**< timeout, no arguments */
		GP_EVENT_FILE_ADDED,	/**< CameraFilePath* = file path on camfs */
		GP_EVENT_FOLDER_ADDED,	/**< CameraFilePath* = folder on camfs */
		GP_EVENT_CAPTURE_COMPLETE	/**< last capture is complete */
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
	
	int gp_camera_wait_for_event(Camera* camera, int timeout, CameraEventType* eventtype, void** eventdata, GPContext* context);
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

local function result_to_string(result)
	return ffi.string(libgphoto2.gp_port_result_as_string(result))
end

local function acquire_camera()
	if context == nil then context = libgphoto2.gp_context_new() end
	
	local cameraptr = ffi.new("Camera*[1]")
	local status = libgphoto2.gp_camera_new(cameraptr)
	if status ~= Results.Ok then error("Failed to acquire camera: " .. result_to_string(status)) end

	status = libgphoto2.gp_camera_init(cameraptr[0], context)
	if status ~= Results.Ok then error("Failed to acquire camera: " .. result_to_string(status)) end

	return cameraptr[0]
end

local function lookup_widget(widget, key) 
	local widgetChild = ffi.new("CameraWidget*[1]")
	local status = libgphoto2.gp_widget_get_child_by_name(widget, key, widgetChild);
	if status ~= Results.Ok then 
		status = libgphoto2.gp_widget_get_child_by_label(widget, key, widgetChild);
		if status ~= Results.Ok then error("Failed to find child widget: " .. result_to_string(status)) end
	end

	return widgetChild[0];
end


local camera_methods = {}
local camera_mt = { __index = camera_methods }

function camera_methods:abilities()
	
end

function camera_methods:summary()
	local text = ffi.new("CameraText")
	local status = libgphoto2.gp_camera_get_summary(self, text, context);
	if status ~= Results.Ok then error("Failed to get camera summary: " .. result_to_string(status)) end

	return ffi.string(text.text)
end

function camera_methods:get_config()
	local widget = ffi.new("CameraWidget*[1]")
	local status = libgphoto2.gp_camera_get_config(self, widget, context);
	if status ~= Results.Ok then error("Failed to get camera configuration: " .. result_to_string(status)) end

	return widget[0]	
end

function camera_methods:capture(capture_type)
	local camera_file_path = ffi.new("CameraFilePath")
	local status = libgphoto2.gp_camera_capture(self, capture_type, camera_file_path, context)
	if status ~= Results.Ok then error("Failed to capture image: " .. result_to_string(status)) end

	return ffi.string(camera_file_path.name), ffi.string(camera_file_path.folder)
end

function camera_methods:capture_image()
	return self:capture(CameraCaptureType.Image)
end

function camera_methods:wait_for_event()
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

function camera_methods:close()
	libgphoto2.gp_camera_exit(camera, context)
end

camera_mt.__gc = camera_methods.close

ffi.metatype("Camera", camera_mt)

return
{
	Results = Results,
	CameraCaptureType = CameraCaptureType,
	CameraEvent = CameraEvent,
	acquire_camera = acquire_camera	
}