/**
 * Created by Nicolas on 1/27/2015.
 */
package im.siver.logger.demo {

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;

    import im.siver.logger.demo.model.RandomTextGenerator;
    import im.siver.logger.demo.ticker.GeneralTicker;
    import im.siver.logger.v1.Logger;

    public class DemoClient extends Sprite {
        private var _ticker:GeneralTicker;

        public function DemoClient() {
            addEventListener(Event.ADDED_TO_STAGE, onAdded);
        }

        private function createTicker():GeneralTicker {
            return new GeneralTicker(
                    new RandomTextGenerator(),
                    Logger.trace,
                    1000
            )
        }

        private function init():void {
            Logger.initialize(this);
            Logger.trace(this, 'Demo application');

            _ticker = createTicker();
            _ticker.start();
        }

        private function onAdded(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, onAdded);

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            init();
        }
    }
}
