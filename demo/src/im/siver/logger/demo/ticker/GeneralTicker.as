/**
 * Created by Nicolas on 1/27/2015.
 */
package im.siver.logger.demo.ticker {

    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import im.siver.logger.demo.model.Generator;

    public class GeneralTicker {
        private var _timer:Timer;
        private var _generator:Generator;
        private var _trace:Function;

        public function GeneralTicker(generator:Generator, trace:Function, delay:Number = 1000) {
            _generator = generator;
            _trace = trace;
            _timer = new Timer(delay);
            _timer.addEventListener(TimerEvent.TIMER, timerDidTick);
        }

        public function start():void {
            _timer.start();
        }

        private function timerDidTick(e:TimerEvent):void {
            _trace(this, _generator.getText(), _generator.getColor());
        }
    }
}
