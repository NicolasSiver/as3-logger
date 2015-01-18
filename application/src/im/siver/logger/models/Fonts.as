package im.siver.logger.models {

    import flash.text.Font;

    public class Fonts {

        [Embed(source='../../../../../fonts/SourceCodePro-Light.ttf',
                fontName='SourceCodeProLight_en',
                mimeType='application/x-font',
                unicodeRange='U+0000-U+007E,U+2000-U+206F',
                embedAsCFF='false')]
        private static var MonoLightClass:Class;
        public static var MONO_LIGHT:String = 'SourceCodeProLight_en';

        [Embed(source='../../../../../fonts/SourceCodePro-Regular.ttf',
                fontName='SourceCodeProRegular_en',
                mimeType='application/x-font',
                unicodeRange='U+0000-U+007E,U+2000-U+206F',
                embedAsCFF='false')]
        private static var MonoRegularClass:Class;
        public static var MONO_REGULAR:String = 'SourceCodeProRegular_en';

        [Embed(source='../../../../../fonts/Roboto-Light.ttf',
                fontName='RobotoLight_en',
                mimeType='application/x-font',
                unicodeRange='U+0000-U+007E,U+2000-U+206F',
                embedAsCFF='true')]
        private static var RobotoLight:Class;
        public static var ROBOTO_LIGHT:String = 'RobotoLight_en';

        {
            Font.registerFont(Fonts.MonoLightClass);
            Font.registerFont(Fonts.MonoRegularClass);
            Font.registerFont(Fonts.RobotoLight);
        }
    }
}
