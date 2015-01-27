package im.siver.logger.v1 {


    /**
     * @private
     * The Monster Debugger connection
     */
    internal class Connection {

        // Connector class
        private static var connector:ConnectionBase;

        /**
         * Start the class
         */
        internal static function initialize():void {
            CONFIG::DEFAULT {
                connector = new ConnectionDefault();
            }

            CONFIG::MOBILE {
                connector = new ConnectionMobile();
            }
        }

        /**
         * @param value: The address to connect to
         */
        internal static function set address(value:String):void {
            connector.address = value;
        }

        /**
         * Get connected status.
         */
        internal static function get connected():Boolean {
            return connector.connected;
        }

        /**
         *  Start processing the queue.
         */
        internal static function processQueue():void {
            connector.processQueue();
        }

        /**
         * Send data to the desktop application.
         * @param id: The id of the plugin
         * @param data: The data to send
         * @param direct: Use the queue or send direct (handshake)
         */
        internal static function send(id:String, data:Object, direct:Boolean = false):void {
            connector.send(id, data, direct);
        }

        /**
         * Connect the socket.
         */
        internal static function connect():void {
            connector.connect();
        }

    }
}

