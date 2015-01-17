package im.siver.logger.controllers
{
	import im.siver.logger.views.components.home.Home;
	import im.siver.logger.views.components.home.HomeRecentItem;
	import im.siver.logger.views.components.tabs.TabContainer;
	import spark.events.IndexChangeEvent;
	import im.siver.logger.models.LoggerClient;
	import im.siver.logger.models.Constants;
	import im.siver.logger.services.HistoryReader;
	import im.siver.logger.models.HistoryItem;
	import mx.events.FlexEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;


	public final class HomeController extends EventDispatcher
	{


		// The tab component with the screen inside
		private var _tab:Home;
		private var _exportFile:File;


		/**
		 * Create a new home screen controller
		 */
		public function HomeController(container:TabContainer)
		{
			// Create a new tab
			_tab = new Home();
			_tab.addEventListener(FlexEvent.INITIALIZE, onInit, false, 0, true);
			container.addTab(_tab);
			loadRecent();
		}


		/**
		 * Creation complete
		 */
		private function onInit(event:FlexEvent):void
		{
			// Remove
			_tab.removeEventListener(FlexEvent.INITIALIZE, onInit);
			_tab.buttonStart.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonBack.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonCopy.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonExport.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.dropdownTarget.addEventListener(IndexChangeEvent.CHANGE, selectedTarget, false, 0, true);
			_tab.dropdownType.addEventListener(IndexChangeEvent.CHANGE, selectedType, false, 0, true);
		}


		/**
		 * Button clicked
		 */
		private function clickHandler(event:MouseEvent):void
		{
			// Remove
			switch (event.target) {
				case _tab.buttonStart:
					_tab.groupHome.visible = false;
					_tab.groupHome.includeInLayout = false;
					_tab.groupWizzard.visible = true;
					_tab.groupWizzard.includeInLayout = true;
					break;
				case _tab.buttonBack:
					_tab.groupHome.visible = true;
					_tab.groupHome.includeInLayout = true;
					_tab.groupWizzard.visible = false;
					_tab.groupWizzard.includeInLayout = false;
					break;
				case _tab.buttonCopy:
					System.setClipboard(_tab.codeField.text);
					break;
				case _tab.buttonExport:
					if (_exportFile != null) {
						var file:File = File.desktopDirectory.resolvePath(_exportFile.name);
						file.addEventListener(Event.SELECT, function(e:Event):void {
							_exportFile.copyTo(file, true);
						});
						file.browseForSave("Save " + _exportFile.name);
					}
					break;
			}
		}


		private function selectedType(event:IndexChangeEvent = null):void
		{
			_tab.dropdownTarget.enabled = true;
			_tab.labelStep2.setStyle('color', 0x000000);
			generateExampleCode();
		}


		private function selectedTarget(event:IndexChangeEvent = null):void
		{
			_tab.buttonExport.enabled = true;
			_tab.labelStep3.setStyle('color', 0x000000);
			_tab.labelStep4.setStyle('color', 0x000000);
			_tab.codeField.enabled = true;
			_tab.buttonCopy.enabled = true;
			generateExampleCode();
		}


		/**
		 * Change the source code
		 */
		private function generateExampleCode(event:IndexChangeEvent = null):void
		{
			/*FDT_IGNORE*/
			
			// Actionscript
			if (_tab.dropdownType.selectedIndex != 2 && _tab.dropdownType.selectedIndex == 0) {
				var exampleAS3:String = 'package {' + '\n';
				exampleAS3 += '' + '\n';
				exampleAS3 += '    import com.demonsters.debugger.MonsterDebugger;' + '\n';
				exampleAS3 += '    import flash.display.Sprite;' + '\n';
				exampleAS3 += '    ' + '\n';
				exampleAS3 += '    public class im.siver.logger.Main extends Sprite {' + '\n';
				exampleAS3 += '    ' + '\n';
				exampleAS3 += '        public function im.siver.logger.Main() {' + '\n';
				exampleAS3 += '        ' + '\n';
				exampleAS3 += '            // Start the MonsterDebugger' + '\n';
				exampleAS3 += '            MonsterDebugger.initialize(this);' + '\n';
				exampleAS3 += '            MonsterDebugger.trace(this, "Hello World!");' + '\n';
				exampleAS3 += '        }' + '\n';
				exampleAS3 += '    }' + '\n';
				exampleAS3 += '}';
				_tab.codeField.text = exampleAS3;
			}
			
			// MXML
			if (_tab.dropdownType.selectedIndex != 2 && _tab.dropdownType.selectedIndex == 1) {
				var exampleMXML:String = '<?xml version="1.0" encoding="utf-8"?>' + '\n';
				exampleMXML += '<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009"  xmlns:s="library://ns.adobe.com/flex/spark" xmlns:mx="library://ns.adobe.com/flex/mx"  xmlns:debugger="com.demonsters.debugger.*" creationComplete="onCreationComplete()">' + '\n';
				exampleMXML += '    <fx:Script>' + '\n';
				exampleMXML += '        <![CDATA[' + '\n';
				exampleMXML += '            ' + '\n';
				exampleMXML += '            import mx.logging.ILogger;' + '\n';
				exampleMXML += '            import mx.logging.Log;' + '\n';
				exampleMXML += '            ' + '\n';
				exampleMXML += '            private function onCreationComplete():void {' + '\n';
				exampleMXML += '                ' + '\n';
				exampleMXML += '                // Monster Debugger trace message' + '\n';
				exampleMXML += '                monsterDebugger.trace(this, "Hello World!");' + '\n';
				exampleMXML += '                ' + '\n';
				exampleMXML += '                // Flex trace message' + '\n';
				exampleMXML += '                var logger:ILogger = Log.getLogger("im.siver.logger.Main.mxml");' + '\n';
				exampleMXML += '                logger.error("Hello World!");' + '\n';
				exampleMXML += '            }' + '\n';
				exampleMXML += '        ]]>' + '\n';
				exampleMXML += '    </fx:Script>' + '\n';
				exampleMXML += '    <debugger:MonsterDebuggerFlex id="monsterDebugger"/>' + '\n';
				exampleMXML += '</s:Application>' + '\n';
				_tab.codeField.text = exampleMXML;
			}
			
			
			/*FDT_IGNORE*/
			
			// Desktop
			if (_tab.dropdownTarget.selectedIndex == 0) {
				_exportFile = File.applicationDirectory.resolvePath("export/MonsterDebugger.swc");
			}

			// Mobile
			if (_tab.dropdownTarget.selectedIndex == 1) {
				_exportFile = File.applicationDirectory.resolvePath("export/MonsterDebuggerMobile.swc");
			}
		}


		public function loadRecent():void
		{
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
		public function addRecent(client:LoggerClient):void
		{
			HistoryReader.add(client);
			HistoryReader.save();
			loadRecent();
		}
	}
}