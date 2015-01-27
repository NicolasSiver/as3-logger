/**
 * Created by Nicolas on 1/27/2015.
 */
package im.siver.logger.demo.model {

    public class RandomTextGenerator implements Generator {
        private var _maxLength:int;

        public function RandomTextGenerator(maxLength:int = 64) {
            _maxLength = maxLength;
        }

        private function chance(prob:Number):Boolean {
            return Math.random() <= prob;
        }

        public function getText():String {
            var len:int = randomInt(_maxLength >> 1, _maxLength);
            var result:String = '', prevChar:String = null, c:String = null;
            while (len >= 0) {
                if (prevChar == ' ' || prevChar == null) {
                    c = String.fromCharCode(randomInt(65, 90));
                } else {
                    if (chance(0.1)) {
                        c = ' ';
                    } else {
                        c = String.fromCharCode(randomInt(97, 122));
                    }
                }

                result += c;
                prevChar = c;
                len--;
            }
            return result;
        }

        private function randomInt(min:int, max:int):int {
            return Math.random() * (max - min) + min;
        }
    }
}
