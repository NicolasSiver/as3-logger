package im.siver.logger.controllers {

    import flash.events.EventDispatcher;
    import flash.filesystem.File;

    import im.siver.logger.models.HistoryItem;
    import im.siver.logger.models.LoggerClient;
    import im.siver.logger.services.HistoryReader;
    import im.siver.logger.views.components.home.Home;
    import im.siver.logger.views.components.home.HomeRecentItem;
    import im.siver.logger.views.components.tabs.TabContainer;

    import mx.events.FlexEvent;

    public final class HomeController extends EventDispatcher {


        // The tab component with the screen inside
        private var _tab:Home;
        private var _exportFile:File;

        /**
         * Create a new home screen controller
         */
        public function HomeController(container:TabContainer) {
            // Create a new tab
            _tab = new Home();
            _tab.addEventListener(FlexEvent.INITIALIZE, onInit, false, 0, true);
            container.addTab(_tab);
            loadRecent();
        }

        /**
         * Creation complete
         */
        private function onInit(event:FlexEvent):void {
            // Remove
            _tab.removeEventListener(FlexEvent.INITIALIZE, onInit);
        }

        public function loadRecent():void {
            _tab.recentSessions.removeAllElements();
            var items:Vector.<HistoryItem> = HistoryReader.items;
            for (var i:int = 0; i < items.length; i++) {
                var item:HomeRecentItem = new HomeRecentItem();
                item.setItem(items[i]);
                _tab.recentSessions.addElement(item);
            }
        }

        /**
         * Add a recent item
         */
        public function addRecent(client:LoggerClient):void {
            HistoryReader.add(client);
            HistoryReader.save();
            loadRecent();
        }
    }
}