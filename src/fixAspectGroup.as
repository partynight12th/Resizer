package {
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;

	public class fixAspectGroup extends Sprite {
		private var fa_off_sprite:Sprite;
		private var fa_on_sprite:Sprite;
		
		public function fixAspectGroup(offname:String, onname:String) {
			fa_off_sprite = new Sprite();
			fa_on_sprite = new Sprite();

			var offldr:Loader = new Loader();
			fa_off_sprite.addChild(offldr);
			offldr.load(new URLRequest(offname));
			var onldr:Loader = new Loader();
			fa_on_sprite.addChild(onldr);
			onldr.load(new URLRequest(onname));
			
			addChild(fa_off_sprite);
			addChild(fa_on_sprite);
		}
		
		public function get on():Sprite {
			return fa_on_sprite;
		}
	}
}