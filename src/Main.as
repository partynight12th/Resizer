package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import adobe.utils.MMExecute;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author dmc
	 */
	public class Main extends Sprite 
	{
		private var tfwidth:TextField;
		private var tfheight:TextField;
		//private var fixaspect:Sprite;
		private var fagroup:Sprite;
		private var basewidth:Number = 0;
		private var baseheight:Number = 0;
		private var distwidth:Number = 0;
		private var distheight:Number = 0;
		private var aspect:Number = 0;
		private var selectionsArray:Array = new Array();
		private static const VERSION:String = "1.2";
		private static const APPNAME:String = "Resizer";
		private static const COPYRIGHT:String = "K.Kawashima";
		
		//[Embed(source = '../lib/fixaspect_on.png')] private static const fa_on:Class;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			stage.scaleMode = "noScale";
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			ExternalInterface.addCallback("IsFwCallbackInstalled", IsFwCallbackInstalled);
			ExternalInterface.addCallback("onFwActiveSelectionChange", onFwActiveSelectionChange);
			
			var wlabel:TextField = createTextField("label", "Width : ", TextFormatAlign.RIGHT);
			addChild(wlabel);
			var hlabel:TextField = createTextField("label", "Height : ", TextFormatAlign.RIGHT);
			addChild(hlabel);
			
			
			
			tfwidth = createTextField("input", "0");
			tfwidth.background = true;
			tfwidth.backgroundColor = 0xFFFFFF;
			addChild(tfwidth);
			
			tfheight = createTextField("input", "0");
			tfheight.background = true;
			tfheight.backgroundColor = 0xFFFFFF;
			addChild(tfheight);
			
			wlabel.width = hlabel.width = Math.max(wlabel.textWidth, hlabel.textWidth) + 10;
			wlabel.height = hlabel.height = wlabel.textHeight + 5;
			wlabel.x = hlabel.x = -16;
			wlabel.y = 8;
			hlabel.y = 33;
			
			
			tfwidth.y = 6;
			tfheight.y = 31;
			tfwidth.x = tfheight.x = 36;
			tfwidth.width = tfheight.width = 44;
			tfwidth.height = tfheight.height = 21;

			tfwidth.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			tfheight.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			tfwidth.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			tfheight.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			
			fagroup = new fixAspectGroup("./Resizer/fixaspect_off.png", "./Resizer/fixaspect_on.png");
			addChild(fagroup);
			
			/*
			var fa_off_sprite:Sprite = new Sprite();
			var fa_on_sprite:Sprite = new Sprite();

			var offldr:Loader = new Loader();
			fa_off_sprite.addChild(offldr);
			offldr.load(new URLRequest("./Resizer/fixaspect_off.png"));
			var onldr:Loader = new Loader();
			fa_on_sprite.addChild(onldr);
			onldr.load(new URLRequest("./Resizer/fixaspect_on.png"));
			
			fagroup.addChild(fa_off_sprite);
			fagroup.addChild(fa_on_sprite);
			*/
			
			fagroup.x = 81;
			fagroup.y = 16;
			fagroup.buttonMode = true;
			
			fagroup.addEventListener(MouseEvent.CLICK, changeFixAspect);

			var verlabel:TextField = createTextField("label", APPNAME + "\nVer " + VERSION + "\nby " + COPYRIGHT);
			verlabel.x = 101;
			verlabel.y = 8;
			addChild(verlabel);

			onFwActiveSelectionChange();
		}
		
		private function changeFixAspect(e:MouseEvent):void {
			getSelectionBounds();
			//fixaspect.alpha = (1 / fixaspect.alpha) / 2;
			e.currentTarget.on.visible = !e.currentTarget.on.visible;
		}
		
		private function createTextField(type:String, text:String, align:String = TextFormatAlign.LEFT):TextField {
			var tformat:TextFormat = new TextFormat("_ゴシック", null, null, null, null, null, null, null, align);
			var tf:TextField = new TextField();
			tf.defaultTextFormat = tformat;
			tf.text = text;
			if (type == "input") {
				tf.border = true;
				tf.type = TextFieldType.INPUT;
				tf.selectable = true;
			}else if (type == "label") {
				tf.border  = false;
				tf.type = TextFieldType.DYNAMIC;
				tf.selectable = false;
				tf.width = tf.textWidth * 1.1;
			}
			tf.height = tf.textHeight * 1.2;
			return tf;
		}
		
		private function modifySize(distance:Number, axis:Object):void {
			var newwidth:Number = 0;
			var newheight:Number = 0;
			
			if (axis == tfwidth) {
				distwidth += distance;
				//distheight += (distance / aspect) * Math.floor(fixaspect.alpha);
				if (fagroup["on"].visible) {
					distheight += (distance / aspect);
				}
			}else {
				//distwidth += distance * aspect * Math.floor(fixaspect.alpha);
				if (fagroup["on"].visible) {
					distwidth += distance * aspect;
				}
				distheight += distance;
			}
			newwidth = basewidth + distwidth;
			newheight = baseheight + distheight;
			
			MMExecute("fw.getDocumentDOM().resizeSelection(" + newwidth + "," + newheight + ");");
			tfwidth.text = sizeNormalizeForString(newwidth);
			tfheight.text = sizeNormalizeForString(newheight);
		}
		
		private function wheelHandler(e:MouseEvent):void {
			alert("wheel");
			/*
			var distance:Number = 1;
			if (e.shiftKey) {
				distance *= 10;
			}

			if (e.delta > 0) {
			}else if(e.delta < 0) {
				distance *= -1;
			}
			modifySize(distance, e.currentTarget);
			*/
		}
		
		private function keyHandler(e:KeyboardEvent):void {

			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) {
				var difw:Number = Math.round(Number(tfwidth.text) - (basewidth + distwidth));
				var difh:Number = Math.round(Number(tfheight.text) - (baseheight + distheight));
				var dif:Number = difw == 0 ? difh : difw;
				//alert(tfwidth.text + " : " + tfheight.text + " : " + (basewidth + distwidth)  + " : " + (baseheight + distheight)  + " : " + difw + " : " + difh + " : " + dif);
				(difw != 0 || difh != 0) ? modifySize(dif, e.currentTarget) : dif = 0 ;
			}
		
			

			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) {
				var distance:Number = 1;
				if (e.shiftKey) {
					distance *= 10;
				}

				if (e.keyCode == Keyboard.UP) {
				}else if (e.keyCode == Keyboard.DOWN) {
					distance *= -1;
				}

				modifySize(distance, e.currentTarget);
			}
			
		}
		
		private function alert(str:Object):void {
			MMExecute('alert("' + str.toString() + '");');
		}
		
		public function onFwActiveSelectionChange():void {
			if (!selectionChecker()) {
				//alert("change");
				var rect:Array = getSelectionBounds();
				if(rect != null){
					tfwidth.text = sizeNormalizeForString(basewidth);
					tfheight.text = sizeNormalizeForString(baseheight);
				}else {
					tfwidth.text = "0";
					tfheight.text = "0";
				}
			}
		}
		
		private function selectionChecker():Boolean {
			var salen:int = int(MMExecute("fw.selection.length;"));
			var newarray:Array = new Array();
			var breakflag:Boolean = false;
			
			for (var i:int = 0; i < salen; i++) {
				
				if (!breakflag) {
					var objname:String = MMExecute("fw.selection[" + i + "].customData.myid;");
					//alert("objname: " + objname.length + " : " + objname);
					
					if (objname.length == 0) {
						breakflag = true;
					}
					
					var sameflag:Boolean = false;
					for (var k:int = 0; k < salen; k++) {
						//alert(selectionsArray[k] + " : " + objname);
						if (selectionsArray[k] == objname) {
							sameflag = true;
							break;
						}
					}
					
					if (!sameflag) {
						breakflag = true;
					}
				}
				var newname:String = String(Math.floor(Math.random() * 1000));
				MMExecute("fw.selection[" + i + "].customData.myid = " + newname);
				newarray.push(newname);
			}

			selectionsArray = newarray;
			if (breakflag) {
				return false;
			}
			return true;
		}
		
		private function getSelectionBounds():Array {
			var tmp:String = MMExecute("fw.getDocumentDOM().getSelectionBounds();");
			var salen:int = int(MMExecute("fw.selection.length;"));
			if (salen > 0 ) {
				var json:Array = tmp.replace(/{/, "").replace(/}/, "").replace(/ /g, "").split(",");
				var rect:Array = new Array();
				
				for (var i:int = 0; i < json.length; i++) {
					var keyvalue:Array = json[i].split(":");
					rect[keyvalue[0]] = new Number(keyvalue[1]);
				}
				
				basewidth = rect.right - rect.left;
				baseheight = rect.bottom -rect.top;
				distwidth = 0;
				distheight = 0;
				aspect = basewidth / baseheight;
				//alert("aspect modify : " + aspect);
				
				return rect;
			}else {
				basewidth = 0;
				baseheight = 0;
				distwidth = 0;
				distheight = 0;
				aspect = 0;
				return null;
			}
			
		}
		
		private function sizeNormalizeForString(value:Number, dotlen:int = 0):String {
			var underdot:int = Math.pow(10, dotlen);
			return String(Math.round(value * underdot) / underdot);
		}
		
		
		static public function IsFwCallbackInstalled( funcName:String ):Boolean {
			//alert("EVENT");
			switch( funcName )
				{
					case "onFwActiveSelectionChange":
						return true;
				}
			return false;
		}
		
	}
	
}