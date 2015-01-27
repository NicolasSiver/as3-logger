/**
 * Created by Nicolas on 1/27/2015.
 */
package im.siver.logger.demo.model {

    public class RandomTextGenerator implements Generator {
        private var _maxLength:int;
        private var _color:uint;
        private var _colors: Array;

        public function RandomTextGenerator(maxLength:int = 64) {
            _maxLength = maxLength;
            _colors = [0x9A0EC3, 0xFF0000, 0x458EFB, 0x1BB014, 0xEE8304];
        }

        private function chance(prob:Number):Boolean {
            return Math.random() <= prob;
        }

        public function getColor():uint {
            if (chance(0.1)) {
                _color = _colors[randomInt(0, _colors.length)];
            }
            return _color;
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
