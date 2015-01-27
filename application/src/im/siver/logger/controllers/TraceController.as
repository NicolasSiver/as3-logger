package im.siver.logger.controllers {

    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import im.siver.logger.models.Constants;
    import im.siver.logger.utils.LoggerUtils;
    import im.siver.logger.views.components.Filter;
    import im.siver.logger.views.components.panels.TracePanel;
    import im.siver.logger.views.components.windows.SnapshotWindow;
    import im.siver.logger.views.components.windows.TraceWindow;

    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;
    import mx.utils.StringUtil;

    public final class TraceController extends EventDispatcher {

        [Bindable]
        private var _dataFiltered:ArrayCollection = new ArrayCollection();

        private var _data:ArrayCollection = new ArrayCollection();
        private var _panel:TracePanel;
        private var _send:Function;

        /**
         * Save panel
         */
        public function TraceController(panel:TracePanel, send:Function) {
            _panel = panel;
            _send = send;
            _panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
        }

        private function collectionDidChange(e:CollectionEvent):void {
            if (_panel.autoScrollButton.selected) {
                _panel.datagrid.validateNow();
                _panel.datagrid.verticalScrollPosition = _panel.datagrid.maxVerticalScrollPosition;
            }
        }

        /**
         * Panel is ready to link data providers
         */
        private function creationComplete(e:FlexEvent):void {
            _panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
            _panel.datagrid.dataProvider = _dataFiltered;
            _panel.datagrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, showTrace, false, 0, true);
            _panel.filter.addEventListener(Filter.CHANGED, filterChanged, false, 0, true);
            _panel.clearButton.addEventListener(MouseEvent.CLICK, clear, false, 0, true);
            _dataFiltered.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionDidChange, false, 0, true);
        }

        /**
         * Show a trace in an output window
         */
        private function filterChanged(event:Event):void {
            // Check if a filter term is given
            if (_panel.filter.words.length == 0) {
                _dataFiltered.filterFunction = null;
                _dataFiltered.refresh();
            } else {
                _dataFiltered.filterFunction = fullFilter;
                _dataFiltered.refresh();
            }
        }

        /**
         * Look through targets and messages
         * @param item data-provider item
         * @return true if item has been found
         */
        private function fullFilter(item:Object):Boolean {
            var message:String = item.message;
            var target:String = item.target;
            var i:int, words:Array = _panel.filter.words, len:int = words.length;

            if (target != null) {
                target = target.toLowerCase();
                for (i = 0; i < len; ++i) {
                    if (target.indexOf(words[i]) != -1) {
                        return true;
                    }
                }
            }

            if (message != null) {
                message = message.toLowerCase();
                for (i = 0; i < len; ++i) {
                    if (message.indexOf(words[i]) != -1) {
                        return true;
                    }
                }
            }
            return false;
        }

        /**
         * Show a trace in an output window
         */
        private function showTrace(event:ListEvent):void {
            // Check if the selected item is still available
            if (event.currentTarget.selectedItem != null) {

                // Get the data
                var item:Object = _dataFiltered.getItemAt(event.currentTarget.selectedIndex);

                // Check the window to open
                if (item.message == "Snapshot" && item.xml == null) {
                    var snapshotWindow:SnapshotWindow = new SnapshotWindow();
                    snapshotWindow.setData(item);
                    snapshotWindow.open();
                } else {
                    var traceWindow:TraceWindow = new TraceWindow();
                    traceWindow.setData(item);
                    traceWindow.open();
                }
            }
        }

        /**
         * Clear traces
         */
        public function clear(event:MouseEvent = null):void {
            _data.removeAll();
            _dataFiltered.removeAll();
            _panel.datagrid.horizontalScrollPosition = 0;
        }

        /**
         * Data handler from client
         */
        public function setData(data:Object):void {
            // Vars for loop
            var date:Date;
            var hours:String;
            var minutes:String;
            var seconds:String;
            var miliseconds:String;
            var time:String;
            var memory:String;
            var traceItem:Object;

            switch (data["command"]) {

                case Constants.COMMAND_CLEAR_TRACES:
                    clear();
                    break;

                case Constants.COMMAND_TRACE:

                    // Format the properties
                    date = data["date"];
                    time = zeroPad(date.getHours(), 2) + ":" + zeroPad(date.getMinutes(), 2) + ":" + zeroPad(date.getSeconds(), 2) + "." + zeroPad(date.getMilliseconds(), 3);
                    memory = Math.round(data["memory"] / 1024) + " Kb";

                    // Create the trace object
                    traceItem = {};

                    // Check the label
                    if (data["xml"]..node.length() > 1 && data["xml"]..node.length() <= 3) {
                        if (data["xml"].node[0].@type == Constants.TYPE_STRING || data["xml"].node[0].@type == Constants.TYPE_BOOLEAN || data["xml"].node[0].@type == Constants.TYPE_NUMBER || data["xml"].node[0].@type == Constants.TYPE_INT || data["xml"].node[0].@type == Constants.TYPE_UINT) {
                            traceItem.message = LoggerUtils.stripBreaks(LoggerUtils.htmlUnescape(data["xml"].node.children()[0].@label));
                        } else {
                            traceItem.message = LoggerUtils.stripBreaks(LoggerUtils.htmlUnescape(data["xml"].node.@label)) + " ...";
                        }
                    } else {
                        traceItem.message = LoggerUtils.stripBreaks(LoggerUtils.htmlUnescape(data["xml"].node.@label)) + " ...";
                    }

                    // Clean target
                    if (data['target'].indexOf('object') != -1) {
                        traceItem.target = String(data['target']).replace('object ', '');
                    } else {
                        traceItem.target = data["target"];
                    }

                    // Add extra info
                    traceItem.line = _data.length + 1;
                    traceItem.time = time;
                    traceItem.memory = memory;
                    traceItem.reference = data["reference"];
                    traceItem.label = data["label"];
                    traceItem.person = data["person"];
                    traceItem.color = data["color"];
                    traceItem.xml = data["xml"];

                    // Add to list
                    _data.addItem(traceItem);
                    _dataFiltered.addItem(traceItem);
                    break;

                case Constants.COMMAND_SNAPSHOT:

                    // Format the properties
                    date = data["date"];
                    hours = (date.getHours() < 10) ? "0" + date.getHours().toString() : date.getHours().toString();
                    minutes = (date.getMinutes() < 10) ? "0" + date.getMinutes().toString() : date.getMinutes().toString();
                    seconds = (date.getSeconds() < 10) ? "0" + date.getSeconds().toString() : date.getSeconds().toString();
                    miliseconds = date.getMilliseconds().toString();
                    time = hours + ":" + minutes + ":" + seconds + "." + miliseconds;
                    memory = Math.round(data["memory"] / 1024) + " Kb";

                    // Read the bitmap
                    try {
                        var bitmapData:BitmapData = new BitmapData(data["width"], data["height"]);
                        bitmapData.setPixels(new Rectangle(0, 0, data["width"], data["height"]), data["bytes"]);
                    } catch (e:Error) {
                        return;
                    }

                    // Create the trace object
                    traceItem = {};
                    traceItem.line = _data.length + 1;
                    traceItem.time = time;
                    traceItem.memory = memory;
                    traceItem.width = data["width"];
                    traceItem.height = data["height"];
                    traceItem.bitmapData = bitmapData;
                    traceItem.message = "Snapshot";
                    traceItem.target = data["target"];
                    traceItem.label = data["label"];
                    traceItem.person = data["person"];
                    traceItem.color = data["color"];
                    traceItem.xml = null;

                    // Add to list
                    _data.addItem(traceItem);
                    _dataFiltered.addItem(traceItem);
                    break;
            }
        }

        private function zeroPad(value:int, length:int, pad:String = '0'):String {
            var result:String = String(value);
            while (result.length < length) {
                result = pad + result;
            }
            return result;
        }
    }
}
