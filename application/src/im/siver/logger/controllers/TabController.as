package im.siver.logger.controllers {

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import im.siver.logger.models.ClientData;
    import im.siver.logger.models.Constants;
    import im.siver.logger.models.LoggerClient;
    import im.siver.logger.views.components.panels.MonitorPanel;
    import im.siver.logger.views.components.panels.TracePanel;
    import im.siver.logger.views.components.tabs.Tab;
    import im.siver.logger.views.components.tabs.TabContainer;

    import mx.events.FlexEvent;

    public final class TabController extends EventDispatcher {

        // Linked client
        private var _client:LoggerClient;

        // The tab component
        public var _tab:Tab;
        private var _tabContainer:TabContainer;

        // The panels
        private var _tracePanel:TracePanel;
        private var _monitorPanel:MonitorPanel;

        // The panel controllers
        private var _traceController:TraceController;
        private var _monitorController:MonitorController;

        // Menu items
        private var _toggleMonitorViewMenuItem:Boolean;
        private var _toggleTraceViewMenuItem:Boolean;
        private var _active:Boolean;

        /**
         * Create a new tab controller
         */
        public function TabController(container:TabContainer, aClient:LoggerClient) {
            _toggleMonitorViewMenuItem = true;
            _toggleTraceViewMenuItem = true;

            // Create a new tab
            _tab = new Tab();
            _tabContainer = container;
            _tab.addEventListener(FlexEvent.INITIALIZE, onInit, false, 0, true);
            container.addTab(_tab);

            // Save client and set label
            client = aClient;
        }

        /**
         * Create the panels
         */
        private function onInit(event:FlexEvent):void {
            // Remove
            _tab.removeEventListener(FlexEvent.INITIALIZE, onInit);

            // Create the panels
            _tracePanel = new TracePanel();
            _monitorPanel = new MonitorPanel();

            // Create the names
            _tracePanel.name = "Traces";
            _monitorPanel.name = "Memory Monitor";

            // Add the panels
            _tab.topPanel.addPanelItem(_monitorPanel);
            _tab.bottomPanel.addPanelItem(_tracePanel);

            // Create the controllers
            _traceController = new TraceController(_tracePanel, send);
            _monitorController = new MonitorController(_monitorPanel, send);

            // Panel listeners
            MenuController.addEventListener(MenuController.TOGGLE_TRACE_VIEW, hideBottomPanel);
            MenuController.addEventListener(MenuController.TOGGLE_MEMORY_MONITOR_VIEW, hideTopPanel);
            MenuController.addEventListener(MenuController.CLEAR_TRACES, clearTraces);
        }

        /**
         * Clear the tab
         */
        public function clear():void {
            _traceController.clear();
            _monitorController.clear();
            _client.onData = null;
            _client = null;
        }

        /**
         * Link the client to this tab
         */
        public function set client(value:LoggerClient):void {
            _client = value;
            if (_client != null) {
                _client.onData = dataHandler;
                _client.onDisconnect = closedConnection;
                _tab.label = _client.fileTitle;
                _traceController.clear();
                _monitorController.clear();

                _tab.disconnectMessageBox.visible = false;
                _tab.disconnectMessageBox.includeInLayout = false;
            } else {
                _tab.label = "Waiting...";
            }
        }

        /**
         * Return the linked client
         */
        public function get client():LoggerClient {
            return _client;
        }

        /**
         * Send data to the client
         * Note: This is called from the panel controller
         */
        private function send(data:Object):void {
            if (_client != null) {
                _client.send(Constants.ID, data);
            }
        }

        /**
         * Incomming data from the client
         */
        private function dataHandler(item:ClientData):void {
            if (item.id == Constants.ID) {

                _traceController.setData(item.data);
                _monitorController.setData(item.data);

                // In case of a new base, get the previews
                switch (item.data["command"]) {
                    case Constants.COMMAND_BASE:
                    case Constants.COMMAND_INSPECT:
                        _client.send(Constants.ID, {command: Constants.COMMAND_GET_PROPERTIES, target: ""});
                        _client.send(Constants.ID, {command: Constants.COMMAND_GET_FUNCTIONS, target: ""});
                        _client.send(Constants.ID, {command: Constants.COMMAND_GET_PREVIEW, target: ""});
                        break;
                }
            }
        }

        private function closedConnection(target:LoggerClient):void {
            _tab.disconnectMessageBox.visible = true;
            _tab.disconnectMessageBox.includeInLayout = true;
        }

        private function hideBottomPanel(e:Event):void {
            if (active) {
                _toggleTraceViewMenuItem = !_toggleTraceViewMenuItem;
                _tab.bottomPanel.visible = _toggleTraceViewMenuItem;
                _tab.bottomPanel.includeInLayout = _toggleTraceViewMenuItem;
            }
        }

        private function hideTopPanel(e:Event):void {
            if (active) {
                _toggleMonitorViewMenuItem = !_toggleMonitorViewMenuItem;
                _tab.topPanel.visible = _toggleMonitorViewMenuItem;
                _tab.topPanel.includeInLayout = _toggleMonitorViewMenuItem;
            }
        }

        private function clearTraces(e:Event):void {
            if (active) {
                _traceController.clear();
            }
        }

        public function get active():Boolean {
            return _active;
        }

        public function set active(value:Boolean):void {
            if (value) {
                MenuController.toggleMonitorViewMenuItem.checked = _toggleMonitorViewMenuItem;
                MenuController.toggleTraceViewMenuItem.checked = _toggleTraceViewMenuItem;

                _tab.bottomPanel.visible = _toggleTraceViewMenuItem;
                _tab.bottomPanel.includeInLayout = _toggleTraceViewMenuItem;

                _tab.topPanel.visible = _toggleMonitorViewMenuItem;
                _tab.topPanel.includeInLayout = _toggleMonitorViewMenuItem;
            }
            _active = value;
        }
    }
}