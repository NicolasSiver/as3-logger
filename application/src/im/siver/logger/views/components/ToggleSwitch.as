/**
 * Created by Nicolas Siver on 1/18/2015 - 16:16.
 */
package im.siver.logger.views.components {

    import spark.components.CheckBox;
    import spark.core.IDisplayText;

    public class ToggleSwitch extends CheckBox {
        [SkinPart("false")]
        public var selectedLabelField:IDisplayText;
        [SkinPart("false")]
        public var deselectedLabelField:IDisplayText;

        private var _selectedLabel:String = 'Yes';
        private var _deselectedLabel:String = 'No';

        public function ToggleSwitch() {
        }

        public function get deselectedLabel():String {
            return _deselectedLabel;
        }

        public function set deselectedLabel(value:String):void {
            _deselectedLabel = value;
            if (deselectedLabelField) {
                deselectedLabelField.text = deselectedLabel;
            }
        }

        public function get selectedLabel():String {
            return _selectedLabel;
        }

        public function set selectedLabel(value:String):void {
            _selectedLabel = value;
            if (selectedLabelField) {
                selectedLabelField.text = selectedLabel;
            }
        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (instance == selectedLabelField) {
                selectedLabelField.text = selectedLabel;
            }
            if (instance == deselectedLabelField) {
                deselectedLabelField.text = deselectedLabel;
            }
        }
    }
}
