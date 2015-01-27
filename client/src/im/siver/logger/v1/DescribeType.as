package im.siver.logger.v1 {

    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;

    /**
     * @private
     * The Monster Debugger DescribeType. This Calls flash.utils.describeType()
     * for the first time and caches the return value so that subsequent calls
     * return faster.
     */
    internal class DescribeType {

        // Simple xml cache
        private static var cache:Object = {};

        /**
         *  Calls flash.utils.describeType() for the first time and caches
         *  the return value so that subsequent calls return faster.
         *  @param object: The target object
         */
        internal static function get(object:*):XML {
            // Save the classname as key
            var key:String = getQualifiedClassName(object);

            // Check if we found the item in cache
            if (key in cache) {
                return cache[key];
            }

            // Else save the item and return that
            var xml:XML = describeType(object);
            cache[key] = xml;
            return xml;
        }
    }
}
