package {
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.factorys.StarlingFactory;

	import flash.ui.Keyboard;
	import flash.events.Event;

	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.display.Image;

	public class Dragon_SwitchClothes extends starling.display.Sprite {
		[Embed(source = "../assets/DragonWithClothes.png",mimeType = "application/octet-stream")]
		public static const ResourcesData:Class;

		private var factory:StarlingFactory;
		private var armature:Armature;
		private var armatureClip:Sprite;

		private var isLeft:Boolean;
		private var isRight:Boolean;
		private var isJumping:Boolean;
		private var moveDir:int = 0;
		private var speedX:Number = 0;
		private var speedY:Number = 0;
		private var textField:TextField;
		private var textures:Array = ["parts/clothes1","parts/clothes2","parts/clothes3","parts/clothes4"];
		private var textureIndex:int = 0;


		public function Dragon_SwitchClothes() {
			factory = new StarlingFactory();
			factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
			factory.parseData(new ResourcesData());
		}

		private function textureCompleteHandler(e:Event):void {
			armature = factory.buildArmature("Dragon");
			armatureClip = armature.display as Sprite;
			armatureClip.x = 400;
			armatureClip.y = 550;
			addChild(armatureClip);
			updateBehavior();
			addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);

			textField = new TextField(600,26,"C-change clothes;A-move left;D-move right;W-jump","Verdana",16,0,true);
			textField.x = 60;
			textField.y = 2;
			addChild(textField);
		}

		private function onKeyEventHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case Keyboard.A :
				case Keyboard.LEFT :
					isLeft = e.type == KeyboardEvent.KEY_DOWN;
					break;
				case Keyboard.D :
				case Keyboard.RIGHT :
					isRight = e.type == KeyboardEvent.KEY_DOWN;
					break;
				case Keyboard.W :
				case Keyboard.UP :
					jump();
					break;
				case Keyboard.C :
					if (e.type == KeyboardEvent.KEY_UP) {
						changeClothes();
					}
					break;
			}
			var dir:int;
			if (isLeft && isRight) {
				dir = moveDir;
				return;
			} else if (isLeft) {
				dir = -1;
			} else if (isRight) {
				dir = 1;
			} else {
				dir = 0;
			}
			if (dir==moveDir) {
				return;
			} else {
				moveDir = dir;
			}
			updateBehavior();
		}

		private function changeClothes():void {
			//Switch textures
			textureIndex++;
			if (textureIndex >= textures.length) {
				textureIndex = textureIndex - textures.length;
			}
			//Get image instance from texture data.
			var _textureName:String = textures[textureIndex];
			var _image:Image = factory.getTextureDisplay(_textureName) as Image;
			//Replace bone.display by the new texture. Don't forget to dispose.
			var _bone:Bone = armature.getBone("clothes");
			_bone.display.dispose();
			_bone.display = _image;
		}

		private function onEnterFrameHandler(_e:EnterFrameEvent):void {
			updateMove();
			armature.update();
		}

		private function updateBehavior():void {
			if (isJumping) {
				return;
			}
			if (moveDir == 0) {
				speedX = 0;
				armature.animation.gotoAndPlay("stand");
			} else {
				speedX = 6 * moveDir;
				armatureClip.scaleX =  -  moveDir;
				armature.animation.gotoAndPlay("walk");
			}
		}
		private function updateMove():void {
			if (speedX != 0) {
				armatureClip.x +=  speedX;
				if (armatureClip.x < 0) {
					armatureClip.x = 0;
				} else if (armatureClip.x > 800) {
					armatureClip.x = 800;
				}
			}
			if (isJumping) {
				if (speedY <= 0 && speedY + 1 > 0 ) {
					armature.animation.gotoAndPlay("fall");
				}
				speedY +=  1;
			}
			if (speedY != 0) {
				armatureClip.y +=  speedY;
				if (armatureClip.y > 540) {
					armatureClip.y = 550;
					isJumping = false;
					speedY = 0;
					updateBehavior();
				}
			}
		}
		private function jump():void {
			if (isJumping) {
				return;
			}
			speedY = -17;
			isJumping = true;
			armature.animation.gotoAndPlay("jump");
		}
	}
}