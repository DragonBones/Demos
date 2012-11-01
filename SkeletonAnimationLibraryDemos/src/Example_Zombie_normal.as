package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import dragonBones.Armature;
	import dragonBones.factorys.BaseFactory;
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Zombie_normal extends flash.display.Sprite {
		[Embed(source = "../assets/Zombie.swf", mimeType = "application/octet-stream")]
		private static const ResourcesData:Class;
		
		private var factory:BaseFactory;
		private var allArmatureNameList:Array;
		private var armatures:Array;
		
		public function Example_Zombie_normal() {
			baseInit();
		}
		
		private function baseInit():void {
			factory = new BaseFactory();
			factory.fromRawData(new ResourcesData(), textureCompleteHandler);
			allArmatureNameList = factory.skeletonData.getSearchList();
			armatures = [];
		}
	
		private function textureCompleteHandler():void {
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			stage.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		private function onMouseClickHandler(_e:Event):void {
			var _randomID:String = allArmatureNameList[int(Math.random() * allArmatureNameList.length)];
			var _armature:Armature = factory.buildArmature(_randomID);
			
			_armature.display.x = mouseX;
			_armature.display.y = mouseY;
			
			var _randomMovement:String = _armature.animation.movementList[int(Math.random() * _armature.animation.movementList.length)];
			_armature.animation.gotoAndPlay(_randomMovement);
			addChild(_armature.display as Sprite);
			armatures.push(_armature);
		}
		
		private function onEnterFrameHandler(_e:Event):void {
			for each(var _armature:Armature in armatures) {
				_armature.update();
			}
		}
	}
}
