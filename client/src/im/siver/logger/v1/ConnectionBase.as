package im.siver.logger.v1 {

    /**
     * This interface is needed to separate default and mobile connectors
     */
    internal interface ConnectionBase {

        function set address(value:String):void;

        function get connected():Boolean;

        function processQueue():void;

        function send(id:String, data:Object, direct:Boolean = false):void;

        function connect():void;
    }
}
