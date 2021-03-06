package im.siver.logger.v1 {

    import flash.display.DisplayObject;

    public class Logger {

        private static var _enabled:Boolean = true;
        private static var _initialized:Boolean = false;
        internal static const VERSION:String = '1.0.0';

        /**
         * This will initialize the Monster Debugger, the client will start a socket connection
         * to the Monster Debugger desktop application and initialize the core functions like
         * memory- and fpsmonitor. From this point on you can use other functions like trace,
         * snapshot, inspect, etc.
         *
         * @example
         * <code>
         * Logger.initialize(this);<br>
         * Logger.initialize(stage);<br>
         * </code>
         *
         * @param base:        The root of your application. We suggest you use the document class
         *                        or stage property for this. In PureMVC projects this could also
         *                        be your main view or application façade, but in this you won't be able
         *                        to see the display tree or use the highlight functions.
         * @param address:      (Optional) An IP address where the Monster Debugger will
         *                        try to connect to. By default it will connect to you local IP address
         *                        (127.0.0.1) but you can also supply another IP address like a remote
         *                        machine.
         */
        public static function initialize(base:Object, address:String = "127.0.0.1"):void {
            if (!_initialized) {
                _initialized = true;

                // Start engines
                Core.base = base;
                Core.initialize();
                Connection.initialize();
                Connection.address = address;
                Connection.connect();
            }
        }

        /**
         * Enables or disables the Monster Debugger. You can set this property before calling initialize
         * to disable even the core functions and socket connection to keep the memory footprint at
         * a minimum. We advise you to always disable the Monster Debugger on a final build.
         */
        public static function get enabled():Boolean {
            return _enabled;
        }

        public static function set enabled(value:Boolean):void {
            _enabled = value;
        }

        /**
         * The trace function of the Monster Debugger can be used to display standard objects like
         * Strings, Numbers, Arrays, etc. But it can also be used to display more complex objects like
         * custom classes, XML or even multidimensional arrays containing XML nodes for that matter.
         * It will send a snapshot of those objects to the desktop application where you can inspect them.
         *
         * @example
         * <code>
         * Logger.trace(this, "error");<br>
         * Logger.trace(this, myObject);<br>
         * Logger.trace(this, myObject, 0xFF0000, 5);<br>
         * Logger.trace("myStaticClass", myObject);<br>
         * </code>
         *
         * @param caller:            The caller of the trace. We suggest you always use the keyword "this".
         *                            The caller is displayed in the desktop application to easily identify
         *                            your traces on instance level. Note: if you use this function within a
         *                            static class, use a string as caller like: "MyStaticClass".
         * @param object:            The object to trace, this can be anything. For instance a String,
         *                            Number or Array but also complex items like a custom class,
         *                            multidimensional arrays.
         * @param color:            (Optional) The color of the trace. This can be useful if you want
         *                            to color code your traces; red for errors, green for status updates, etc.
         * @param depth:            (Optional) The level of depth for this trace. By default the Monster Debugger
         *                            will trace a tree structure of five levels deep to preserve CPU power.
         *                            In some occasions 5 could not be enough to see the whole object, for
         *                            instance if you’re tracing a large XML document with many sub nodes.
         *                            In those situations you can use a higher number to see the complete object.
         *                            If you set the depth to -1 it will not limit the levels at all and will
         *                            trace the entire tree. Be careful with this setting though as it can
         *                            dramatically slow down your application.
         */
        public static function trace(caller:*, object:*, color:uint = 0x000000, depth:int = 5):void {
            if (_initialized && _enabled) {
                Core.trace(caller, object, color, depth);
            }
        }

        /**
         * Makes a snapshot of a DisplayObject and sends it to the desktop application. This can be useful
         * if you need to compare visual states or display a hidden interface item. Snapshot will return
         * an un-rotated, completely visible (100% alpha) representation of the supplied DisplayObject.
         *
         * @example
         * <code>
         * Logger.snapshot(this, myMovieClip);<br>
         * Logger.snapshot(this, myBitmap, "joe", "interface");<br>
         * </code>
         *
         * @param caller:    The caller of the snapshot. We suggest you always use the keyword "this".
         *                    The caller is displayed in the desktop application to easily identify your
         *                    snapshots on instance level. Note: if you use this function within a static
         *                    class use a string as caller like: "MyStaticClass".
         * @param object:    The object to create the snapshot from. This object should extend a DisplayObject
         *                    (like a Sprite, MovieClip or UIComponent).
         * @param person:    (Optional) The person of interest. You can use this label to easily work with
         *                    a team of programmers on one project. The desktop application has a filter for
         *                    persons so each member can see their own snapshots.
         * @param label:    (Optional) Label to identify the snapshot. Within the desktop application
         *                    you can filter on this label.
         */
        public static function snapshot(caller:*, object:DisplayObject, person:String = "", label:String = ""):void {
            if (_initialized && _enabled) {
                Core.snapshot(caller, object, person, label);
            }
        }

        /**
         * This will clear all traces in the connected Monster Debugger desktop application.
         *
         * @example
         * <code>
         * Logger.clear();<br>
         * </code>
         *
         */
        public static function clear():void {
            if (_initialized && _enabled) {
                Core.clear();
            }
        }

    }

}