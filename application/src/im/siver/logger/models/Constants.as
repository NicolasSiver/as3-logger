package im.siver.logger.models {

    public final class Constants {

        // Core app id
        public static const ID:String = "com.demonsters.debugger.core";

        // Paths
        public static const PATH_UPDATE:String = "http://www.monsterdebugger.com/xml/3/update.xml";

        // Commands
        public static const COMMAND_HELLO:String = "HELLO";
        public static const COMMAND_INFO:String = "INFO";
        public static const COMMAND_TRACE:String = "TRACE";
        public static const COMMAND_BASE:String = "BASE";
        public static const COMMAND_INSPECT:String = "INSPECT";
        public static const COMMAND_GET_PROPERTIES:String = "GET_PROPERTIES";
        public static const COMMAND_GET_FUNCTIONS:String = "GET_FUNCTIONS";
        public static const COMMAND_GET_PREVIEW:String = "GET_PREVIEW";
        public static const COMMAND_CLEAR_TRACES:String = "CLEAR_TRACES";
        public static const COMMAND_MONITOR:String = "MONITOR";
        public static const COMMAND_SNAPSHOT:String = "SNAPSHOT";

        // Types
        public static const TYPE_NULL:String = "null";
        public static const TYPE_VOID:String = "void";
        public static const TYPE_ARRAY:String = "Array";
        public static const TYPE_BOOLEAN:String = "Boolean";
        public static const TYPE_NUMBER:String = "Number";
        public static const TYPE_OBJECT:String = "Object";
        public static const TYPE_VECTOR:String = "Vector.";
        public static const TYPE_STRING:String = "String";
        public static const TYPE_INT:String = "int";
        public static const TYPE_UINT:String = "uint";
        public static const TYPE_XML:String = "XML";
        public static const TYPE_XMLLIST:String = "XMLList";
        public static const TYPE_XMLNODE:String = "XMLNode";
        public static const TYPE_XMLVALUE:String = "XMLValue";
        public static const TYPE_XMLATTRIBUTE:String = "XMLAttribute";
        public static const TYPE_METHOD:String = "MethodClosure";
        public static const TYPE_FUNCTION:String = "Function";
        public static const TYPE_BYTEARRAY:String = "ByteArray";
        public static const TYPE_WARNING:String = "Warning";
        public static const TYPE_NOT_FOUND:String = "Not found";
        public static const TYPE_UNREADABLE:String = "Unreadable";

        // Access types
        public static const ACCESS_VARIABLE:String = "variable";
        public static const ACCESS_CONSTANT:String = "constant";
        public static const ACCESS_ACCESSOR:String = "accessor";
        public static const ACCESS_METHOD:String = "method";
        public static const ACCESS_DISPLAY_OBJECT:String = "displayObject";

        // Permission types
        public static const PERMISSION_READWRITE:String = "readwrite";
        public static const PERMISSION_READONLY:String = "readonly";
        public static const PERMISSION_WRITEONLY:String = "writeonly";

        // Icon types
        public static const ICON_DEFAULT:String = "iconDefault";
        public static const ICON_ROOT:String = "iconRoot";
        public static const ICON_WARNING:String = "iconWarning";
        public static const ICON_VARIABLE:String = "iconVariable";
        public static const ICON_VARIABLE_READONLY:String = "iconVariableReadonly";
        public static const ICON_VARIABLE_WRITEONLY:String = "iconVariableWriteonly";
        public static const ICON_DISPLAY_OBJECT:String = "iconDisplayObject";
        public static const ICON_XMLNODE:String = "iconXMLNode";
        public static const ICON_XMLVALUE:String = "iconXMLValue";
        public static const ICON_XMLATTRIBUTE:String = "iconXMLAttribute";
        public static const ICON_FUNCTION:String = "iconFunction";

        // Path delimiter
        public static const DELIMITER:String = ".";

        public static const URL_AS3_REFERENCE:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/index.html";
        public static const URL_AS3_ERRORS:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/runtimeErrors.html";
        public static const URL_AS3_RIA:String = "http://www.adobe.com/devnet-archive/actionscript/articles/atp_ria_guide/atp_ria_guide.pdf";
        public static const URL_AS3_PLAYER:String = "http://www.adobe.com/support/flashplayer/downloads.html";

        public static const URL_ISSUES:String = "https://github.com/NicolasSiver/as3-logger/issues";
        public static const URL_SITE:String = "https://github.com/NicolasSiver/as3-logger";
    }
}