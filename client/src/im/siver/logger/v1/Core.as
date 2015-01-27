package im.siver.logger.v1 {

    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.getDefinitionByName;

    /**
     * @private
     */
    internal class Core {

        // Monitor and highlight interval timer
        private static const MONITOR_UPDATE:int = 1000;

        // Monitor timer
        private static var _monitorTimer:Timer;
        private static var _monitorSprite:Sprite;
        private static var _monitorTime:Number;
        private static var _monitorStart:Number;
        private static var _monitorFrames:int;

        // The root of the application
        private static var _base:Object = null;

        // The stage needed for highlight
        private static var _stage:Stage = null;

        // The core id
        internal static const ID:String = "im.siver.logger.v1";

        /**
         * Start the class.
         */
        internal static function initialize():void {
            // Reset the monitor values
            _monitorTime = new Date().time;
            _monitorStart = new Date().time;
            _monitorFrames = 0;

            // Create the monitor timer
            _monitorTimer = new Timer(MONITOR_UPDATE);
            _monitorTimer.addEventListener(TimerEvent.TIMER, monitorTimerCallback, false, 0, true);
            _monitorTimer.start();

            // Regular check for stage
            if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage) {
                _stage = _base["stage"] as Stage;
            }

            // Create the monitor sprite
            // This is needed for the enterframe ticks
            _monitorSprite = new Sprite();
            _monitorSprite.addEventListener(Event.ENTER_FRAME, frameHandler, false, 0, true);
        }

        /**
         * Getter and setter for base.
         */
        internal static function get base():* {
            return _base;
        }

        internal static function set base(value:*):void {
            _base = value;
        }

        /**
         * @private
         */
        internal static function trace(caller:*, object:*, color:uint = 0x000000, depth:int = 5):void {
            if (Logger.enabled) {

                // Get the object information
                var xml:XML = XML(Utils.parse(object, "", 1, depth, false));

                // Create the data
                var data:Object = {
                    command:   Constants.COMMAND_TRACE,
                    memory:    Utils.getMemory(),
                    date:      new Date(),
                    target:    String(caller),
                    reference: Utils.getReferenceID(caller),
                    xml:       xml,
                    color:     color
                };

                // Send the data
                send(data);
            }
        }

        /**
         * @private
         * See MonsterDebugger class
         */
        internal static function snapshot(caller:*, object:DisplayObject, person:String = "", label:String = ""):void {
            if (Logger.enabled) {

                // Create the bitmapdata
                var bitmapData:BitmapData = Utils.snapshot(object);
                if (bitmapData != null) {
                    // Write the bitmap in the bytearray
                    var bytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));

                    // Create the data
                    var data:Object = {
                        command:   Constants.COMMAND_SNAPSHOT,
                        memory:    Utils.getMemory(),
                        date:      new Date(),
                        target:    String(caller),
                        reference: Utils.getReferenceID(caller),
                        bytes:     bytes,
                        width:     bitmapData.width,
                        height:    bitmapData.height,
                        person:    person,
                        label:     label
                    };

                    // Send the data
                    send(data);
                }
            }
        }

        /**
         * @private
         * See MonsterDebugger class
         */
        internal static function clear():void {
            if (Logger.enabled) {
                send({command: Constants.COMMAND_CLEAR_TRACES});
            }
        }

        /**
         * Send the capabilities and information.
         * This is send after the HELLO command.
         */
        internal static function sendInformation():void {
            // Get basic data
            var playerType:String = Capabilities.playerType;
            var playerVersion:String = Capabilities.version;
            var isDebugger:Boolean = Capabilities.isDebugger;
            var isFlex:Boolean = false;
            var fileTitle:String = "";
            var fileLocation:String = "";

            // Check for Flex framework
            try {
                var UIComponentClass:* = getDefinitionByName("mx.core::UIComponent");
                if (UIComponentClass != null) isFlex = true;
            } catch (e1:Error) {
            }

            // Get the location
            if (_base is DisplayObject && _base.hasOwnProperty("loaderInfo")) {
                if (DisplayObject(_base).loaderInfo != null) {
                    fileLocation = unescape(DisplayObject(_base).loaderInfo.url);
                }
            }
            if (_base.hasOwnProperty("stage")) {
                if (_base["stage"] != null && _base["stage"] is Stage) {
                    fileLocation = unescape(Stage(_base["stage"]).loaderInfo.url);
                }
            }

            // Check for browser
            if (playerType == "ActiveX" || playerType == "PlugIn") {
                if (ExternalInterface.available) {
                    try {
                        var tmpLocation:String = ExternalInterface.call("window.location.href.toString");
                        var tmpTitle:String = ExternalInterface.call("window.document.title.toString");
                        if (tmpLocation != null) fileLocation = tmpLocation;
                        if (tmpTitle != null) fileTitle = tmpTitle;
                    } catch (e2:Error) {
                        // External interface FAIL
                    }
                }
            }

            // Check for Adobe AIR
            if (playerType == "Desktop") {
                try {
                    var NativeApplicationClass:* = getDefinitionByName("flash.desktop::NativeApplication");
                    if (NativeApplicationClass != null) {
                        var descriptor:XML = NativeApplicationClass["nativeApplication"]["applicationDescriptor"];
                        var ns:Namespace = descriptor.namespace();
                        var filename:String = descriptor.ns::filename;
                        var FileClass:* = getDefinitionByName("flash.filesystem::File");
                        if (Capabilities.os.toLowerCase().indexOf("windows") != -1) {
                            filename += ".exe";
                            fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
                        } else if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {
                            filename += ".app";
                            fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
                        }
                    }
                } catch (e3:Error) {
                }
            }

            if (fileTitle == "" && fileLocation != "") {
                var slash:int = Math.max(fileLocation.lastIndexOf("\\"), fileLocation.lastIndexOf("/"));
                if (slash != -1) {
                    fileTitle = fileLocation.substring(slash + 1, fileLocation.lastIndexOf("."));
                } else {
                    fileTitle = fileLocation;
                }
            }

            // Default
            if (fileTitle == "") {
                fileTitle = "Application";
            }

            // Create the data
            var data:Object = {
                command:         Constants.COMMAND_INFO,
                debuggerVersion: Logger.VERSION,
                playerType:      playerType,
                playerVersion:   playerVersion,
                isDebugger:      isDebugger,
                isFlex:          isFlex,
                fileLocation:    fileLocation,
                fileTitle:       fileTitle
            };

            // Send the data direct
            send(data, true);

            // Start the queue after that
            Connection.processQueue();
        }

        /**
         * Handle incoming data from the connection.
         * @param item: Data from the desktop application
         */
        internal static function handle(item:Data):void {
            if (Logger.enabled) {

                // If the id is empty just return
                if (item.id == null || item.id == "") {
                    return;
                }

                // Check if we should handle the call internaly
                if (item.id == Core.ID) {
                    handleInternal(item);
                }
            }
        }

        /**
         * Handle internal commands from the connection.
         * @param item: Data from the desktop application
         */
        private static function handleInternal(item:Data):void {
            // Vars for loop
            var obj:*;
            var xml:XML;
            var method:Function;

            // Do the actions
            switch (item.data["command"]) {
                // Get the application info and start processing queue
                case Constants.COMMAND_HELLO:
                    sendInformation();
                    break;

                // Get the root xml structure (object)
                case Constants.COMMAND_BASE:
                    obj = Utils.getObject(_base, "", 0);
                    if (obj != null) {
                        xml = XML(Utils.parse(obj, "", 1, 2, true));
                        send({command: Constants.COMMAND_BASE, xml: xml});
                    }
                    break;

                // Inspect
                case Constants.COMMAND_INSPECT:
                    obj = Utils.getObject(_base, item.data["target"], 0);
                    if (obj != null) {
                        _base = obj;
                        xml = XML(Utils.parse(obj, "", 1, 2, true));
                        send({command: Constants.COMMAND_BASE, xml: xml});
                    }
                    break;

                // Return the parsed object
                case Constants.COMMAND_GET_OBJECT:
                    obj = Utils.getObject(_base, item.data["target"], 0);
                    if (obj != null) {
                        xml = XML(Utils.parse(obj, item.data["target"], 1, 2, true));
                        send({command: Constants.COMMAND_GET_OBJECT, xml: xml});
                    }
                    break;

                // Return a list of properties
                case Constants.COMMAND_GET_PROPERTIES:
                    obj = Utils.getObject(_base, item.data["target"], 0);
                    if (obj != null) {
                        xml = XML(Utils.parse(obj, item.data["target"], 1, 1, false));
                        send({command: Constants.COMMAND_GET_PROPERTIES, xml: xml});
                    }
                    break;

                // Return a list of functions
                case Constants.COMMAND_GET_FUNCTIONS:
                    obj = Utils.getObject(_base, item.data["target"], 0);
                    if (obj != null) {
                        xml = XML(Utils.parseFunctions(obj, item.data["target"]));
                        send({command: Constants.COMMAND_GET_FUNCTIONS, xml: xml});
                    }
                    break;

                // Adjust a property and return the value
                case Constants.COMMAND_SET_PROPERTY:
                    obj = Utils.getObject(_base, item.data["target"], 1);
                    if (obj != null) {
                        try {
                            obj[item.data["name"]] = item.data["value"];
                            send({
                                     command: Constants.COMMAND_SET_PROPERTY,
                                     target:  item.data["target"],
                                     value:   obj[item.data["name"]]
                                 });
                        } catch (e1:Error) {
                            //
                        }
                    }
                    break;

                // Return a preview
                case Constants.COMMAND_GET_PREVIEW:
                    obj = Utils.getObject(_base, item.data["target"], 0);
                    if (obj != null && Utils.isDisplayObject(obj)) {
                        var displayObject:DisplayObject = obj as DisplayObject;
                        var bitmapData:BitmapData = Utils.snapshot(displayObject, new Rectangle(0, 0, 300, 300));
                        if (bitmapData != null) {
                            var bytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
                            send({
                                     command: Constants.COMMAND_GET_PREVIEW,
                                     bytes:   bytes,
                                     width:   bitmapData.width,
                                     height:  bitmapData.height
                                 });
                        }
                    }
                    break;

                // Call a method and return the answer
                case Constants.COMMAND_CALL_METHOD:
                    method = Utils.getObject(_base, item.data["target"], 0);
                    if (method != null && method is Function) {
                        if (item.data["returnType"] == Constants.TYPE_VOID) {
                            method.apply(null, item.data["arguments"]);
                        } else {
                            try {
                                obj = method.apply(null, item.data["arguments"]);
                                xml = XML(Utils.parse(obj, "", 1, 5, false));
                                send({command: Constants.COMMAND_CALL_METHOD, id: item.data["id"], xml: xml});
                            } catch (e2:Error) {
                                //
                            }
                        }
                    }
                    break;
            }
        }

        /**
         * Monitor timer callback.
         */
        private static function monitorTimerCallback(event:TimerEvent):void {
            if (Logger.enabled) {

                // Calculate the frames per second
                var now:Number = new Date().time;
                var delta:Number = now - _monitorTime;
                var fps:uint = _monitorFrames / delta * 1000; // Miliseconds to seconds
                var fpsMovie:uint = 0;
                if (_stage == null) {
                    if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage) {
                        _stage = Stage(_base["stage"]);
                    }
                }
                if (_stage != null) {
                    fpsMovie = _stage.frameRate;
                }

                // Reset
                _monitorFrames = 0;
                _monitorTime = now;

                // Check if we can send the data
                if (Connection.connected) {
                    // Create the data
                    var data:Object = {
                        command:  Constants.COMMAND_MONITOR,
                        memory:   Utils.getMemory(),
                        fps:      fps,
                        fpsMovie: fpsMovie,
                        time:     now
                    };

                    // Send the data
                    send(data);
                }
            }
        }

        /**
         * Enterframe ticker callback.
         */
        private static function frameHandler(event:Event):void {
            if (Logger.enabled) {
                _monitorFrames++;
            }
        }

        /**
         * Send data to the desktop application.
         * @param data: The data to send
         * @param direct: Use the queue or send direct (handshake)
         */
        private static function send(data:Object, direct:Boolean = false):void {
            if (Logger.enabled) {
                Connection.send(Core.ID, data, direct);
            }
        }

    }

}