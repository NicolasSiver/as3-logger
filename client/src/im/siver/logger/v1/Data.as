package im.siver.logger.v1 {

    import flash.utils.ByteArray;

    /**
     * The Monster Debugger shared data.
     */
    public class Data {

        // Properties
        private var _id:String;
        private var _data:Object;

        /**
         * Shared data class between the client and desktop application.
         * @param id: The plugin id
         * @param data: The data to send over the socket connection
         */
        public function Data(id:String, data:Object) {
            // Save data
            _id = id;
            _data = data;
        }

        /**
         * Get the plugin id.
         */
        public function get id():String {
            return _id;
        }

        /**
         * Get the data object.
         */
        public function get data():Object {
            return _data;
        }

        /**
         * Get the raw bytes.
         */
        public function get bytes():ByteArray {
            // Create the holders
            var bytesId:ByteArray = new ByteArray();
            var bytesData:ByteArray = new ByteArray();

            // Save the objects
            bytesId.writeObject(_id);
            bytesData.writeObject(_data);

            // Write in one object
            var item:ByteArray = new ByteArray();
            item.writeUnsignedInt(bytesId.length);
            item.writeBytes(bytesId);
            item.writeUnsignedInt(bytesData.length);
            item.writeBytes(bytesData);
            item.position = 0;

            // Clear the old objects
            bytesId = null;
            bytesData = null;

            // Return the object
            return item;
        }

        /**
         * Convert raw bytes.
         */
        public function set bytes(value:ByteArray):void {
            // Create the holders
            var bytesId:ByteArray = new ByteArray();
            var bytesData:ByteArray = new ByteArray();

            // Decompress the value and read bytes
            try {
                value.readBytes(bytesId, 0, value.readUnsignedInt());
                value.readBytes(bytesData, 0, value.readUnsignedInt());

                // Save vars
                _id = bytesId.readObject() as String;
                _data = bytesData.readObject() as Object;
            } catch (e:Error) {
                _id = null;
                _data = null;
            }

            // Clear the old objects
            bytesId = null;
            bytesData = null;
        }

        /**
         * Convert raw bytes to a MonsterDebuggerData object.
         * @param bytes: The raw bytes to convert
         */
        public static function read(bytes:ByteArray):Data {
            var item:Data = new Data(null, null);
            item.bytes = bytes;
            return item;
        }
    }

}